/*  GLUtils.cpp
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford on 3/21/11.
 *  Copyright 2011-2021 mousebird consulting
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
 */

#import <stdio.h>
#import "UtilsGLES.h"
#import "WhirlyKitLog.h"

// Turn this off for a little performance gain
#if DEBUG || __ANDROID__
static bool ErrorsOn = true;
#else
static bool ErrorsOn = false;
#endif
bool CheckGLError(const char *msg)
{
    if (ErrorsOn)
    {
        const GLenum theError = glGetError();
        if (theError != GL_NO_ERROR)
        {
#if defined(EGL_VERSION_1_4)
            wkLogLevel(Error, "GL Error: 0x%x - %s (ctx: %x)", theError, msg, eglGetCurrentContext());
#else
            wkLogLevel(Error, "GL Error: 0x%x - %s", theError, msg);
#endif
            return false;
        }
    }
    return true;
}
