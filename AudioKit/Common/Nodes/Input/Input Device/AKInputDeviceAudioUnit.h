//
//  AKInputDeviceAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"
#import "EZMicrophone.h"

@interface AKInputDeviceAudioUnit : AKAudioUnit<EZMicrophoneDelegate>

@end

