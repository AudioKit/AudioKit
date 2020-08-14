// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AudioKit.h"

#include "DiodeClipper.hpp"
#include "AKSoulDSPBase.hpp"

using AKDiodeClipperDSP = AKSoulDSPBase<Diode>;
AK_REGISTER_DSP(AKDiodeClipperDSP)

