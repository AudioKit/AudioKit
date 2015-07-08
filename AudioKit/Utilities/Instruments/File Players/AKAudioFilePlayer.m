//
//  AudioFilePlayer.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudioFilePlayer.h"

@implementation AKAudioFilePlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // Instrument Control
        _speed     = [self createPropertyWithValue:1 minimum:-2 maximum:2];
        _scaling   = [self createPropertyWithValue:1 minimum:0  maximum:3];
        _sampleMix = [self createPropertyWithValue:0 minimum:0  maximum:1];
        
        // Instrument Definition
        NSString *file1 = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        NSString *file2 = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        
        AKFileInput *fileIn1 = [[AKFileInput alloc] initWithFilename:file1];
        fileIn1.speed = _speed;
        fileIn1.loop = YES;
        
        AKFileInput *fileIn2 = [[AKFileInput alloc] initWithFilename:file2];
        fileIn2.speed = _speed;
        fileIn2.loop = YES;
        
        AKMix *fileInLeft = [[AKMix alloc] initWithInput1:fileIn1.leftOutput
                                                   input2:fileIn2.leftOutput
                                                  balance:_sampleMix];
        
        AKMix *fileInRight = [[AKMix alloc] initWithInput1:fileIn1.rightOutput
                                                    input2:fileIn2.rightOutput
                                                   balance:_sampleMix];
        
        AKFFT *leftF;
        leftF = [[AKFFT alloc] initWithInput:[fileInLeft scaledBy:akp(0.25)]
                                     fftSize:akp(1024)
                                     overlap:akp(256)
                                  windowType:[AKFFT hammingWindow]
                            windowFilterSize:akp(1024)];
        
        AKFFT *rightF;
        rightF = [[AKFFT alloc] initWithInput:[fileInRight scaledBy:akp(0.25)]
                                      fftSize:akp(1024)
                                      overlap:akp(256)
                                   windowType:[AKFFT hammingWindow]
                             windowFilterSize:akp(1024)];
        
        AKScaledFFT *scaledLeftF;
        scaledLeftF = [[AKScaledFFT alloc] initWithSignal:leftF frequencyRatio:_scaling];
        
        AKScaledFFT *scaledRightF;
        scaledRightF = [[AKScaledFFT alloc] initWithSignal:rightF frequencyRatio:_scaling];
        
        AKResynthesizedAudio *scaledLeft;
        scaledLeft = [[AKResynthesizedAudio alloc] initWithSignal:scaledLeftF];
        
        AKResynthesizedAudio *scaledRight;
        scaledRight = [[AKResynthesizedAudio alloc] initWithSignal:scaledRightF];
        
        AKMix *mono = [[AKMix alloc] initWithInput1:scaledLeft input2:scaledRight balance:akp(0.5)];
        
        // Output to global effects processing
        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:mono];
        
    }
    return self;
}

@end
