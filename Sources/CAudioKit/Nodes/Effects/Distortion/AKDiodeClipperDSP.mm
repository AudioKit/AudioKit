// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "DiodeClipper.hpp"
#include "AKSoulDSP.hpp"

enum AKDiodeClipperParameter {
    AKDiodeClipperParameterCutoff,
    AKDiodeClipperParameterGaindB
};

using AKDiodeClipperDSP = AKSoulDSP<Diode>;
AK_REGISTER_DSP(AKDiodeClipperDSP)
AK_REGISTER_PARAMETER(AKDiodeClipperParameterCutoff)
AK_REGISTER_PARAMETER(AKDiodeClipperParameterGaindB)


