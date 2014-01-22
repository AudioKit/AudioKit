//
//  FivePropertyInstrument.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//


#import "FivePropertyInstrument.h"

@implementation FivePropertyInstrument

- (instancetype)init
{
    self = [super init];
    if ( self) {
        
        // NOTE BASED CONTROL ==================================================
        FivePropertyInstrumentNote *note = [[FivePropertyInstrumentNote alloc] init];
        [self addNoteProperty:note.volume];
        [self addNoteProperty:note.frequency];
        
        
        // INPUTS AND CONTROLS =================================================
        _pitchBend = [[AKInstrumentProperty alloc] initWithValue:1
                                                     minimumValue:kPitchBendMin
                                                     maximumValue:kPitchBendMax];
        _modulation = [[AKInstrumentProperty alloc] initWithMinimumValue:kModulationMin
                                                             maximumValue:kModulationMax];
        _cutoffFrequency = [[AKInstrumentProperty alloc] initWithMinimumValue:kLpCutoffMin
                                                                  maximumValue:kLpCutoffMax];
        
        [self addProperty:_pitchBend];
        [self addProperty:_modulation];
        [self addProperty:_cutoffFrequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKSineTable *sine = [[AKSineTable alloc] init];
        [self addFTable:sine];
        
        AKControl *bentFreq;
        bentFreq = [[AKControl alloc] initWithExpression:[NSString stringWithFormat:@"%@  * %@", note.frequency, _pitchBend]];
        
        AKFMOscillator *fm = [[AKFMOscillator alloc] initWithFTable:sine
                                                        baseFrequency:bentFreq
                                                    carrierMultiplier:akp(2)
                                                 modulatingMultiplier:_modulation
                                                      modulationIndex:akp(15)
                                                            amplitude:note.volume];
        [self connect:fm];
        
        AKLowPassButterworthFilter *lpFilter;
        lpFilter = [[AKLowPassButterworthFilter alloc] initWithAudioSource:fm
                                                            cutoffFrequency:_cutoffFrequency];
        [self connect:lpFilter];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:lpFilter];
        [self connect:audio];
    }
    return self;
}

@end


@implementation FivePropertyInstrumentNote

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _volume = [[AKNoteProperty alloc] initWithValue:kVolumeInit
                                            minimumValue:kVolumeMin
                                            maximumValue:kVolumeMax];
        [self addProperty:_volume];
        
        _frequency = [[AKNoteProperty alloc] initWithValue:kFrequencyMin
                                               minimumValue:kFrequencyMin
                                               maximumValue:kFrequencyMax];
        [self addProperty:_frequency];
        
    }
    return self;
}

- (instancetype)initWithFrequency:(float)frequency atVolume:(float)volume
{
    self = [self init];
    if (self) {
        self.frequency.value = frequency;
        self.volume.value = volume;
    }
    return self;
}


@end
