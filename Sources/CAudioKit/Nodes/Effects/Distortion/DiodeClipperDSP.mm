// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "DiodeClipper.hpp"
#include "SoulDSP.hpp"

enum DiodeClipperParameter {
    DiodeClipperParameterCutoff,
    DiodeClipperParameterGaindB
};

using DiodeClipperDSP = SoulDSP<Diode>;
AK_REGISTER_DSP(DiodeClipperDSP)
AK_REGISTER_PARAMETER(DiodeClipperParameterCutoff)
AK_REGISTER_PARAMETER(DiodeClipperParameterGaindB)


