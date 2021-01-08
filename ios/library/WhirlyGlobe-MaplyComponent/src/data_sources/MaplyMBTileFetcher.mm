/*
 *  MaplyMBTileFetcher.mm
 *  WhirlyGlobe-MaplyComponent
 *
 *  Created by Steve Gifford on 9/13/18.
 *  Copyright 2011-2019 mousebird consulting inc
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#import "data_sources/MaplyMBTileFetcher.h"
#import "MaplyCoordinateSystem_private.h"
#import "WhirlyGlobe.h"
#import "sqlhelpers.h"

using namespace WhirlyKit;

@implementation MaplyMBTileFetcher
{
    bool tilesStyles;
    int minZoom,maxZoom;
    Mbr mbr;
    GeoMbr geoMbr;
    sqlite3 *sqlDb;
    MaplyCoordinateSystem *coordSys;
}

- (nullable instancetype)initWithMBTiles:(NSString *__nonnull)mbTilesName
{
    NSString *infoPath = nil;
    // See if that was a direct path first
    if ([[NSFileManager defaultManager] fileExistsAtPath:mbTilesName])
        infoPath = mbTilesName;
    else {
        // Try the documents directory
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        infoPath = [NSString stringWithFormat:@"%@/%@",docDir,mbTilesName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:infoPath])
            infoPath = nil;
        if (!infoPath)
        {
            // Now try looking for it in the bundle
            infoPath = [[NSBundle mainBundle] pathForResource:mbTilesName ofType:@"mbtiles"];
            if (!infoPath)
            {
                infoPath = [[NSBundle mainBundle] pathForResource:mbTilesName ofType:@"sqlite"];
                if (!infoPath)
                    return nil;
            }
        }
    }
    
    // Open the sqlite DB
    sqlite3 *db = nil;
    if (sqlite3_open([infoPath cStringUsingEncoding:NSASCIIStringEncoding],&db) != SQLITE_OK)
    {
        return nil;
    }
    
    const auto cs = [[MaplySphericalMercator alloc] initWebStandard];
    
    // Look at the metadata
    GeoMbr gmbr;
    try
    {
        sqlhelpers::StatementRead readStmt(db,@"select value from metadata where name='bounds';");
        if (readStmt.stepRow())
        {
            NSString *bounds = readStmt.getString();
            NSScanner *scan = [NSScanner scannerWithString:bounds];
            NSMutableCharacterSet *charSet = [[NSMutableCharacterSet alloc] init];
            [charSet addCharactersInString:@", "];
            [scan setCharactersToBeSkipped:charSet];
            double ll_lat,ll_lon,ur_lat,ur_lon;
            if (![scan scanDouble:&ll_lon] ||
                ![scan scanDouble:&ll_lat] ||
                ![scan scanDouble:&ur_lon] ||
                ![scan scanDouble:&ur_lat])
            {
                return nil;
            }
            gmbr.ll() = GeoCoord::CoordFromDegrees(ll_lon,ll_lat);
            gmbr.ur() = GeoCoord::CoordFromDegrees(ur_lon,ur_lat);
        } else {
            // No bounds implies it covers the whole earth
            gmbr.ll() = GeoCoord::CoordFromDegrees(-180, -85.0511);
            gmbr.ur() = GeoCoord::CoordFromDegrees(180, 85.0511);
        }
        
        // And let's convert that over to spherical mercator
        const Point3f ll = [cs getCoordSystem]->geographicToLocal(gmbr.ll());
        mbr.ll() = Point2f(ll.x(),ll.y());
        const Point3f ur = [cs getCoordSystem]->geographicToLocal(gmbr.ur());
        mbr.ur() = Point2f(ur.x(),ur.y());

        minZoom = 0;  maxZoom = 8;
        sqlhelpers::StatementRead readStmt2(db,@"select value from metadata where name='minzoom';");
        if (readStmt2.stepRow())
            minZoom = [readStmt2.getString() intValue];
        else {
            // Read it the hard way
            sqlhelpers::StatementRead readStmt3(db,@"select min(zoom_level) from tiles;");
            if (readStmt3.stepRow())
                minZoom = [readStmt3.getString() intValue];
        }
        sqlhelpers::StatementRead readStmt3(db,@"select value from metadata where name='maxzoom';");
        if (readStmt3.stepRow())
            maxZoom = [readStmt3.getString() intValue];
        else {
            // Read it the hard way
            sqlhelpers::StatementRead readStmt3(db,@"select max(zoom_level) from tiles;");
            if (readStmt3.stepRow())
                maxZoom = [readStmt3.getString() intValue];
        }
        
        sqlhelpers::StatementRead readStmt4(db,"select value from metadata where name='format';");
        if (readStmt4.stepRow())
            _format = readStmt4.getString();
        
        // See if there's a tiles table or it's the older(?) style
        sqlhelpers::StatementRead testStmt(db,@"SELECT name FROM sqlite_master WHERE type='table' AND name='tiles';");
        if (testStmt.stepRow())
            tilesStyles = true;
    } catch (int e) {
        NSLog(@"Exception fetching MBTiles metadata (%d)", e);
        if (db) {
            sqlite3_close(db);
        }
        return nil;
    } catch (...) {
        NSLog(@"Unknown exception fetching MBTiles metadata");
        if (db) {
            sqlite3_close(db);
        }
        return nil;
    }

    self = [super initWithName:mbTilesName minZoom:minZoom maxZoom:maxZoom];
    geoMbr = gmbr;
    coordSys = cs;
    sqlDb = db;
    
    return self;
}

- (MaplyCoordinateSystem *)coordSys
{
    return coordSys;
}

- (id)dataForTile:(id)fetchInfo tileID:(MaplyTileID)tileID;
{
    NSData *imageData = nil;
    
    @synchronized(self)
    {
        try {
            if (tilesStyles)
            {
                sqlhelpers::StatementRead readStmt(sqlDb,[NSString stringWithFormat:@"SELECT tile_data from tiles where zoom_level='%d' AND tile_column='%d' AND tile_row='%d';",tileID.level,tileID.x,tileID.y]);
                if (readStmt.stepRow())
                    imageData = readStmt.getBlob();
            } else {
                sqlhelpers::StatementRead readStmt(sqlDb,[NSString stringWithFormat:@"SELECT tile_id from map where zoom_level='%d' AND tile_column='%d' AND tile_row='%d';",tileID.level,tileID.x,tileID.y]);
                if (readStmt.stepRow())
                {
                    NSString *tile_id = readStmt.getString();
                    sqlhelpers::StatementRead readStmt2(sqlDb,[NSString stringWithFormat:@"SELECT tile_data from images where tile_id='%@';",tile_id]);
                    if (readStmt2.stepRow())
                        imageData = readStmt2.getBlob();
                }
            }
        } catch (int e) {
            NSLog(@"Exception in [MaplyMBTileSouce imageForTile:]");
        }
    }
    
    //**修改 20210105--周炯
    if(self.darkMode){
        UIImage *image = [UIImage imageWithData:imageData];
        UIImage *resImg = [self imageBlackToTransparent:image];
        imageData = UIImageJPEGRepresentation(resImg,1.0f);
    }
    return imageData;
}

- (void)shutdown
{
    [super shutdown];
    
    if (sqlDb) {
        sqlite3_close(sqlDb);
        sqlDb = nullptr;
    }
}

void ProviderReleaseData (void *info, const void *data, size_t size)
{
    free((void*)data);
}

- (UIImage*) imageBlackToTransparent:(UIImage*) image{
    // 分配内存c
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++)
    {
        // 改成下面的代码，会将图片转成灰度
        uint8_t* ptr = (uint8_t*)pCurPtr;
        
        UInt8 red,green,blue;
        red= ptr[3];
        green =   ptr[2] ;
        blue= ptr[1] ;
        
        if(red > 240){
            ptr[3] = 31;
            ptr[2] = 31;
            ptr[1] = 31;
        }else{
            ptr[3] = 15;
            ptr[2] = 28;
            ptr[1] = 73;
        }
        //        ptr[3] = 255 - red;
        //        ptr[2] = 255 - green;
        //        ptr[1] = 255 - blue;
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // free(rgbImageBuf) 创建dataProvider时已提供释放函数，这里不用free
    
    return resultUIImage;    
}

@end
