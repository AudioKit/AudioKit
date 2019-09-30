//
//  AKShakerDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/30/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKShakerParameter) {
    AKShakerParameterType,
    AKShakerParameterAmplitude,
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

AKDSPRef createShakerDSP(int channelCount, double sampleRate);

#else

class AKShakerDSP : public AKDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;

public:

    AKShakerDSP();

    ~AKShakerDSP();

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override;

    void init(int channelCount, double sampleRate) override;

    void trigger() override;

    void triggerTypeAmplitude(AUValue freq, AUValue amp) override;

    void destroy();

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;
};

#endif


