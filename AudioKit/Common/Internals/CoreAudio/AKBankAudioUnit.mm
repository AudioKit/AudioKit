//
//  AKBankAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/15/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKBankAudioUnit.h"

@implementation AKBankAudioUnit

- (BOOL)isSetUp { return NO; }
- (void)setAttackDuration:(float)attackDuration {};
- (void)setDecayDuration:(float)decayDuration {};
- (void)setSustainLevel:(float)sustainLevel {};
- (void)setReleaseDuration:(float)releaseDuration {};
- (void)setDetuningOffset:(float)detuningOffset {};
- (void)setDetuningMultiplier:(float)detuningMultiplier {};
- (void)stopNote:(uint8_t)note {};
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity {};
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency {};

@end
