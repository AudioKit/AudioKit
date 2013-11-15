//
//  OCSAudioAnalyzer.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 11/14/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface OCSAudioAnalyzer : OCSInstrument

@property (nonatomic, strong) OCSInstrumentProperty *trackedFrequency;
#define kTrackedFrequencyMin  0.0
#define kTrackedFrequencyMax  2500.0

@property (nonatomic, strong) OCSInstrumentProperty *trackedAmplitude;

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource;

@end
