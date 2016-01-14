//
//  AKBufferedAudioBus.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//


#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

// Reusable non-ObjC class, accessible from render thread.
struct AKBufferedAudioBus {
	AUAudioUnitBus* bus = nullptr;
	AUAudioFrameCount maxFrames = 0;
    
	AVAudioPCMBuffer* pcmBuffer = nullptr;
    
	AudioBufferList const* originalAudioBufferList = nullptr;
	AudioBufferList *mutableAudioBufferList = nullptr;

	void init(AVAudioFormat* defaultFormat, AVAudioChannelCount maxChannels) {
		maxFrames = 0;
		pcmBuffer = nullptr;
		originalAudioBufferList = nullptr;
		mutableAudioBufferList = nullptr;
		
        bus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];

        bus.maximumChannelCount = maxChannels;
	}
	
	void allocateRenderResources(AUAudioFrameCount inMaxFrames) {
		maxFrames = inMaxFrames;
		
		pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:bus.format frameCapacity: maxFrames];
		
        originalAudioBufferList = pcmBuffer.audioBufferList;
        mutableAudioBufferList = pcmBuffer.mutableAudioBufferList;
	}
	
	void deallocateRenderResources() {
		pcmBuffer = nullptr;
		originalAudioBufferList = nullptr;
		mutableAudioBufferList = nullptr;
	}
};

/*
	`BufferedInputBus`
	This class manages a buffer into which an audio unit with input busses can 
    pull its input data.
*/
struct BufferedInputBus : AKBufferedAudioBus {
	/*
        Gets input data for this input by preparing the input buffer list and pulling
        the pullInputBlock.
    */
	AUAudioUnitStatus pullInput(AudioUnitRenderActionFlags *actionFlags,
								AudioTimeStamp const* timestamp,
								AVAudioFrameCount frameCount,
								NSInteger inputBusNumber,
								AURenderPullInputBlock pullInputBlock) {
        if (pullInputBlock == nullptr) {
			return kAudioUnitErr_NoConnection;
		}
		
		prepareInputBufferList();
		
		return pullInputBlock(actionFlags, timestamp, frameCount, inputBusNumber, mutableAudioBufferList);
	}

    /*
    	\c prepareInputBufferList populates the \c mutableAudioBufferList with the data
        pointers from the \c originalAudioBufferList.

        The upstream audio unit may overwrite these with its own pointers, so each
        render cycle this function needs to be called to reset them.
	*/
    void prepareInputBufferList() {
        UInt32 byteSize = maxFrames * sizeof(float);
		
        mutableAudioBufferList->mNumberBuffers = originalAudioBufferList->mNumberBuffers;
		
        for (UInt32 i = 0; i < originalAudioBufferList->mNumberBuffers; ++i) {
            mutableAudioBufferList->mBuffers[i].mNumberChannels = originalAudioBufferList->mBuffers[i].mNumberChannels;
            mutableAudioBufferList->mBuffers[i].mData = originalAudioBufferList->mBuffers[i].mData;
            mutableAudioBufferList->mBuffers[i].mDataByteSize = byteSize;
        }
    }
};

