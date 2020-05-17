// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#ifndef __cplusplus

AKDSPRef createBalancerDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKBalancerDSP : public AKSoundpipeDSPBase {
public:
    // MARK: Member Functions

    AKBalancerDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

    // MARK: Member Variables

private:

    sp_bal *bal;
};

#endif
