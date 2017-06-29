//
//  AKFilePlayerDSPKernel.hpp
//  AudioKit For iOS
//
//  Created by Bang Means Do It on 28/03/2017.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once
#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import "TPCircularBuffer.h"

#import <AudioKit/AudioKit-Swift.h>
#include <vector>

enum {
    FilePlaybackParameterIsPlaying = 0,
    FilePlaybackParameterIsMuted,
    FilePlaybackParameterLoopStart,
    FilePlaybackParameterLoopEnd,
    FilePlaybackParameterEnqueuedLoopStart,
    FilePlaybackParameterEnqueuedLoopEnd
};


class AKFilePlayerDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    typedef std::function<void(void)> SectionEndReachedCallback;
    typedef std::function<void(float currentTime)> CurrentTimeUpdatedCallback;
    
    struct File {
        CFURLRef fileURL;
        ExtAudioFileRef audioFile;
        AudioStreamBasicDescription audioStreamBasicDescription;
        BOOL isFillingBuffer = NO;
        SInt64 fileLengthInFrames = 0;
        
        // Share a single queue for all file buffers
        __strong dispatch_queue_t bufferFillingQueue = dispatch_queue_create("BufferedFilePlaybackDSPKernelQueue", DISPATCH_QUEUE_SERIAL);
    };
    
    // MARK: Member Functions
    AKFilePlayerDSPKernel() {}
    
    // MARK: - Lifecycle
    void init(int inChannelCount, double inSampleRate) override {
        // Parameters
        channelCount = inChannelCount;
        sampleRate = inSampleRate;
        
        // Circular Buffer
        TPCircularBufferInit(&cBuffer, cBufferLength);
    }
    
    void setURL(CFURLRef inFileURL) {
        dispatch_async(file.bufferFillingQueue, ^{
            // File
            file.fileURL = inFileURL;
            
            // Open the file
            setUpAudioFile();
            
            loopEnd = (int32_t)file.fileLengthInFrames;
            realTimeLoopEnd = loopEnd;
        });
    }
    
    // AKAudioUnit - Standard Setup
    // Start and stop
    void start() {
        dispatch_async(file.bufferFillingQueue, ^{
            OSStatus status = ExtAudioFileSeek(file.audioFile, loopStart + sampleTimeStartOffset);
            assert(status == noErr); // Error reading audio file
            
            sampleTimeReadFrame = loopStart + sampleTimeStartOffset;
            realTimeReadFrame = sampleTimeReadFrame;
            
            hasDelayedStart = false;
            
            isPlaying = true;
            fillCircularBuffer();
        });
    }
    
    void stop() {
        isPlaying = false;
        
        reset();
    }
    
    void destroy() {
        isPlaying = false;
        
        dispatch_async(file.bufferFillingQueue, ^{
            TPCircularBufferClear(&cBuffer);
            TPCircularBufferCleanup(&cBuffer);
            
            ExtAudioFileDispose(file.audioFile);
        });
    }
    
    void reset() {
        dispatch_async(file.bufferFillingQueue, ^{
            isPlaying = false;
            
            // Reset DSP here
            TPCircularBufferClear(&cBuffer);
        });
    }
    
    void prepareToPlay() {
        reset();
    }
    
    void prepareForOfflineRender() {
        reset();
        start();
    }
    
    // MARK :- Setup
    void setUpAudioFile() {
        // Open the audio file
        OSStatus status;
        status = ExtAudioFileOpenURL(file.fileURL, &file.audioFile);
        assert(status == noErr); // Error opening file
        
        status = ExtAudioFileSeek(file.audioFile, 0);
        assert(status == noErr); // Error seeking file
        
        // Get file data format
        UInt32 size = sizeof(file.audioStreamBasicDescription);
        status = ExtAudioFileGetProperty(file.audioFile, kExtAudioFileProperty_FileDataFormat, &size, &file.audioStreamBasicDescription);
        assert(status == noErr); // Error reading file format
        
        // Apply client data format
        const int eight_bits_per_byte = 8;
        const int size_of_data_type_in_bytes = sizeof(float);
        
        // Create the client stream format
        clientAudioStreamBasicDescription.mSampleRate = sampleRate;
        clientAudioStreamBasicDescription.mFormatID = kAudioFormatLinearPCM;
        clientAudioStreamBasicDescription.mFormatFlags = kLinearPCMFormatFlagIsFloat;
        clientAudioStreamBasicDescription.mBitsPerChannel = size_of_data_type_in_bytes * eight_bits_per_byte;
        clientAudioStreamBasicDescription.mChannelsPerFrame = channelCount;
        clientAudioStreamBasicDescription.mBytesPerFrame = clientAudioStreamBasicDescription.mChannelsPerFrame * size_of_data_type_in_bytes;
        clientAudioStreamBasicDescription.mFramesPerPacket = 1;
        clientAudioStreamBasicDescription.mBytesPerPacket = clientAudioStreamBasicDescription.mFramesPerPacket * clientAudioStreamBasicDescription.mBytesPerFrame;
        
        size = sizeof(clientAudioStreamBasicDescription);
        status = ExtAudioFileSetProperty(file.audioFile, kExtAudioFileProperty_ClientDataFormat, size, &clientAudioStreamBasicDescription);
        assert(status == noErr); // Error setting file format
        
        // Get length of audio file in frames
        size = sizeof(file.fileLengthInFrames);
        status = ExtAudioFileGetProperty(file.audioFile, kExtAudioFileProperty_FileLengthFrames, &size, &file.fileLengthInFrames);
        assert(status == noErr); // Error getting file frame length
    }
    
    void setSampleTimeStartOffset(int32_t offset) {
        sampleTimeStartOffset = offset;
    }
    
    void setSampleTimeDelayOffset(int32_t offset) {
        sampleTimeDelayOffset = offset;
    }
    
    void prepareToPlay(int32_t readHeadPosition) {
        if (readHeadPosition > -1) {
            // Reset read position
            OSStatus status = ExtAudioFileSeek(file.audioFile, readHeadPosition);
            assert(status == noErr); // Error reading audio file
            
            sampleTimeReadFrame = readHeadPosition;
            realTimeLoopEnd = loopEnd;
        }
        
        fillCircularBuffer();
    }
    
    // MARK: - Info
    int32_t currentPlayheadPosition() {
        return sampleTimeReadFrame;
    }
    
    SInt64 fileLengthInFrames() {
        return file.fileLengthInFrames;
    }
    
    float fileLengthInSeconds() {
        return file.fileLengthInFrames / sampleRate;
    }
    
    // MARK: - Callback
    void setCurrentTimeUpdatedCallback(CurrentTimeUpdatedCallback callback) {
        currentTimeUpdatedCallback = callback;
    }
    
    void setSectionEndReachedCallback(SectionEndReachedCallback callback) {
        sectionEndReachedCallback = callback;
    }
    
    // MARK: - Parameters and parameter ramps
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case FilePlaybackParameterIsPlaying:
                isPlaying = (bool)value;
                break;
                
            case FilePlaybackParameterIsMuted:
                isMuted = (bool)value;
                break;
                
            case FilePlaybackParameterLoopStart: {
                int32_t newValue = file.audioStreamBasicDescription.mSampleRate * value;
                if(newValue < file.fileLengthInFrames) {
                    loopStart = newValue;
                } else {
                    loopStart = 0;
                }
                
                if(isPlaying == false) {
                    sampleTimeReadFrame = loopStart;
                    ExtAudioFileSeek(file.audioFile, loopStart);
                }
                
                break;
            }
            case FilePlaybackParameterLoopEnd: {
                int32_t newValue = file.audioStreamBasicDescription.mSampleRate * value;
                if(newValue < file.fileLengthInFrames &&
                   newValue > loopStart) {
                    loopEnd = newValue;
                    realTimeLoopEnd = loopEnd;
                } else {
                    loopEnd = (int32_t)file.fileLengthInFrames;
                }
                break;
            }
            case FilePlaybackParameterEnqueuedLoopStart: {
                int32_t newValue = file.audioStreamBasicDescription.mSampleRate * value;
                if(newValue < file.fileLengthInFrames) {
                    enqueuedLoopStart = newValue;
                } else {
                    enqueuedLoopStart = NoEnqueuedLoopPoint;
                }
                
                if(isPlaying == false) {
                    sampleTimeReadFrame = enqueuedLoopStart;
                    ExtAudioFileSeek(file.audioFile, loopStart);
                }
                
                break;
            }
            case FilePlaybackParameterEnqueuedLoopEnd: {
                int32_t newValue = file.audioStreamBasicDescription.mSampleRate * value;
                if(newValue < file.fileLengthInFrames &&
                   newValue > enqueuedLoopStart) {
                    enqueuedLoopEnd = newValue;
                } else {
                    enqueuedLoopEnd = NoEnqueuedLoopPoint;
                }
                
                break;
            }
            default:
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case FilePlaybackParameterIsPlaying:
                return (AUValue)isPlaying;
            case FilePlaybackParameterIsMuted:
                return (AUValue)isMuted;
            case FilePlaybackParameterLoopStart:
                return (AUValue)loopStart;
            case FilePlaybackParameterLoopEnd:
                return (AUValue)loopEnd;
            case FilePlaybackParameterEnqueuedLoopStart:
                return (AUValue)enqueuedLoopStart;
            case FilePlaybackParameterEnqueuedLoopEnd:
                return (AUValue)enqueuedLoopEnd;
            default:
                return 0;
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            default:
                break;
        }
    }
    
    // MARK: - Buffers
    void setBuffer(AudioBufferList* outBufferList) {
        outBufferListPtr = outBufferList;
    }
    
    // MARK: - Process
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        int32_t availableBytes = 0;
        int32_t availableFrames = 0;
        
        float* readHead = (float*)TPCircularBufferTail(&cBuffer, &availableBytes);
        availableFrames = (availableBytes / sizeof(float)) / channelCount;
        
        int32_t framesElapsed = 0;
        
        // Copy the read buffer to the output buffer
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            
            float output = 0.f;
            
            for (int channel = 0; channel < channelCount; ++channel) {
                int channelSpecificFrame = (frameIndex * channelCount) + channel;
                
                if(frameIndex < availableFrames) {
                    output = readHead[channelSpecificFrame];
                    if(channel == 0) {
                        framesElapsed++;
                    }
                } else {
                    output = 0.f;
                }
                
                float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = output;
            }
        }
        
        // Calculate the read time
        if(true) { // file.isMasterTrack) {
            realTimeReadFrame += framesElapsed;
            
            if(realTimeReadFrame > realTimeLoopEnd) {
                int32_t diff = realTimeReadFrame - realTimeLoopEnd;
                realTimeReadFrame = loopStart + diff;
                realTimeLoopEnd = loopEnd;
                
                sectionEndReachedCallback();
            }
            
            currentTimeUpdatedCallback(float(realTimeReadFrame / sampleRate));
        }
        
        // Consume frames from the circular buffer
        if(frameCount < availableFrames) {
            TPCircularBufferConsume(&cBuffer, frameCount * sizeof(float) * channelCount);
        } else {
            TPCircularBufferConsume(&cBuffer, availableBytes);
        }
        
        // Check whether we should refill buffer
        int fillCount = cBuffer.fillCount;
        
        if(fillCount < cBufferRefillLimit &&
           file.isFillingBuffer == NO) {
            dispatch_async(file.bufferFillingQueue, ^{
                file.isFillingBuffer = YES;
                fillCircularBuffer();
                file.isFillingBuffer = NO;
            });
        }
    }
    
private:
    // MARK: - TPCircularBuffer
    void fillCircularBuffer() {
        if(isPlaying == true) {
            int32_t totalBytesToRead = 0;
            int32_t totalFramesToRead = 0;
            
            // Determine number of frames in available bytes
            float* writeHead = (float*)TPCircularBufferHead(&cBuffer, &totalBytesToRead);
            totalFramesToRead = totalBytesToRead / clientAudioStreamBasicDescription.mBytesPerFrame; // bytes per frame already accounts for channelCount - a 'frame' is one sample for all channels. So, for stereo, interleaved audio, a frame is 2 samples
            
            std::vector<int32_t> framesToReadVector;
            
            // If we are delaying the sample start - write the delayed silent frames to the buffer first
            if(hasDelayedStart == false) {
                if(sampleTimeDelayOffset < totalFramesToRead) {
                    // Write silence for the delayed samples
                    int32_t framesToRead = sampleTimeDelayOffset;
                    
                    for(int32_t i = 0; i < framesToRead; i++) {
                        writeHead[i] = 0.0f;
                    }
                    
                    // Produce bytes
                    int32_t totalBytesRead = framesToRead * clientAudioStreamBasicDescription.mBytesPerFrame;
                    TPCircularBufferProduce(&cBuffer, totalBytesRead);
                    
                    hasDelayedStart = true;
                }
                
                return;
            }
            
            if(sampleTimeReadFrame + totalFramesToRead < loopEnd) {
                framesToReadVector.push_back(totalFramesToRead);
            } else {
                int32_t testFramePosition = sampleTimeReadFrame;
                int32_t framesLeftToWrite = totalFramesToRead;
                
                int32_t targetLoopEnd = loopEnd;
                
                while(framesLeftToWrite > 0) {
                    int32_t framesToWrite = framesLeftToWrite;
                    int32_t framesToLoopEnd = targetLoopEnd - testFramePosition;
                    
                    if(framesToWrite >= framesToLoopEnd) {
                        framesToWrite = framesToLoopEnd;
                        
                        if(enqueuedLoopStart != NoEnqueuedLoopPoint &&
                           enqueuedLoopEnd != NoEnqueuedLoopPoint) {
                            // There's a new loop enqueued
                            testFramePosition = enqueuedLoopStart;
                            targetLoopEnd = enqueuedLoopEnd;
                        } else {
                            testFramePosition = loopStart;
                            targetLoopEnd = loopEnd;
                        }
                    }
                    
                    framesToReadVector.push_back(framesToWrite);
                    framesLeftToWrite -= framesToWrite;
                }
            }
            
            int32_t totalFramesRead = 0;
            int32_t writeHeadIndex = 0;
            
            for(std::vector<int32_t>::iterator it = framesToReadVector.begin(); it != framesToReadVector.end(); ++it) {
                int32_t framesToRead = *it;
                if(framesToRead < 1) {
                    continue;
                }
                
                int32_t bytesToRead = framesToRead * clientAudioStreamBasicDescription.mBytesPerFrame;
                char mData[bytesToRead];
                
                AudioBufferList audioFileBufferList;
                audioFileBufferList.mNumberBuffers = 1;
                audioFileBufferList.mBuffers[0].mNumberChannels = clientAudioStreamBasicDescription.mChannelsPerFrame;
                audioFileBufferList.mBuffers[0].mDataByteSize = bytesToRead;
                audioFileBufferList.mBuffers[0].mData = (void*)mData;
                
                UInt32 ui32FramesToRead = framesToRead;
                OSStatus status = ExtAudioFileRead(file.audioFile, &ui32FramesToRead, &audioFileBufferList);
                assert(status == noErr); // Error reading audio file
                
                // Copy the audio file buffer data to the circular buffer
                float* audioFileBuffer = (float*)audioFileBufferList.mBuffers[0].mData;
                int32_t floatsToRead = framesToRead * clientAudioStreamBasicDescription.mChannelsPerFrame;
                
                for(int32_t idx = 0; idx < floatsToRead; idx++) {
                    writeHead[writeHeadIndex] = audioFileBuffer[idx];
                    ++writeHeadIndex;
                }
                
                totalFramesRead += framesToRead;
                
                // Progress the file read pointer
                sampleTimeReadFrame += framesToRead;
                
                // Reset if at loop end
                if(sampleTimeReadFrame == loopEnd) {
                    if(enqueuedLoopStart != NoEnqueuedLoopPoint &&
                       enqueuedLoopEnd != NoEnqueuedLoopPoint) {
                        loopStart = enqueuedLoopStart;
                        loopEnd = enqueuedLoopEnd;
                        
                        enqueuedLoopStart = enqueuedLoopEnd = NoEnqueuedLoopPoint;
                    }
                    
                    // Don't loop
                    //                    status = ExtAudioFileSeek(file.audioFile, loopStart);
                    //                    assert(status == noErr); // Error reading audio file
                    //
                    //                    sampleTimeReadFrame = loopStart;
                    
                    isPlaying = false;
                    break;
                }
            }
            
            int32_t totalBytesRead = totalFramesRead * clientAudioStreamBasicDescription.mBytesPerFrame;
            TPCircularBufferProduce(&cBuffer, totalBytesRead);
        }
    }

    // MARK: - Member Variables
    int channelCount = 0;
    float sampleRate = 44100.0;

    // Audio
    File file;
    AudioStreamBasicDescription clientAudioStreamBasicDescription;

    // Buffers;
    AudioBufferList* outBufferListPtr = nullptr;

    const int cBufferLength = (sizeof(float) * 2) * 22050;
    const int cBufferRefillLimit = cBufferLength / 4;
    TPCircularBuffer cBuffer;
    
    // Sample-time
    int32_t sampleTimeReadFrame = 0;
    int32_t sampleTimeStartOffset = 0;
    int32_t sampleTimeDelayOffset = 0;
    bool hasDelayedStart = false;
    
    int32_t loopStart = 0;
    int32_t loopEnd = sampleRate;
    
    static const int32_t NoEnqueuedLoopPoint = -1;
    int32_t enqueuedLoopStart = NoEnqueuedLoopPoint;
    int32_t enqueuedLoopEnd = NoEnqueuedLoopPoint;
    
    // Real-time
    int32_t realTimeReadFrame = 0;
    int32_t realTimeLoopEnd = sampleRate;
    
    // Parameters
    bool isPlaying = false;
    bool isMuted = false;
    
    // Callbacks
    SectionEndReachedCallback sectionEndReachedCallback = nullptr;
    CurrentTimeUpdatedCallback currentTimeUpdatedCallback = nullptr;
    
public:
    bool started = false;
    bool resetted = false;
};
