//
//  AKNewSequencerTrackDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/31/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKNewSequencerTrackParameter) {
    AKNewSequencerTrackParameterStartPoint,
    AKNewSequencerTrackParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createNewSequencerTrackDSP(int channelCount, double sampleRate);

#else

#import "AKDSPBase.hpp"

class AKNewSequencerTrackDSP : public AKDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;

    float startPoint = 0;
    AudioUnit targetAU;
    UInt64 framesCounted = 0;
    UInt64 positionInSamples = 0;

    void sendMidiData(UInt8 status, UInt8 data1, UInt8 data2, double offset, double time);
    int lengthInSamples();
    void resetPlaybackVariables();
    int beatToSamples(double beat);
    int positionModulo();
    bool validTriggerTime(double beat);

    struct MIDIEvent {
        uint8_t status;
        uint8_t data1;
        uint8_t data2;
        double beat;
        double duration;
    };

    struct MIDINote {
        struct MIDIEvent noteOn;
        struct MIDIEvent noteOff;
    };


public:
    AKNewSequencerTrackDSP();

    float startPointLowerBound = 0.0;
    float startPointUpperBound = 20000.0;

    float defaultStartPoint = 0.0;

    int defaultRampDurationSamples = 0;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

    // Sequencer Stuff
    void start() override;
    bool isLooping() override;
    void toggleLooping() override;
    void setTargetAU(AudioUnit target) override;
    void addMIDIEvent(UInt8 status, UInt8 data1, UInt8 data2, double beat) override;

    bool isPlaying = false;
    MIDIPortRef midiPort;
    MIDIEndpointRef midiEndpoint;
    MIDIEvent events[512];
    int eventCount = 0;
    double lengthInBeats = 4.0;
    double bpm = 120.0;
    bool stopAfterCurrentNotes = false;
    bool loopEnabled = true;
};

#endif
