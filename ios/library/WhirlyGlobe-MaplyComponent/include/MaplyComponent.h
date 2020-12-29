/*
 *  MaplyComponent.h
 *  MaplyComponent
 *
 *  Created by Steve Gifford on 9/6/12.
 *  Copyright 2012-2019 mousebird consulting
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

#import "MaplySharedAttributes.h"

//#import "NSData+Zlib.h"
//#import "NSDictionary+StyleRules.h"
//
//#import "MaplyGeomBuilder.h"
//#import "MaplyIconManager.h"
//#import "MaplyLocationTracker.h"
//#import "MaplyTextureBuilder.h"
//
//#import "MaplyCoordinate.h"
//#import "MaplyCoordinateSystem.h"
//#import "MaplyMatrix.h"
//#import "WGCoordinate.h"
//
//#import "MaplyActiveObject.h"
//#import "MaplyAnnotation.h"
//#import "MaplyRenderController.h"
//#import "MaplyUpdateLayer.h"
//#import "MaplyViewTracker.h"
//#import "MaplyControllerLayer.h"
//#import "MaplyViewController.h"
//#import "MaplyBaseViewController.h"
////#import "MaplyGlobeRenderController"
////#import "MaplyViewController"
//
//#import "MaplyComponentObject.h"
//#import "MaplyBillboard.h"
//#import "MaplyCluster.h"
//#import "MaplyLabel.h"
//#import "MaplyGeomModel.h"
//#import "MaplyMarker.h"
//#import "MaplyMoon.h"
//#import "MaplyParticleSystem.h"
//#import "MaplyPoints.h"
//#import "MaplySticker.h"
//#import "MaplyShape.h"
//#import "MaplyScreenLabel.h"
//#import "MaplySun.h"
//#import "MaplyScreenObject.h"
//#import "MaplyScreenMarker.h"
//#import "MaplyStarsModel.h"
//#import "MaplyTexture.h"
//#import "MaplyVectorObject.h"
//
//#import "MapboxVectorTiles.h"
//#import "MapboxVectorInterpreter.h"
//
//#import "SLDStyleSet.h"
//#import "SLDExpressions.h"
//#import "SLDOperators.h"
//#import "SLDSymbolizers.h"
//#import "SLDWellKnownMarkers.h"
//#import "MaplyVectorStyle.h"
//#import "MaplyVectorStyleSimple.h"
//#import "MaplyVectorTileLineStyle.h"
//#import "MaplyVectorTileMarkerStyle.h"
//#import "MaplyVectorTilePolygonStyle.h"
//#import "MaplyVectorTileStyle.h"
//#import "MaplyVectorTileTextStyle.h"
//#import "MapboxVectorStyleSet.h"
//#import "MapnikStyle.h"
//#import "MapnikStyleRule.h"
//#import "MapnikStyleSet.h"
//
//#import "MaplyQuadLoader.h"
//#import "MaplyImageTile.h"
//#import "MaplyQuadImageLoader.h"
//#import "MaplyQuadImageFrameLoader.h"
//#import "MaplyQuadPagingLoader.h"
//#import "MaplyTileSourceNew.h"
//#import "MaplySimpleTileFetcher.h"
//#import "MaplyQuadSampler.h"
//#import "MaplyRemoteTileFetcher.h"
//#import "GeoJSONSource.h"
//
//#import "MaplyWMSTileSource.h"
//#import "MaplyMBTileFetcher.h"
//
//#import "MaplyVariableTarget.h"
//#import "MaplyAtmosphere.h"
//#import "MaplyColorRampGenerator.h"
//#import "MaplyLight.h"
//#import "MaplyRenderTarget.h"
//#import "MaplyShader.h"
//#import "MaplyVertexAttribute.h"

#import "UIKit/NSData+Zlib.h"
#import "UIKit/NSDictionary+StyleRules.h"

#import "helpers/MaplyGeomBuilder.h"
#import "helpers/MaplyIconManager.h"
#import "helpers/MaplyLocationTracker.h"
#import "helpers/MaplyTextureBuilder.h"

#import "math/MaplyCoordinate.h"
#import "math/MaplyCoordinateSystem.h"
#import "math/MaplyMatrix.h"

#import "control/MaplyActiveObject.h"
#import "control/MaplyAnnotation.h"
#import "control/MaplyRenderController.h"
#import "control/MaplyUpdateLayer.h"
#import "control/MaplyViewTracker.h"
#import "control/MaplyControllerLayer.h"
#import "control/MaplyViewController.h"
#import "control/MaplyBaseViewController.h"

#import "visual_objects/MaplyComponentObject.h"
#import "visual_objects/MaplyBillboard.h"
#import "visual_objects/MaplyCluster.h"
#import "visual_objects/MaplyLabel.h"
#import "visual_objects/MaplyGeomModel.h"
#import "visual_objects/MaplyMarker.h"
#import "visual_objects/MaplyMoon.h"
#import "visual_objects/MaplyParticleSystem.h"
#import "visual_objects/MaplyPoints.h"
#import "visual_objects/MaplySticker.h"
#import "visual_objects/MaplyShape.h"
#import "visual_objects/MaplyScreenLabel.h"
#import "visual_objects/MaplySun.h"
#import "visual_objects/MaplyScreenObject.h"
#import "visual_objects/MaplyScreenMarker.h"
#import "visual_objects/MaplyStarsModel.h"
#import "visual_objects/MaplyTexture.h"
#import "visual_objects/MaplyVectorObject.h"

#import "vector_tiles/MapboxVectorTiles.h"
#import "vector_tiles/MapboxVectorInterpreter.h"

#import "vector_styles/SLDStyleSet.h"
#import "vector_styles/SLDExpressions.h"
#import "vector_styles/SLDOperators.h"
#import "vector_styles/SLDSymbolizers.h"
#import "vector_styles/SLDWellKnownMarkers.h"
#import "vector_styles/MaplyVectorStyle.h"
#import "vector_styles/MaplyVectorStyleSimple.h"
#import "vector_styles/MaplyVectorTileLineStyle.h"
#import "vector_styles/MaplyVectorTileMarkerStyle.h"
#import "vector_styles/MaplyVectorTilePolygonStyle.h"
#import "vector_styles/MaplyVectorTileStyle.h"
#import "vector_styles/MaplyVectorTileTextStyle.h"
#import "vector_styles/MapboxVectorStyleSet.h"
#import "vector_styles/MapnikStyle.h"
#import "vector_styles/MapnikStyleRule.h"
#import "vector_styles/MapnikStyleSet.h"

#import "loading/MaplyQuadLoader.h"
#import "loading/MaplyImageTile.h"
#import "loading/MaplyQuadImageLoader.h"
#import "loading/MaplyQuadImageFrameLoader.h"
#import "loading/MaplyQuadPagingLoader.h"
#import "loading/MaplyTileSourceNew.h"
#import "loading/MaplySimpleTileFetcher.h"
#import "loading/MaplyQuadSampler.h"
#import "loading/MaplyRemoteTileFetcher.h"
#import "loading/GeoJSONSource.h"

#import "data_sources/MaplyWMSTileSource.h"
#import "data_sources/MaplyMBTileFetcher.h"

#import "rendering/MaplyVariableTarget.h"
#import "rendering/MaplyAtmosphere.h"
#import "rendering/MaplyColorRampGenerator.h"
#import "rendering/MaplyLight.h"
#import "rendering/MaplyRenderTarget.h"
#import "rendering/MaplyShader.h"
#import "rendering/MaplyVertexAttribute.h"
