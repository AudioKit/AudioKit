//
//  AKTanhDistortionAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTanhDistortionAudioUnit_h
#define AKTanhDistortionAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKTanhDistortionAudioUnit : AUAudioUnit<AKAudioUnitType>

@property (nonatomic) float pregain;
@property (nonatomic) float postgain;
@property (nonatomic) float postiveShapeParameter;
@property (nonatomic) float negativeShapeParameter;

@property double rampTime;

@end

#endif /* AKTanhDistortionAudioUnit_h */
