//
//  AKDSPKernel.cpp
//  AudioKit
//
//  Created by Stéphane Peter on 2/2/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKDSPKernel.hpp"

#import <AudioKit/AudioKit-Swift.h>

AKDSPKernel::AKDSPKernel() : AKDSPKernel(AKSettings.numberOfChannels, AKSettings.sampleRate) { }
