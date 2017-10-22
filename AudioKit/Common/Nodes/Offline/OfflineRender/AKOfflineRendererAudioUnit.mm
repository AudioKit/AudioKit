//
//  AKOfflineRenderAudioUnit.m
//  AudioKit
//
//  Created by David O'Neill on 8/7/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKOfflineRenderAudioUnit.h"
#import <algorithm>
#import "BufferedAudioBus.hpp"
#import <AudioKit/AudioKit-Swift.h>
#import <pthread.h>

typedef struct {
    AURenderPullInputBlock pullInputBlock;
}RenderPull;

typedef BOOL(^SimpleRenderBlock)(AudioBufferList *bufferList, AVAudioFrameCount frames, NSError **outError);

@implementation AKOfflineRenderAudioUnit {
    BufferedInputBus _inputBus;
    AVAudioPCMBuffer *silentBuffer;
    RenderPull renderPull;
    pthread_mutex_t renderLock;
}
@synthesize parameterTree = _parameterTree;

- (void)createParameters {
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate channels:AKSettings.numberOfChannels];
    _inputBus.init(self.defaultFormat, 8);
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeInput busses:@[_inputBus.bus]];
    _parameterTree = [AUParameterTree tree:@[]];
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return false;
    }
    renderPull.pullInputBlock = nil;
    _internalRenderEnabled = true;
    
    if (self.outputBus.format.channelCount != _inputBus.bus.format.channelCount) {
        self.renderResourcesAllocated = false;
        return [AKOfflineRenderAudioUnit outError:outError withDomain:NSOSStatusErrorDomain code:kAudioUnitErr_FailedInitialization
                                      description:@"AKOfflineRenderAudioUnit self.outputBus.format.channelCount != _inputBus.bus.format.channelCount"];
    }
    pthread_mutex_init(&renderLock, nil);
    _inputBus.allocateRenderResources(self.maximumFramesToRender);
    silentBuffer = [[AVAudioPCMBuffer alloc]initWithPCMFormat:self.defaultFormat frameCapacity:self.maximumFramesToRender];
    
    return true;
}

- (void)deallocateRenderResources {
    [super deallocateRenderResources];
    _inputBus.deallocateRenderResources();
}
-(BOOL)renderToFile:(NSURL * _Nonnull)fileURL
            seconds:(double)seconds
           settings:(NSDictionary<NSString *, id> * _Nullable)settings
              error:(NSError * _Nullable * _Nullable)outError{
    
    if (!settings) {
        NSString *extension = fileURL.pathExtension.lowercaseString;
        if ([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"m4a"]) {
            settings = @{AVFormatIDKey:             @(kAudioFormatMPEG4AAC),
                         AVNumberOfChannelsKey:     @(self.defaultFormat.channelCount),
                         AVSampleRateKey:           @(self.defaultFormat.sampleRate)};
        } else {
            NSMutableDictionary *fixedSettings = AudioKit.format.settings.mutableCopy;
            fixedSettings[AVLinearPCMIsNonInterleaved] = @(false);
            settings = fixedSettings;
        }
    }
    if(![AKOfflineRenderAudioUnit checkSeconds:seconds error:outError]) {
        return false;
    }
    AURenderPullInputBlock pullInputBlock = [self getPullInputBlock:outError];
    if (!pullInputBlock) {
        return false;
    }
    
    AVAudioFile *audioFile = [[AVAudioFile alloc]initForWriting:fileURL
                                                       settings:settings
                                                   commonFormat:self.defaultFormat.commonFormat
                                                    interleaved:self.defaultFormat.interleaved
                                                          error:outError];
    
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc]initWithPCMFormat:self.defaultFormat frameCapacity:self.maximumFramesToRender];
    int bytesPerFrame = self.defaultFormat.streamDescription->mBytesPerFrame;
    
    return [self render:round(seconds * self.defaultFormat.sampleRate)
         pullInputBlock:pullInputBlock
            renderBlock:^BOOL(AudioBufferList *bufferList, AVAudioFrameCount frames, NSError **outError) {
                AudioBufferList *outBufferlist = buffer.mutableAudioBufferList;
                for (int i = 0; i < bufferList->mNumberBuffers; i++) {
                    memcpy(outBufferlist->mBuffers[i].mData, bufferList->mBuffers[i].mData, bytesPerFrame * frames);
                }
                buffer.frameLength = frames;
                return [audioFile writeFromBuffer:buffer error:outError];
            } error:outError];
    
}


-(AVAudioPCMBuffer * _Nullable)renderToBuffer:(NSTimeInterval)seconds error:(NSError *_Nullable*__null_unspecified)outError{
    if (![AKOfflineRenderAudioUnit checkSeconds:seconds error:outError]) {
        return nil;
    }
    AURenderPullInputBlock pullInputBlock = [self getPullInputBlock:outError];
    if (!pullInputBlock) {
        return nil;
    }
    
    UInt32 frameCount = round(seconds * self.defaultFormat.sampleRate);
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc]initWithPCMFormat:self.defaultFormat frameCapacity:frameCount];
    
    if (!buffer) {
        [AKOfflineRenderAudioUnit outError:outError withDomain:@"AKOfflineRenderAudioUnit" code:1
                               description:@"renderToBuffer couldn't create buffer"];
        return nil;
    }
    
    __block UInt32 offset = 0;
    UInt32 bytesPerFrame = self.defaultFormat.streamDescription->mBytesPerFrame;
    BOOL success = [self render:frameCount pullInputBlock:pullInputBlock renderBlock:^BOOL(AudioBufferList *bufferList, AVAudioFrameCount frames, NSError **outError) {
        AudioBufferList *mutableBufferlist = buffer.mutableAudioBufferList;
        UInt32 byteOffset = offset * bytesPerFrame;
        for (int i = 0; i < bufferList->mNumberBuffers; i++) {
            char *dst = (char *)mutableBufferlist->mBuffers[i].mData;
            memcpy(dst + byteOffset, bufferList->mBuffers[i].mData, frames * bytesPerFrame);
        }
        offset += frames;
        return true;
    } error:outError];
    
    if (!success) {
        return nil;
    }
    buffer.frameLength = offset;
    return buffer;
}

//renderBlock expects a return value of true for success and false for failure.
-(BOOL)render:(UInt32)sampleCount pullInputBlock:(AURenderPullInputBlock)pullInputBlock renderBlock:(SimpleRenderBlock)renderBlock error:(NSError **)outError{
    if (!sampleCount) {
        return [AKOfflineRenderAudioUnit outError:outError withDomain:@"AKOfflineRenderAudioUnit" code:1
                                      description:@"Can't render <= 0 seconds"];
    }
    if(!pullInputBlock || !renderBlock) {
        return [AKOfflineRenderAudioUnit outError:outError withDomain:@"AKOfflineRenderAudioUnit" code:1
                                      description:@"AKOfflineRenderAudioUnit.render !pullInputBlock || !renderBlock"];
    }
    
    AudioTimeStamp ts = {0};
    ts.mFlags = kAudioTimeStampSampleHostTimeValid;
    
    int samplesRemaining = sampleCount;
    int maxBufferLen = 1024;
    
    pthread_mutex_lock(&renderLock);
    while (samplesRemaining) {
        
        int renderLen = MIN(maxBufferLen,samplesRemaining);
        
        AudioUnitRenderActionFlags pullFlags = 0;
        AUAudioUnitStatus status = _inputBus.pullInput(&pullFlags, &ts, renderLen, 0, pullInputBlock);
        
        if (status) {
            pthread_mutex_unlock(&renderLock);
            return [AKOfflineRenderAudioUnit outError:outError withDomain:NSOSStatusErrorDomain code:status
                                          description:@"Cached pullInputBlock failed"];
        }
        //renderblock can set error out
        if (!renderBlock(_inputBus.mutableAudioBufferList,renderLen,outError)) {
            pthread_mutex_unlock(&renderLock);
            return false;
        }
        
        ts.mSampleTime += renderLen;
        samplesRemaining -= renderLen;
    }
    pthread_mutex_unlock(&renderLock);
    return true;
}

- (AUInternalRenderBlock)internalRenderBlock {
    BufferedInputBus *input = &_inputBus;
    RenderPull *renderPullCapture = &renderPull;
    BOOL *internalRenderEnabled = &_internalRenderEnabled;
    pthread_mutex_t *lock = &renderLock;
    AudioBufferList *silentBufferList = silentBuffer.mutableAudioBufferList;
    
    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        
        //Cache the pullInputBlock so that it can be used for offline render
        if (!renderPullCapture->pullInputBlock) {
            renderPullCapture->pullInputBlock = pullInputBlock;
        }
        
        AudioBufferList *outAudioBufferList = outputData;
        
        //Ouptut silence using silentBufferList if performing an offline render, or if internalRenderEnabled == false.  pullInput not called.
        BOOL renderDisabled = !*internalRenderEnabled;
        BOOL lockSuccessful = false;
        
        if (!renderDisabled) {
            lockSuccessful = pthread_mutex_trylock(lock) == 0;
        }
        if (renderDisabled || !lockSuccessful) {
            if (outAudioBufferList->mBuffers[0].mData == nullptr) {
                for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
                    memset(silentBufferList->mBuffers[i].mData, 0, silentBufferList->mBuffers[i].mDataByteSize);
                    outAudioBufferList->mBuffers[i].mData = silentBufferList->mBuffers[i].mData;
                }
            }
            if (lockSuccessful) {
                pthread_mutex_unlock(lock);
            }
            return noErr;
        }
        
        //This is just a passthrough, save some cycles by bypassing when not rendering.
        AudioUnitRenderActionFlags pullFlags = 0;
        AUAudioUnitStatus err = input->pullInput(&pullFlags, timestamp, frameCount, 0, pullInputBlock);
        if (err) {
            pthread_mutex_unlock(lock);
            return err;
        }
        
        //No need to copy if using own buffers
        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList;
        if (outAudioBufferList->mBuffers[0].mData == nullptr) {
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData;
            }
        } else {
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
                memcpy(outputData->mBuffers[i].mData, inAudioBufferList->mBuffers[i].mData, inAudioBufferList->mBuffers[i].mDataByteSize);
            }
        }
        
        pthread_mutex_unlock(lock);
        return noErr;
    }; 
}
-(AVAudioFormat *)defaultFileFormat{
    return [[AVAudioFormat alloc]initWithCommonFormat:AVAudioPCMFormatInt16 sampleRate:44100.0 channels:self.defaultFormat.channelCount interleaved:true];
}

-(AURenderPullInputBlock)getPullInputBlock:(NSError **)outError{
    int tries = 0;
    AURenderPullInputBlock pullInputBlock = renderPull.pullInputBlock;
    while (!pullInputBlock) {
        usleep((self.maximumFramesToRender / self.defaultFormat.sampleRate) * 1000000);
        if (tries >= 3) {
            [AKOfflineRenderAudioUnit outError:outError withDomain:@"AKOfflineRenderAudioUnit" code:1
                                   description:@"Node needs to be connected and engine needs to be running"];
            return nil;
        }
        tries ++;
        pullInputBlock = renderPull.pullInputBlock;
    }
    return pullInputBlock;
}
+(BOOL)outError:(NSError **)error withDomain:(NSString *)domain code:(int)code description:(NSString *)description{
    if (error) {
        *error = [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:description}];
    }
    return false;
}
+(BOOL)checkSeconds:(double)seconds error:(NSError **)outError{
    if (seconds <= 0) {
        return [AKOfflineRenderAudioUnit outError:outError withDomain:@"AKOfflineRenderAudioUnit" code:1
                                      description:@"Can't render <= 0 seconds"];
    }
    return true;
}
@end
