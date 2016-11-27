//
//  AKAudioUnitType.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/14/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#ifndef AKAudioUnitType_h
#define AKAudioUnitType_h
@protocol AKAudioUnitType
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end



#endif /* AKAudioUnitType_h */
