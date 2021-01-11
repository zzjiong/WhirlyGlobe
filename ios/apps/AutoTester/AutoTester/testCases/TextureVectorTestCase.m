//
//  TextureVectorTestCase.m
//  AutoTester
//
//  Created by Steve Gifford on 11/2/16.
//  Copyright © 2016-2021 mousebird consulting.
//

#import "TextureVectorTestCase.h"
#import "AutoTester-Swift.h"

@implementation TextureVectorTestCase
{
    MaplyTexture *dotsTexture;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.name = @"Textured Vectors";
        self.implementations = MaplyTestCaseImplementationGlobe | MaplyTestCaseImplementationMap;
    }
    
    return self;
}

// Grid size to use for clipping
// Smaller is going to be more triangles, but look better
// Might be better to use a bigger size for the poles
static const float ClipGridSize = 2.0/180.0*M_PI;

- (void) overlayCountries: (MaplyBaseViewController*) baseVC globeMode:(bool)globeMode
{
    NSMutableArray *tessObjs = [NSMutableArray array];
    
    NSArray * paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"geojson" inDirectory:nil];
    // Sort so that the results don't depend on the bundle ordering
    NSArray * sortedPaths = [paths sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@""
                                      ascending:NO  // first 20 are slow, use the last 20
                                       selector:@selector(localizedStandardCompare:)]
        ]];
    int count = 0;
    // Work through the individual GeoJSON files
    for (NSString* fileName  in sortedPaths) {
		NSLog(@"Loading %@...", fileName);
        if (count++ > 20)
            break;
        NSData *jsonData = [NSData dataWithContentsOfFile:fileName];
        if (jsonData) {
            MaplyVectorObject *countryVec = [MaplyVectorObject VectorObjectFromGeoJSON:jsonData];
            if (countryVec)
            {
                MaplyVectorObject *tessObj;
                // We want each individual loop so we can center them properly
                for (MaplyVectorObject *thisVecObj in [countryVec splitVectors])
                {
                    MaplyVectorObject *vecObj = [thisVecObj deepCopy2];
                    // This will be the center of the texture application
                    MaplyCoordinate center = [vecObj centroid];
                    vecObj.attributes[kMaplyVecCenterX] = @(center.x);
                    vecObj.attributes[kMaplyVecCenterY] = @(center.y);

                    float thisClipGridLon = ClipGridSize;
                    if (globeMode)
                    {
                        // We adjust the grid clipping size based on the latitude
                        // This helps a lot near the poles.  Otherwise we're way oversampling
                        if (ABS(center.y) > 60.0/180.0 * M_PI)
                            thisClipGridLon *= 4.0;
                        else if (ABS(center.y) > 45.0/180.0 * M_PI)
                            thisClipGridLon *= 2.0;
                        
                        // We clip the vector to a grid and then tesselate the results
                        // This forms the vector closer to the globe, make it look nicer
                    }

                    tessObj = [[vecObj clipToGrid:CGSizeMake(thisClipGridLon, ClipGridSize)] tesselate];

                    // Don't add them yet, it's more efficient later
                    if (tessObj)
                        [tessObjs addObject:tessObj];
                }
            }
        }
    }
        
    // Add all the vectors at once to be more efficient
    // The geometry gets grouped together, which is nice and fast
    [baseVC addVectors:tessObjs desc:
     @{
       kMaplyFilled: @(YES),
       // We'll apply this texture when filled
       kMaplyVecTexture: dotsTexture,
       // The texture is applied with a tanget plane from the center
       kMaplyVecTextureProjection: globeMode ? kMaplyProjectionTangentPlane : kMaplyProjectionNone,
       // The texture coordinates will be scaled like so
       kMaplyVecTexScaleX: @(6.0),
       kMaplyVecTexScaleY: @(6.0),
       kMaplyColor: [UIColor whiteColor]
       }];
    
    // Turn this on to see the tessellation over the top.  Good for debugging
    //[baseVC addVectors:tessObjs desc:@{kMaplyDrawPriority: @(kMaplyVectorDrawPriorityDefault+1000)} mode:MaplyThreadCurrent];
}

- (void)setupTexture:(MaplyBaseViewController *)viewC
{
    UIImage *dotsImage = [UIImage imageNamed:@"dots.png"];

    dotsTexture = [viewC addTexture:dotsImage
                               desc:@{kMaplyTexWrapX: @(YES),kMaplyTexWrapY: @(YES)}
                               mode:MaplyThreadAny];
}

- (void)setUpWithGlobe:(WhirlyGlobeViewController *)globeVC
{
    [self setupTexture:globeVC];
    
    globeVC.keepNorthUp = true;
    self.baseView = [[GeographyClassTestCase alloc]init];
    [self.baseView setUpWithGlobe:globeVC];
    [globeVC animateToPosition:MaplyCoordinateMakeWithDegrees(-100.0, 0.0) time:1.0];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       //Overlay Countries
                       [self overlayCountries:(MaplyBaseViewController*)globeVC globeMode:true];
                   });
}


- (void)setUpWithMap:(MaplyViewController *)mapVC
{
    [self setupTexture:mapVC];

    self.baseView = [[GeographyClassTestCase alloc]init];
    [self.baseView setUpWithMap:mapVC];
    [mapVC animateToPosition:MaplyCoordinateMakeWithDegrees(-100.0, 0.0) time:1.0];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       [self overlayCountries:(MaplyBaseViewController*)mapVC globeMode:false];
                   });
}

@end
