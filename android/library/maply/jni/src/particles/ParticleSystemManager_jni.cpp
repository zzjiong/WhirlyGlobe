/*
 *  ParticleSystemManager_jni.cpp
 *  WhirlyGlobeLib
 *
 *  Created by jmnavarro on 23/1/16.
 *  Copyright 2011-2016 mousebird consulting
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
#import "Particles_jni.h"
#import "Scene_jni.h"
#import "com_mousebird_maply_ParticleSystemManager.h"


using namespace WhirlyKit;
using namespace Maply;

template<> ParticleSystemManagerClassInfo * ParticleSystemManagerClassInfo::classInfoObj = NULL;

JNIEXPORT void JNICALL Java_com_mousebird_maply_ParticleSystemManager_nativeInit
(JNIEnv *env, jclass cls)
{
    ParticleSystemManagerClassInfo::getClassInfo(env, cls);
}

JNIEXPORT void JNICALL Java_com_mousebird_maply_ParticleSystemManager_initialize
(JNIEnv *env, jobject obj, jobject sceneObj)
{
    
    try {
        Scene *scene = SceneClassInfo::getClassInfo()->getObject(env, sceneObj);
        if (!scene)
            return;
        ParticleSystemManagerRef particleSystemManager = std::dynamic_pointer_cast<ParticleSystemManager>(scene->getManager(kWKParticleSystemManager));
        ParticleSystemManagerClassInfo::getClassInfo()->setHandle(env, obj, new ParticleSystemManagerRef(particleSystemManager));
    }
    catch (...) {
        __android_log_print(ANDROID_LOG_VERBOSE, "Maply", "Crash in ParticleSystemManager::initialise()");
    }
}

static std::mutex disposeMutex;

JNIEXPORT void JNICALL Java_com_mousebird_maply_ParticleSystemManager_dispose
(JNIEnv *env, jobject obj)
{
    try {
        ParticleSystemManagerClassInfo *classInfo = ParticleSystemManagerClassInfo::getClassInfo();
        ParticleSystemManagerRef *particleSystemManager = classInfo->getObject(env, obj);
        if (particleSystemManager)
            delete particleSystemManager;
        classInfo->clearHandle(env, obj);
    }
    catch(...) {
        __android_log_print(ANDROID_LOG_VERBOSE, "Maply", "Crash in ParticleSystemManager::dispose()");
    }
}
                                                                                              
JNIEXPORT jlong JNICALL Java_com_mousebird_maply_ParticleSystemManager_addParticleSystem
(JNIEnv *env, jobject obj, jobject parSysObj, jobject changesObj)
{
    try {
        ParticleSystemManagerClassInfo *classInfo = ParticleSystemManagerClassInfo::getClassInfo();
        ParticleSystemManagerRef *particleSystemManager = classInfo->getObject(env, obj);
        
        ParticleSystem *parSys = ParticleSystemClassInfo::getClassInfo()->getObject(env, parSysObj);
        ChangeSetRef *changes = ChangeSetClassInfo::getClassInfo()->getObject(env, changesObj);
        
        if (!particleSystemManager || !parSys || !changes)
            return EmptyIdentity;

        return (*particleSystemManager)->addParticleSystem(*parSys, *(changes->get()));
    }
    catch(...) {
        __android_log_print(ANDROID_LOG_VERBOSE, "Maply", "Crash in ParticleSystemManager::addParticleSystem");
    }
    
    return EmptyIdentity;
}
                                                                                              
JNIEXPORT void JNICALL Java_com_mousebird_maply_ParticleSystemManager_addParticleBatch
(JNIEnv *env, jobject obj, jlong id, jobject batchObj, jobject changeObj)
{
    try {
        ParticleSystemManagerClassInfo *classInfo = ParticleSystemManagerClassInfo::getClassInfo();
        ParticleSystemManagerRef *particleSystemManager = classInfo->getObject(env, obj);
        
        ParticleBatch *batch = ParticleBatchClassInfo::getClassInfo()->getObject(env, batchObj);
        ChangeSetRef *changes = ChangeSetClassInfo::getClassInfo()->getObject(env, changeObj);
        
        if (!particleSystemManager || !batch || !changes)
            return;
        
        (*particleSystemManager)->addParticleBatch(id, *batch, *(changes->get()));
    }
    catch(...) {
        __android_log_print(ANDROID_LOG_VERBOSE, "Maply", "Crash in ParticleSystemManager::addParticleBatch");
    }
}

JNIEXPORT void JNICALL Java_com_mousebird_maply_ParticleSystemManager_enableParticleSystem
(JNIEnv *env, jobject obj, jlong id, jboolean enable, jobject changeObj)
{
    try {
        ParticleSystemManagerClassInfo *classInfo = ParticleSystemManagerClassInfo::getClassInfo();
        ParticleSystemManagerRef *particleSystemManager = classInfo->getObject(env, obj);
        
        ChangeSetRef *changes = ChangeSetClassInfo::getClassInfo()->getObject(env, changeObj);
        if (!particleSystemManager || !changes)
            return;
        
        (*particleSystemManager)->enableParticleSystem(id, enable, *(changes->get()));
    }
    catch(...) {
        __android_log_print(ANDROID_LOG_VERBOSE, "Maply", "Crash in ParticleSystemManager::enableParticleSystem");
    }
}

JNIEXPORT void JNICALL Java_com_mousebird_maply_ParticleSystemManager_removeParticleSystem
(JNIEnv *env, jobject obj, jlong sysID, jobject changeObj)
{
    try {
        ParticleSystemManagerClassInfo *classInfo = ParticleSystemManagerClassInfo::getClassInfo();
        ParticleSystemManagerRef *particleSystemManager = classInfo->getObject(env, obj);
        
        ChangeSetRef *changes = ChangeSetClassInfo::getClassInfo()->getObject(env, changeObj);
        if (!particleSystemManager || !changes)
            return;
        (*particleSystemManager)->removeParticleSystem(sysID, *(changes->get()));
    }
    catch(...) {
        __android_log_print(ANDROID_LOG_VERBOSE, "Maply", "Crash in ParticleSystemManager::removeParticleSystems");
    }
}

                                                                                              
