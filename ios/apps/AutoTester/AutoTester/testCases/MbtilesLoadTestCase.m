//
//  MbtilesLoadTestCase.m
//  AutoTester
//
//  Created by zhoujiong on 2020/12/23.
//  Copyright © 2020 mousebird consulting. All rights reserved.
//

#import "MbtilesLoadTestCase.h"
#import "AutoTester-Swift.h"

@interface MbtilesLoadTestCase ()

@property (nonatomic, strong) GeographyClassTestCase *testCase;

@property (nonatomic, strong) MaplyMBTileFetcher *fetcher;

@property (nonatomic, strong) MaplyQuadImageLoader *imageLoader;

@end

@implementation MbtilesLoadTestCase

- (instancetype)init
{
    if (self = [super init]) {
        self.name = @"MbtilesLoad";
        self.implementations = MaplyTestCaseImplementationGlobe;
        
    }
    
    return self;
}

- (void) setup {
    // set up the data source
    self.testCase = [[GeographyClassTestCase alloc] init];
}

- (void)setUpWithGlobe:(WhirlyGlobeViewController *)globeVC{
    
//    [self setup];
//    [_testCase setUpWithGlobe:globeVC];
    
    MaplyMBTileFetcher *fetcher = [[MaplyMBTileFetcher alloc] initWithMBTiles:@"world9"];
    MaplySamplingParams *params = [[MaplySamplingParams alloc] init];
//    params.forceMinLevel = false;
    params.minZoom = 0;
    params.maxZoom = [fetcher maxZoom];
    params.coordSys = [[MaplySphericalMercator alloc] initWebStandard];
    params.singleLevel = true;
    MaplyQuadImageLoader *imageLoader = [[MaplyQuadImageLoader alloc] initWithParams:params tileInfo:fetcher.tileInfo viewC:globeVC];
    [imageLoader setTileFetcher:fetcher];
    imageLoader.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault;
    
    self.fetcher = fetcher;
    self.imageLoader = imageLoader;
    
    NSString *jsonStr = @"{\"type\":\"Polygon\",\"coordinates\":[[[-100,35.82916699999999],[-99.249939,35.825256],[-98.49999999999999,35.816667],[-98.016667,35.88333099999999],[-97.88333099999999,35.92499699999999],[-97.58333099999999,35.49166699999999],[-97.083331,35.458331],[-96.40416699999999,35.64999699999999],[-96.049997,35.870831],[-95.61249700000001,36.01666699999999],[-95,35.654167],[-95,35.066667],[-94.783331,34.691667],[-94.533331,34.53333099999999],[-94.03603099999999,34.284339],[-93.541667,34.03333099999999],[-93.158331,33.95],[-92.525747,33.47869699999999],[-91.90000000000001,33.004167],[-91.688889,32.28333099999999],[-92.25833099999999,32.28333099999999],[-92.79166700000001,31.92195299999999],[-93.320831,31.55833099999999],[-94.19999999999999,31.572219],[-95.09216699999999,31.52254999999999],[-95.98333100000001,31.46666699999999],[-96.68333099999999,31.204167],[-97.2,31.199997],[-97.5125,31.21249699999999],[-97.7125,31.375],[-97.794442,31.390278],[-98.63058599999998,31.389531],[-99.46666699999999,31.38333099999999],[-100.009472,31.18447499999999],[-100.549997,30.983331],[-101.3487389999999,31.135817],[-102.15,31.28333099999999],[-102.7405109999999,31.46803299999999],[-103.3333309999999,31.649997],[-103.7999969999999,32.03333099999999],[-103.9333309999999,32.466667],[-103.7999969999999,32.99999999999999],[-103.7999969999999,33.38333099999999],[-103.6916669999999,33.40277799999999],[-103.366667,33.77499699999999],[-102.7999969999999,34.316667],[-102.3249999999999,34.54999699999999],[-102,34.59999999999999],[-101.3744999999999,34.534931],[-100.75,34.466667],[-100.3166669999999,34.86666699999999],[-100,35.333331],[-100,35.82916699999999],[-100,35.82916699999999],[-100,35.82916699999999]]]}";
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    MaplyVectorObject *mvObject = [MaplyVectorObject VectorObjectFromGeoJSONApple:jsonData];
//    mvObject.selectable = YES;
    [mvObject subdivideToGlobe:0.0001];
    MaplyComponentObject *maplyOject = [globeVC addVectors:@[mvObject] desc:@{kMaplyMinVis:@(0),kMaplyMaxVis : @(2),kMaplyDrawPriority:@(kMaplyVectorDrawPriorityDefault-100),kMaplyColor:[UIColor redColor],kMaplyFilled: @(NO),kMaplyVecWidth: @(10.0),kMaplySelectable:@(YES)} mode:MaplyThreadAny];
   [globeVC setPosition:mvObject.center];
}

- (void)globeViewController:(WhirlyGlobeViewController *)viewC didStopMoving:(MaplyCoordinate *)corners userMotion:(bool)userMotion{
    
}

- (void)globeViewController:(WhirlyGlobeViewController *__nonnull)viewC allSelect:(NSArray *__nonnull)selectedObjs atLoc:(MaplyCoordinate)coord onScreen:(CGPoint)screenPt{

    MaplySelectedObject *selectedObject = selectedObjs.firstObject;
    MaplyVectorObject *selectedObj = selectedObject.selectedObj;
    
    NSLog(@"%@",selectedObj.attributes);
    
}

@end
