/*
*  DrawableMTL.h
*  WhirlyGlobeLib
*
*  Created by Steve Gifford on 9/30/19.
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

#import "Drawable.h"
#import "SceneRendererMTL.h"

namespace WhirlyKit
{

// Block of data to be passed into a given buffer ID
// We do this rather than setting individual uniforms
class UniformBlockMTL
{
public:
    int bufferID;
    RawDataRef blockData;
};

// Resources we need for a given render (buffers, textures, etc..)
class ResourceRefsMTL {
public:
    void addBuffer(id<MTLBuffer> buffer);
    void addTexture(id<MTLTexture> texture);
    
    // Wire up the resources listed
    void use(id<MTLRenderCommandEncoder> cmdEncode);
    
protected:
    std::set< id<MTLBuffer> > buffers;
    std::set< id<MTLTexture> > textures;
};

/**
   Used to track the contents of an argument buffer.
 Includes the buffers we set up to track things.
 */
class ArgBuffContentsMTL {
public:
    // Set up the buffers corresponding to the various entries
    ArgBuffContentsMTL(id<MTLDevice> mtlDevice,
                       id<MTLFunction> func,
                       int bufferArgIdx);
    
    // Create empty buffers for the various entries we don't have yet
    void createBuffers(id<MTLDevice> mtlDevice);
    
    // True if this argument buffer has the given entry
    bool hasEntry(int entryID);
    
    // Copy in the buffer contents for the given entry
    void updateEntry(id<MTLDevice> mtlDevice,
                     id<MTLBlitCommandEncoder> blitEncode,
                     int entryID,
                     void *rawData,size_t size);
    
    // Set the buffer for a specific entry
    void setEntry(int entryID,id<MTLBuffer> buffer);
    
    // Clear the MTLTextures we're holding
    void clearTextures();
    
    // Use the encode to directly set a texture
    void setTexture(int texIndex,id<MTLTexture> tex);
    
    // Add the resources we're using to the list
    void addResources(ResourceRefsMTL &resources);
    
    // Return the buffer created for the argument buffer
    id<MTLBuffer> getBuffer();
        
    // False if this failed to set up correctly
    bool isValid();
    
protected:
    bool valid;
    
    // Single entry (for a buffer) in the argument buffer
    typedef struct {
        int entryID;
        size_t size;
        id<MTLBuffer> buff;  // Buffer we created to store the data
        int offset;
    } Entry;
    typedef std::shared_ptr<Entry> EntryRef;
        
    // Textures indices and textures we've seen
    std::map<int,id<MTLTexture> > textures;
    
    // Buffer that contains the argument buffer
    id<MTLBuffer> buff;
    
    // Used to encode everything initially and then textures later
    id<MTLArgumentEncoder> encode;
    
    // Individual entries (by ID) in the argument buffer
    std::map<int,EntryRef> entries;
};
typedef std::shared_ptr<ArgBuffContentsMTL> ArgBuffContentsMTLRef;

/**
    Metal version of drawable doesn't draw, so much as encode.
 */
class DrawableMTL : virtual public Drawable
{
public:
    EIGEN_MAKE_ALIGNED_OPERATOR_NEW;
        
    // An all-purpose pre-render that sets up textures, uniforms and such in preparation for rendering
    // Also adds to the list of resources being used by this drawable
    virtual void preProcess(RendererFrameInfoMTL *frameInfo,
                    id<MTLCommandBuffer> cmdBuff,
                    id<MTLBlitCommandEncoder> bltEncode,
                    Scene *inScene,
                    ResourceRefsMTL &resources) = 0;

    /// Fill this in to draw the basic drawable
    virtual void draw(RendererFrameInfoMTL *frameInfo,id<MTLRenderCommandEncoder> cmdEncode,Scene *scene) = 0;

    /// Some drawables have a pre-render phase that uses the GPU for calculation
    virtual void calculate(RendererFrameInfoMTL *frameInfo,id<MTLRenderCommandEncoder> cmdEncode,Scene *scene) = 0;
};

}
