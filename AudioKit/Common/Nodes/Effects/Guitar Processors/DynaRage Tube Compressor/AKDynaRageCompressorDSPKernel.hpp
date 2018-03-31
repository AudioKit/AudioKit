//
//  AKDynaRageCompressorDSPKernel.hpp
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#pragma once

#import "AKDSPKernel.hpp"
#import "ParameterRamper.hpp"

class AKDynaRageCompressorDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    enum {
        ratioAddress = 0,
        thresholdAddress = 1,
        attackTimeAddress = 2,
        releaseTimeAddress = 3,
        rageAddress = 4
    };

    // MARK: Member Functions

    AKDynaRageCompressorDSPKernel();
    ~AKDynaRageCompressorDSPKernel();
    
    void init(int _channels, double _sampleRate) override;

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() { }

    void reset();

    void setRatio(float value);

    void setThreshold(float value);

    void setAttackTime(float value);

    void setReleaseTime(float value);

    void setRage(float value) ;

    void setRageIsOn(bool value);

    void setParameter(AUParameterAddress address, AUValue value);

    AUValue getParameter(AUParameterAddress address);
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

    // MARK: Member Variables

private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper ratioRamper = 1;
    ParameterRamper thresholdRamper = 0.0;
    ParameterRamper attackTimeRamper = 0.1;
    ParameterRamper releaseTimeRamper = 0.1;
    ParameterRamper rageRamper = 0.1;
};

#endif

