//
//  CrashProblem.m
//  AutoTester
//
//  Created by zhoujiong on 2020/12/24.
//  Copyright © 2020 mousebird consulting. All rights reserved.
//

#import "CrashProblem.h"
#import "AutoTester-Swift.h"

@interface CrashProblem ()

@property (nonatomic, strong) GeographyClassTestCase *testCase;

@property (nonatomic,strong) NSMutableArray *maplyComponentObjectArray;

@property (nonatomic,strong) MaplyComponentObject *compObjPointLabel;

@property (nonatomic,strong) MaplyComponentObject *maplyOject;

@end

@implementation CrashProblem

- (instancetype)init
{
    if (self = [super init]) {
        self.name = @"CrashProblem";
        self.implementations = MaplyTestCaseImplementationGlobe;
        
    }
    
    return self;
}

- (void) setup {
    // set up the data source
    self.testCase = [[GeographyClassTestCase alloc] init];
}

- (void)setUpWithGlobe:(WhirlyGlobeViewController *)globeVC{
    
    [self setup];
    [_testCase setUpWithGlobe:globeVC];
    
    globeVC.keepNorthUp = true;//保持正北朝上
    globeVC.height = 2.0;
    globeVC.delegate = self;
    
    [globeVC setPosition:MaplyCoordinateMakeWithDegrees(120,40)];
    
    [self addVectorWithGlobe:globeVC];

}

- (void)addVectorWithGlobe:(WhirlyGlobeViewController *)globeVC{
    
    NSString *jsonStr = @"{\"type\":\"Polygon\",\"coordinates\":[[[-100,35.82916699999999],[-99.249939,35.825256],[-98.49999999999999,35.816667],[-98.016667,35.88333099999999],[-97.88333099999999,35.92499699999999],[-97.58333099999999,35.49166699999999],[-97.083331,35.458331],[-96.40416699999999,35.64999699999999],[-96.049997,35.870831],[-95.61249700000001,36.01666699999999],[-95,35.654167],[-95,35.066667],[-94.783331,34.691667],[-94.533331,34.53333099999999],[-94.03603099999999,34.284339],[-93.541667,34.03333099999999],[-93.158331,33.95],[-92.525747,33.47869699999999],[-91.90000000000001,33.004167],[-91.688889,32.28333099999999],[-92.25833099999999,32.28333099999999],[-92.79166700000001,31.92195299999999],[-93.320831,31.55833099999999],[-94.19999999999999,31.572219],[-95.09216699999999,31.52254999999999],[-95.98333100000001,31.46666699999999],[-96.68333099999999,31.204167],[-97.2,31.199997],[-97.5125,31.21249699999999],[-97.7125,31.375],[-97.794442,31.390278],[-98.63058599999998,31.389531],[-99.46666699999999,31.38333099999999],[-100.009472,31.18447499999999],[-100.549997,30.983331],[-101.3487389999999,31.135817],[-102.15,31.28333099999999],[-102.7405109999999,31.46803299999999],[-103.3333309999999,31.649997],[-103.7999969999999,32.03333099999999],[-103.9333309999999,32.466667],[-103.7999969999999,32.99999999999999],[-103.7999969999999,33.38333099999999],[-103.6916669999999,33.40277799999999],[-103.366667,33.77499699999999],[-102.7999969999999,34.316667],[-102.3249999999999,34.54999699999999],[-102,34.59999999999999],[-101.3744999999999,34.534931],[-100.75,34.466667],[-100.3166669999999,34.86666699999999],[-100,35.333331],[-100,35.82916699999999],[-100,35.82916699999999],[-100,35.82916699999999]]]}";
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    MaplyVectorObject *mvObject = [MaplyVectorObject VectorObjectFromGeoJSONApple:jsonData];
    mvObject.selectable = YES;
    [mvObject subdivideToGlobe:0.0001];
        self.maplyOject = [globeVC addVectors:@[mvObject] desc:@{kMaplyMinVis:@(0),kMaplyMaxVis : @(2),kMaplyDrawPriority:@(kMaplyMaxDrawPriorityDefault+100),kMaplyColor:[UIColor greenColor],kMaplyFilled: @(NO),kMaplyVecWidth: @(3.0)} mode:MaplyThreadAny];
    UIImage *image = [UIImage imageNamed:@"gjx.png"];
    MaplyTexture *lineTexture = [globeVC addTexture:image
                                          imageFormat:MaplyImageIntRGBA
                                            wrapFlags:MaplyImageWrapY
                                                 mode:MaplyThreadCurrent];
//    MaplyLinearTextureBuilder *lineTexBuilder = [[MaplyLinearTextureBuilder alloc] init];
//    [lineTexBuilder setPattern:@[@10,@10]];
//    UIImage *lineImage = [lineTexBuilder makeImage];
//    MaplyTexture *lineTexture = [globeVC addTexture:lineImage
//                                          imageFormat:MaplyImageIntRGBA
//                                            wrapFlags:MaplyImageWrapY
//                                                 mode:MaplyThreadCurrent];
    self.maplyOject = [globeVC addWideVectors:@[mvObject] desc:@{kMaplyColor: [UIColor blueColor],
    kMaplyDrawPriority: @(kMaplyMaxDrawPriorityDefault),
    kMaplyVecCentered: @YES,
    kMaplyVecTexture: lineTexture,
    kMaplyWideVecJoinType:
    kMaplyWideVecMiterJoin,
    kMaplyWideVecCoordType: kMaplyWideVecCoordTypeScreen,
    kMaplyWideVecTexRepeatLen: @(100),
    kMaplyWideVecOffset:@(-10),//偏移
    kMaplyVecWidth: @(6),
    kMaplyMinVis:@(0),
    kMaplyMaxVis:@(2)}
    mode:MaplyThreadCurrent];
    [globeVC setPosition:mvObject.center];
    
    NSLog(@"%@",mvObject.attributes);
}

- (void)globeViewController:(WhirlyGlobeViewController *)viewC didStopMoving:(MaplyCoordinate *)corners userMotion:(bool)userMotion{
 
//    return;
    //The first case
    if (!self.maplyComponentObjectArray) {
        self.maplyComponentObjectArray = [NSMutableArray array];
    }
    if (self.maplyComponentObjectArray.count > 0) {
        [viewC removeObjects:self.maplyComponentObjectArray];
        [self.maplyComponentObjectArray removeAllObjects];
    }
    
    //Please try change it to 200
    int countX = 100;//200
    int countY = 100;//200

    NSMutableArray *labelArray = [NSMutableArray array];
    for (int i = 0; i < countX; i ++) {
       for (int j = 0; j < countY; j ++) {
           MaplyScreenLabel *annotationLabel = [[MaplyScreenLabel alloc] init];
           annotationLabel.text = [NSString stringWithFormat:@"%d-%d",i,j];
           annotationLabel.loc = MaplyCoordinateMakeWithDegrees(110 + i*0.5, 30 + j*0.5);
           annotationLabel.userObject = annotationLabel.text;
           [labelArray addObject:annotationLabel];
       }
    }
//    if (_compObjPointLabel) {
//        [viewC removeObject:_compObjPointLabel];
//    }
    _compObjPointLabel = [viewC addScreenLabels:labelArray desc:@{kMaplyFont: [UIFont systemFontOfSize:15],kMaplyTextColor:[UIColor blackColor]} mode:MaplyThreadAny];
    
   
    [self.maplyComponentObjectArray addObject:_compObjPointLabel];
    
//    //The second case
//    if (!self.maplyComponentObjectArray) {
//        self.maplyComponentObjectArray = [NSMutableArray array];
//    }
//    if (self.maplyComponentObjectArray.count > 0) {
//        [viewC removeObjects:self.maplyComponentObjectArray];
//    }
//    int countX = 20;
//    int countY = 20;
//
//    NSMutableArray *labelArray = [NSMutableArray array];
//    for (int i = 0; i < countX; i ++) {
//        for (int j = 0; j < countY; j ++) {
//            MaplyScreenLabel *annotationLabel = [[MaplyScreenLabel alloc] init];
//            annotationLabel.text = [NSString stringWithFormat:@"%d%d",i,j];
//            annotationLabel.loc = MaplyCoordinateMakeWithDegrees(110 + i*0.5, 30 + j*0.5);
//            [labelArray addObject:annotationLabel];
//        }
//        MaplyComponentObject *compObjPointLabel = [viewC addScreenLabels:labelArray desc:@{kMaplyFont: [UIFont systemFontOfSize:15],kMaplyTextColor:[UIColor blackColor]} mode:MaplyThreadAny];
//        [self.maplyComponentObjectArray addObject:compObjPointLabel];
//    }
}

- (void)globeViewController:(WhirlyGlobeViewController *__nonnull)viewC allSelect:(NSArray *__nonnull)selectedObjs atLoc:(MaplyCoordinate)coord onScreen:(CGPoint)screenPt{

    MaplySelectedObject *selectedObject = selectedObjs.firstObject;
    MaplyScreenLabel *selectedObj = selectedObject.selectedObj;
    
    NSLog(@"%@",selectedObj.userObject);
    
}

@end
