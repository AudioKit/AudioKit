// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDSPKernel.hpp"

#import <AudioKit/AudioKit-Swift.h>

AKDSPKernel::AKDSPKernel() : AKDSPKernel(AKSettings.channelCount, AKSettings.sampleRate) { }
