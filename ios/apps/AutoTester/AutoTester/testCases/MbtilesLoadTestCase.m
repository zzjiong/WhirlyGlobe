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

@property (nonatomic, strong) MaplyMBTileFetcher *fetcherAmm;

@property (nonatomic, strong) MaplyQuadImageLoader *imageLoaderAmm;

@property (nonatomic, strong) MaplyMBTileFetcher *fetcher2;

@property (nonatomic, strong) MaplyQuadImageLoader *imageLoader2;

@property (nonatomic, strong) WhirlyGlobeViewController *globalVC;

@property (nonatomic,assign) NSInteger count;

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
    
    _globalVC = globeVC;
    _count = 0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(50, 100, 100, 50);
    [button setTitle:@"Change" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [globeVC.view addSubview:button];
    
    MaplyMBTileFetcher *fetcher = [[MaplyMBTileFetcher alloc] initWithMBTiles:@"geography-class_medres"];
    MaplySamplingParams *params = [[MaplySamplingParams alloc] init];
//    params.forceMinLevel = false;
    params.minZoom = 0;
    params.maxZoom = [fetcher maxZoom];
    params.coordSys = [[MaplySphericalMercator alloc] initWebStandard];
    params.singleLevel = true;
    MaplyQuadImageLoader *imageLoader = [[MaplyQuadImageLoader alloc] initWithParams:params tileInfo:fetcher.tileInfo viewC:globeVC];
    [imageLoader setTileFetcher:fetcher];
    imageLoader.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault + 10;

    self.fetcher = fetcher;
    self.imageLoader = imageLoader;
    
//    //AMM
//    {
//        MaplyMBTileFetcher *fetcher = [[MaplyMBTileFetcher alloc] initWithMBTiles:@"ZBAA"];
//        MaplySamplingParams *params = [[MaplySamplingParams alloc] init];
//        params.coordSys = [[MaplySphericalMercator alloc] initWebStandard];
//    //    params.forceMinLevel = false;
//        params.minZoom = 0;
//        params.maxZoom = [fetcher maxZoom];
//        params.singleLevel = true;
//        params.coverPoles = false;
//        params.edgeMatching = false;
//
//        MaplyQuadImageLoader *imageLoader = [[MaplyQuadImageLoader alloc] initWithParams:params tileInfo:fetcher.tileInfo viewC:globeVC];
//        [imageLoader setTileFetcher:fetcher];
//        imageLoader.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault + 100;
//        self.fetcherAmm = fetcher;
//        self.imageLoaderAmm = imageLoader;
//    }
        
    MaplyCoordinate coords = MaplyCoordinateMakeWithDegrees(116.596667, 40.071667);
    MaplyScreenMarker *marker = [[MaplyScreenMarker alloc] init];
    marker.image = [UIImage imageNamed:@"airport-24"];
    marker.loc = coords;
    [globeVC addScreenMarkers:@[marker] desc:nil];
    
    [globeVC animateToPosition:coords time:0];
}

- (void)globeViewController:(WhirlyGlobeViewController *__nonnull)viewC allSelect:(NSArray *__nonnull)selectedObjs atLoc:(MaplyCoordinate)coord onScreen:(CGPoint)screenPt{

    MaplySelectedObject *selectedObject = selectedObjs.firstObject;
    MaplyVectorObject *selectedObj = selectedObject.selectedObj;
    
    NSLog(@"%@",selectedObj.attributes);
    
}

- (void)buttonClick:(UIButton *)button{
     
    _count ++;
    MaplyMBTileFetcher *fetcher;
    if (_count % 2 != 1) {
//        fetcher = [[MaplyMBTileFetcher alloc] initWithMBTiles:@"geography-class_medres"];
        [self.imageLoader2 shutdown];
        return;
    }else{
        fetcher = [[MaplyMBTileFetcher alloc] initWithMBTiles:@"world9"];
//        fetcher.darkMode = YES;
    }
    MaplySamplingParams *params = [[MaplySamplingParams alloc] init];
    params.forceMinLevel = false;
    params.minZoom = 0;
    params.maxZoom = [fetcher maxZoom];
    params.coordSys = [[MaplySphericalMercator alloc] initWebStandard];
    params.singleLevel = true;
    MaplyQuadImageLoader *imageLoader = [[MaplyQuadImageLoader alloc] initWithParams:params tileInfo:fetcher.tileInfo viewC:_globalVC];
    [imageLoader setTileFetcher:fetcher];
    imageLoader.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault + 1000;
//    imageLoader.drawPriorityPerLevel = 2000;

//    MaplyQuadImageLoader *tmpImageLoader = self.imageLoader;
    self.fetcher2 = fetcher;
    self.imageLoader2 = imageLoader;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [tmpImageLoader shutdown];
//    });
    
//    self.fetcher = [[MaplyMBTileFetcher alloc] initWithMBTiles:@"world9"];
//    [self.imageLoader changeTileInfo:self.fetcher.tileInfo];
//    [self.imageLoader reload];
        
}

@end
