//
//  AKRhinoGuitarProcessorDSPKernel.hpp
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#pragma once

#import "AKDSPKernel.hpp"

class AKRhinoGuitarProcessorDSPKernel : public AKDSPKernel, public AKBuffered {
public:

    enum {
        preGainAddress = 0,
        postGainAddress = 1,
        lowGainAddress = 2,
        midGainAddress = 3,
        highGainAddress = 4,
        distTypeAddress = 5,
        distortionAddress= 6
    };

    // MARK: Member Functions

    AKRhinoGuitarProcessorDSPKernel();
    ~AKRhinoGuitarProcessorDSPKernel();

    void init(int _channels, double _sampleRate) override;

    void start();

    void stop();

    void destroy();

    void reset();

    void setPreGain(float value);

    void setPostGain(float value);

    void setLowGain(float value);

    void setMidGain(float value);

    void setHighGain(float value);

    void setDistType(float value);

    void setDistortion(float value);

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
    ParameterRamper preGainRamper = 5.0;
    ParameterRamper postGainRamper = 0.0;
    ParameterRamper lowGainRamper = 0.0;
    ParameterRamper midGainRamper = 0.0;
    ParameterRamper highGainRamper = 0.0;
    ParameterRamper distTypeRamper = 1.0;
    ParameterRamper distortionRamper = 1.0;
};

#endif

