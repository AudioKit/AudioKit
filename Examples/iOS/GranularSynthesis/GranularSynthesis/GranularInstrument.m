//
//  GranularInstrument.m
//  GranularSynthTest
//
//  Created by Nicholas Arner on 9/2/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "GranularInstrument.h"
#import "AKFoundation.h"

@implementation GranularInstrument

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // INPUTS AND CONTROLS =================================================
        _mix = [[AKInstrumentProperty alloc] initWithValue:0.5
                                                   minimum:0
                                                   maximum:1];
        
        _frequency = [[AKInstrumentProperty alloc] initWithValue:0.2
                                                         minimum:0.01
                                                         maximum:10];
        
        _duration = [[AKInstrumentProperty alloc] initWithValue:10
                                                        minimum:0.1
                                                        maximum:20];
        
        _density = [[AKInstrumentProperty alloc] initWithValue:1
                                                       minimum:0.1
                                                       maximum:2];
        
        _frequencyVariation = [[AKInstrumentProperty alloc] initWithValue:10
                                                                  minimum:0.1
                                                                  maximum:  20];
        
        _frequencyVariationDistribution = [[AKInstrumentProperty alloc] initWithValue:10
                                                                              minimum:0.1
                                                                              maximum:20];
        
        [self addProperty:_mix];
        [self addProperty:_frequency];
        [self addProperty:_duration];
        [self addProperty:_density];
        [self addProperty:_frequencyVariation];
        [self addProperty:_frequencyVariationDistribution];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"PianoBassDrumLoop"
                                                         ofType:@"wav"];
        AKSoundFile *soundFile;
        soundFile = [[AKSoundFile alloc] initWithFilename:file];
        soundFile.size = 16384;
        [self addFunctionTable:soundFile];
        
        AKGranularSynthesizer *synth;
        synth = [[AKGranularSynthesizer alloc] initWithGrainWaveform:soundFile
                                                           frequency:_frequency];
        synth.duration = _duration;
        synth.density = _density;
        synth.frequencyVariation = _frequencyVariation;
        synth.frequencyVariationDistribution = _frequencyVariationDistribution;
        [self connect:synth];
        
        NSString *file2 = [[NSBundle mainBundle] pathForResource:@"808loop"
                                                         ofType:@"wav"];
        AKSoundFile *soundFile2;
        soundFile2 = [[AKSoundFile alloc] initWithFilename:file2];
        soundFile2.size = 16384;
        [self addFunctionTable:soundFile2];
        
        AKGranularSynthesizer *synth2;
        synth2 = [[AKGranularSynthesizer alloc] initWithGrainWaveform:soundFile2
                                                           frequency:_frequency];
        synth2.duration = _duration;
        synth2.density = _density;
        synth2.frequencyVariation = _frequencyVariation;
        synth2.frequencyVariationDistribution = _frequencyVariationDistribution;
        [self connect:synth2];
        
        AKMix *mixer = [[AKMix alloc] initWithInput1:synth
                                              input2:synth2
                                             balance:_mix];
        [self connect:mixer];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:[mixer scaledBy:akp(0.5)]];
        [self connect:audio];
    }
    return self;
}

@end
