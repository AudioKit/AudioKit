// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "DiodeClipper.h"
#include "SoulDSP.h"

// XXX: For some reason this would result in a link error with it only defined inside Diode.
constexpr const std::array<const Diode::ParameterProperties, Diode::numParameters> Diode::parameters =
{
    ParameterProperties {  "cutoffFrequency",  "Cutoff",  "",  20.0f,  20000.0f,  10.0f,  10000.0f,  true,  false,  false,  "",  ""  },
    ParameterProperties {  "gaindB",           "Gain",    "",  0.0f,   40.0f,     0.1f,   20.0f,     true,  false,  false,  "",  ""  }
};

enum DiodeClipperParameter {
    DiodeClipperParameterCutoff,
    DiodeClipperParameterGaindB
};

using DiodeClipperDSP = SoulDSP<Diode>;
AK_REGISTER_DSP(DiodeClipperDSP, "dclp")
AK_REGISTER_PARAMETER(DiodeClipperParameterCutoff)
AK_REGISTER_PARAMETER(DiodeClipperParameterGaindB)


