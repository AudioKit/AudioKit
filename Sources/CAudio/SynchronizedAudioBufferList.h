#pragma once

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudio.h>

struct SynrchonizedAudioBufferList2 {

    AVAudioPCMBuffer* pcmBuffer;

    AudioBufferList* abl;

    std::atomic<int> sync;

    void endWriting() {
        sync.fetch_add(1, std::memory_order_release);
    }

    void beginReading() {
        sync.fetch_sub(1, std::memory_order_acquire);
    }
};

