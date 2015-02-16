//
//  AudioFilePlayer.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AudioFilePlayer.h"

@implementation AudioFilePlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // INSTRUMENT BASED CONTROL ============================================
        _speed = [[AKInstrumentProperty alloc] initWithValue:1
                                                     minimum:-2
                                                     maximum:2];
        [self addProperty:_speed];
        
        _scaling = [[AKInstrumentProperty alloc] initWithValue:1
                                                       minimum:0.0
                                                       maximum:3.0];
        [self addProperty:_scaling];
        
        _sampleMix = [[AKInstrumentProperty alloc] initWithValue:0
                                                         minimum:0
                                                         maximum:1];
        [self addProperty:_sampleMix    ];
        
        // INSTRUMENT DEFINITION ===============================================

        NSString *file1;
        file1 = [[NSBundle mainBundle] pathForResource:@"PianoBassDrumLoop" ofType:@"wav"];

        NSString *file2;
        file2 = [[NSBundle mainBundle] pathForResource:@"808loop" ofType:@"wav"];
        
        
        AKFileInput *fileIn1 = [[AKFileInput alloc] initWithFilename:file1];
        fileIn1.speed = _speed;
        [self connect:fileIn1];
        
        AKFileInput *fileIn2 = [[AKFileInput alloc] initWithFilename:file2];
        fileIn2.speed = _speed;
        [self connect:fileIn2];
        
        AKMix *fileInLeft = [[AKMix alloc] initWithInput1:fileIn1.leftOutput
                                                   input2:fileIn2.leftOutput
                                                  balance:_sampleMix];
        [self connect:fileInLeft];
        
        AKMix *fileInRight = [[AKMix alloc] initWithInput1:fileIn1.rightOutput
                                                    input2:fileIn2.rightOutput
                                                   balance:_sampleMix];
        [self connect:fileInRight];
        
        
        AKFFT *leftF;
        leftF = [[AKFFT alloc] initWithInput:[fileInLeft scaledBy:akp(0.25)]
                                     fftSize:akp(1024)
                                     overlap:akp(256)
                                  windowType:AKFFTWindowTypeHamming
                            windowFilterSize:akp(1024)];
        [self connect:leftF];
        
        AKFFT *rightF;
        rightF = [[AKFFT alloc] initWithInput:[fileInRight scaledBy:akp(0.25)]
                                      fftSize:akp(1024)
                                      overlap:akp(256)
                                   windowType:AKFFTWindowTypeHamming
                             windowFilterSize:akp(1024)];
        [self connect:rightF];
        
        AKScaledFFT *scaledLeftF;
        scaledLeftF = [[AKScaledFFT alloc] initWithSignal:leftF frequencyRatio:_scaling];
        [self connect:scaledLeftF];
        
        AKScaledFFT *scaledRightF;
        scaledRightF = [[AKScaledFFT alloc] initWithSignal:rightF frequencyRatio:_scaling];
        [self connect:scaledRightF];
        
        AKResynthesizedAudio *scaledLeft;
        scaledLeft = [[AKResynthesizedAudio alloc] initWithSignal:scaledLeftF];
        [self connect:scaledLeft];
        
        AKResynthesizedAudio *scaledRight;
        scaledRight = [[AKResynthesizedAudio alloc] initWithSignal:scaledRightF];
        [self connect:scaledRight];
        
        AKMix *mono = [[AKMix alloc] initWithInput1:scaledLeft input2:scaledRight balance:akp(0.5)];
        [self connect:mono];
        
        // Output to global effects processing
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:mono];
        
    }
    return self;
}

@end
