//
//  AKBeatenPlate.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's wguide2:
//  http://www.csounds.com/manual/html/wguide2.html
//

#import "AKBeatenPlate.h"
#import "AKManager.h"

@implementation AKBeatenPlate
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         frequency1:(AKParameter *)frequency1
                         frequency2:(AKParameter *)frequency2
                   cutoffFrequency1:(AKControl *)cutoffFrequency1
                   cutoffFrequency2:(AKControl *)cutoffFrequency2
                          feedback1:(AKControl *)feedback1
                          feedback2:(AKControl *)feedback2
{
    self = [super initWithString:[self operationName]];
    if (self) {
            _audioSource = audioSource;
                _frequency1 = frequency1;
                _frequency2 = frequency2;
                _cutoffFrequency1 = cutoffFrequency1;
                _cutoffFrequency2 = cutoffFrequency2;
                _feedback1 = feedback1;
                _feedback2 = feedback2;
        
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
            _audioSource = audioSource;
            
    // Default Values   
            _frequency1 = akp(5000);        
            _frequency2 = akp(2000);        
            _cutoffFrequency1 = akp(3000);        
            _cutoffFrequency2 = akp(1500);        
            _feedback1 = akp(0.25);        
            _feedback2 = akp(0.25);            
    }
    return self;
}

+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource
 {
    return [[AKBeatenPlate alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalFrequency1:(AKParameter *)frequency1 {
    _frequency1 = frequency1;
}

- (void)setOptionalFrequency2:(AKParameter *)frequency2 {
    _frequency2 = frequency2;
}

- (void)setOptionalCutoffFrequency1:(AKControl *)cutoffFrequency1 {
    _cutoffFrequency1 = cutoffFrequency1;
}

- (void)setOptionalCutoffFrequency2:(AKControl *)cutoffFrequency2 {
    _cutoffFrequency2 = cutoffFrequency2;
}

- (void)setOptionalFeedback1:(AKControl *)feedback1 {
    _feedback1 = feedback1;
}

- (void)setOptionalFeedback2:(AKControl *)feedback2 {
    _feedback2 = feedback2;
}

- (NSString *)stringForCSD {
        return [NSString stringWithFormat:
            @"%@ wguide2 %@, %@, %@, %@, %@, %@, %@",
            self,
            _audioSource,
            _frequency1,
            _frequency2,
            _cutoffFrequency1,
            _cutoffFrequency2,
            _feedback1,
            _feedback2];
}


@end
