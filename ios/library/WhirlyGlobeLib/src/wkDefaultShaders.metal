/*
 *  wkDefaultShaders.metal
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford on 5/16/19.
 *  Copyright 2011-2019 mousebird consulting
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

#include <metal_stdlib>
using namespace metal;

// Vertices with position, color, and normal
struct VertexA
{
    float3 position [[attribute(0)]];
    float4 color [[attribute(1)]];
    float3 normal [[attribute(2)]];
};

// Uniforms for the basic case.  Nothing fancy.
struct UniformsA
{
    float4x4 mvpMatrix;
    float4x4 mvMatrix;
    float4x4 mvNormalMatrix;
    float fade;
};

// Position, color, and dot project (for backface checking)
struct ProjVertexA
{
    float4 position [[position]];
    float4 color;
    float dotProd;
};

// Vertex shader for simple line on the globe
vertex ProjVertexA vertexLineOnly_globe(
    VertexA vert [[stage_in]],
    constant UniformsA &uniforms [[buffer(1)]])
{
    ProjVertexA outVert;
    
    float4 pt = uniforms.mvMatrix * float4(vert.position, 1.0);
    pt /= pt.w;
    float4 testNorm = uniforms.mvNormalMatrix * float4(vert.normal,0.0);
    outVert.dotProd = dot(-pt.xyz,testNorm.xyz);
    outVert.color = vert.color * uniforms.fade;
    outVert.position = uniforms.mvpMatrix * float4(vert.position,1.0);
    
    return outVert;
}

// Fragment shader for simple line case
fragment float4 framentLineOnly_globe(
    ProjVertexA in [[stage_in]])
{
    if (in.dotProd <= 0.0)
        discard_fragment();
    return in.color;
}

// Just position and color
struct ProjVertexB
{
    float4 position [[position]];
    float4 color;
};

// Vertex shader for simple line on the flat map (no backface checking)
vertex ProjVertexB vertexLineOnly_flat(
    VertexA vert [[stage_in]],
    constant UniformsA &uniforms [[buffer(1)]])
{
    ProjVertexB outVert;
    
    outVert.color = vert.color * uniforms.fade;
    outVert.position = uniforms.mvpMatrix * float4(vert.position,1.0);
    
    return outVert;
}

// Simple fragment shader for lines on flat map
fragment float4 fragmentLineOnly_flat(
    ProjVertexB vert [[stage_in]],
    constant UniformsA &uniforms [[buffer(1)]])
{
    return vert.color;
}


//// Lighting support //////

// A single light
struct Light {
    float3 direction;
    float3 halfPlane;
    float4 ambient;
    float4 diffuse;
    float4 specular;
    float viewDepend;
};

// Material definition
struct Material {
    float4 ambient;
    float4 diffuse;
    float4 specular;
    float specularExponent;
};

// Lighting together in one struct
struct Lighting {
    int numLights;
    Light lights[8];
    Material mat;
};

// General purpose uniforms for these shaders
struct UniformsTri {
    float4x4 mvpMatrix;
    float4x4 mvMatrix;
    float4x4 mvNormalMatrix;
    float fade;
};

// Texture lookup indirection
// Used for treating one textures coordinates as coordinates in the parent
struct TexIndirect {
    float2 offset;
    float2 scale;
};

// Ye olde triangle vertex
struct VertexTriA
{
    float3 position [[attribute(0)]];
    float4 color [[attribute(1)]];
    float3 normal [[attribute(2)]];
    float2 texCoord [[attribute(3)]];
};

// Output vertex to the fragment shader
struct ProjVertexTriA {
    float4 position [[position]];
    float4 color;
    float2 texCoord;
};

// Resolve texture coordinates with their parent offsts, if necessary
float2 resolveTexCoords(const float2 &texCoord,constant TexIndirect &texIndr)
{
    if (texIndr.scale.x == 0.0)
        return texCoord;
    
    return texCoord * texIndr.scale + texIndr.offset;
}

// Calculate lighting for the given position and normal
float4 resolveLighting(const float4 &pos,const float4 &norm,const float4 color,
                       constant Lighting &lighting,constant UniformsTri &uniforms)
{
    float4 ambient(0.0,0.0,0.0,0.0);
    float4 diffuse(0.0,0.0,0.0,0.0);

    for (int ii=0;ii<lighting.numLights;ii++) {
        constant Light &light = lighting.lights[ii];
        float3 adjNorm = light.viewDepend > 0.0 ? normalize((uniforms.mvpMatrix * float4(norm.xyz, 0.0)).xyz) : norm.xzy;
        float ndotl;
        //"        float ndoth;
        ndotl = max(0.0, dot(adjNorm, light.direction));
        //"        ndotl = pow(ndotl,0.5);
        //"        ndoth = max(0.0, dot(adjNorm, light[ii].halfplane));
        ambient += light.ambient;
        diffuse += ndotl * light.diffuse;
    }
    
    return float4(ambient.xyz * lighting.mat.ambient.xyz * color.xyz + diffuse.xyz * color.xyz,1.0);
}

// Simple vertex shader for triangle with no lighting
vertex ProjVertexTriA vertexTri_noLight(VertexTriA vert [[stage_in]],
                                        constant UniformsTri &uniforms [[buffer(1)]],
                                        constant Lighting &lighting [[buffer(2)]],
                                        constant TexIndirect &texIndirect [[buffer(3)]])
{
    ProjVertexTriA outVert;
    
    outVert.position = uniforms.mvpMatrix * float4(vert.position,1.0);
    outVert.color = vert.color * uniforms.fade;
    outVert.texCoord = resolveTexCoords(vert.texCoord,texIndirect);
    
    return outVert;
}

// Simple fragment shader for lines on flat map
fragment float4 fragmentTri_noLight(ProjVertexTriA vert [[stage_in]],
                                      constant UniformsTri &uniforms [[buffer(1)]],
                                      texture2d<float,access::sample> tex [[texture(0)]]
                                      )
{
    constexpr sampler sampler2d(coord::normalized, filter::linear);

    return vert.color * tex.sample(sampler2d, vert.texCoord);
}
