//
//  AKOfflineRenderDSPKernel.h
//  AudioKit For iOS
//
//  Created by Bang Means Do It on 27/03/2017.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once
#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>


class AKOfflineRenderDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions
    
    AKOfflineRenderDSPKernel() {}
    
    void init(int _channels, double _sampleRate) override {
        AKDSPKernel::init(_channels, _sampleRate);
    }
    
    void completeFileWrite() {
        printf("\n\nFile Write Complete\n\n");
        ExtAudioFileDispose(outputFile);
    }
    
    // AKAudioUnit - Standard Setup
    // Start and stop
    void start() {
    }
    
    void stop() {
    }
    
    void destroy() {
    }
    
    void reset() {
    }
    
    // MARK: - Offline Render
    void setUpOutputAudioFile(CFURLRef outputFileURL) {
        
        // The output audio file format
        AudioStreamBasicDescription outputFormat;
        
        // The file type identifier tells the ExtAudioFile API what kind of file we want created
        AudioFileTypeID fileType;
        
        if(m4aOutput == true) {
            // Define format
            outputFormat.mFormatID = kAudioFormatMPEG4AAC;
            outputFormat.mSampleRate = 44100;
            outputFormat.mFormatFlags = kMPEG4Object_AAC_Main;
            outputFormat.mChannelsPerFrame = 2;
            outputFormat.mBitsPerChannel = 0;
            outputFormat.mBytesPerFrame = 0;
            outputFormat.mBytesPerPacket = 0;
            outputFormat.mFramesPerPacket = 1024;
            
            // This creates a wav file type
            fileType = kAudioFileM4AType;
        } else {
            FillOutASBDForLPCM(outputFormat, sampleRate, channels, 16, 16, false, false, false);
            fileType = kAudioFileWAVEType;
        }
        
        // Dispose of existing audio file if needed
        ExtAudioFileDispose(outputFile);
        
        enableOfflineRender(false);
        
        // Open output file with format
        OSStatus status;
        status = ExtAudioFileCreateWithURL(outputFileURL,
                                           fileType,
                                           &outputFormat,
                                           NULL,
                                           kAudioFileFlags_EraseFile,
                                           &outputFile);
        
        assert(status == noErr); // Error opening file
        
        AudioStreamBasicDescription localFormat;
        FillOutASBDForLPCM(localFormat, 44100.0, channels, 16, 16, false, false, false);
        
        // Tell the ExtAudioFile API what format we'll be sending samples in
        status = ExtAudioFileSetProperty(outputFile,
                                         kExtAudioFileProperty_ClientDataFormat,
                                         sizeof(localFormat),
                                         &localFormat);
        
        assert(status == noErr); // Error defining audio stream
    }
    
    // MARK :- Parameters
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            default:
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            default:
                return 0.0f;
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            default:
                break;
        }
    }
    
    // Set buffers
    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        AKOutputBuffered::setBuffer(outBufferList);
        inBufferListPtr = inBufferList;
    }
    
    // MARK: - Render
    void enableOfflineRender(bool enable) {
        shouldWriteToFile = enable;
    }
    
    // MARK: - Process
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        if(frameCount < 1) {
            return;
        }
        
        // Prepare the output buffer list for writing to the file
        AudioBufferList outputData;
        
        outputData.mNumberBuffers = 1;
        outputData.mBuffers[0].mNumberChannels = channels;
        outputData.mBuffers[0].mDataByteSize = sizeof(int16_t) * frameCount * channels;
        
        int16_t audioFileOutputBuffer[frameCount * channels];
        
        // Copy the buffer to the output buffer and to
        // the buffer for writing to the output file
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            
            for (int channel = 0; channel < channels; ++channel) {
                int channelSpecificFrame = (frameIndex * channels) + channel;
                
                // !!! - note: due to the way the buffers are set up
                // out = in   ie. the address of input buffer is just copied to the
                // output buffer. So, output buffer is NOT independent - we are processing in place
                // Would need to rewrite .mm file to make buffers independent
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                // Copy value to the audio file buffer
                int16_t newValue16BitInt = *in * 32767.f;
                audioFileOutputBuffer[channelSpecificFrame] = newValue16BitInt;
                
                if(shouldWriteToFile == false) {
                    *out = *in;
                } else {
                    *out = *in * 0.f;
                }
            }
        }

        outputData.mBuffers[0].mData = &audioFileOutputBuffer;
        
        if(shouldWriteToFile == true) {
            OSStatus status;
            status = ExtAudioFileWrite(outputFile, frameCount, &outputData);
            assert(status == noErr);
        }
    }
    
private:
    ExtAudioFileRef outputFile;
    bool m4aOutput = false;
    bool shouldWriteToFile = false;
    
public:
    bool started = false;
    bool resetted = false;
};
