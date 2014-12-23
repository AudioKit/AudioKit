//
//  AKBallWithinTheBoxReverb.m
//  AudioKit
//
//  Auto-generated on 12/19/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's babo:
//  http://www.csounds.com/manual/html/babo.html
//

#import "AKBallWithinTheBoxReverb.h"
#import "AKManager.h"

@implementation AKBallWithinTheBoxReverb
{
    AKAudio *_audioSource;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                  lengthOfXAxisEdge:(AKConstant *)lengthOfXAxisEdge
                  lengthOfYAxisEdge:(AKConstant *)lengthOfYAxisEdge
                  lengthOfZAxisEdge:(AKConstant *)lengthOfZAxisEdge
                          xLocation:(AKControl *)xLocation
                          yLocation:(AKControl *)yLocation
                          zLocation:(AKControl *)zLocation
                          diffusion:(AKConstant *)diffusion
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        _lengthOfXAxisEdge = lengthOfXAxisEdge;
        _lengthOfYAxisEdge = lengthOfYAxisEdge;
        _lengthOfZAxisEdge = lengthOfZAxisEdge;
        _xLocation = xLocation;
        _yLocation = yLocation;
        _zLocation = zLocation;
        _diffusion = diffusion;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _audioSource = audioSource;
        // Default Values
        _lengthOfXAxisEdge = akp(14.39);    
        _lengthOfYAxisEdge = akp(11.86);    
        _lengthOfZAxisEdge = akp(10);    
        _xLocation = akp(6);    
        _yLocation = akp(4);    
        _zLocation = akp(3);    
        _diffusion = akp(1);
    }
    return self;
}

+ (instancetype)stereoaudioWithAudioSource:(AKAudio *)audioSource
{
    return [[AKBallWithinTheBoxReverb alloc] initWithAudioSource:audioSource];
}

- (void)setOptionalLengthOfXAxisEdge:(AKConstant *)lengthOfXAxisEdge {
    _lengthOfXAxisEdge = lengthOfXAxisEdge;
}
- (void)setOptionalLengthOfYAxisEdge:(AKConstant *)lengthOfYAxisEdge {
    _lengthOfYAxisEdge = lengthOfYAxisEdge;
}
- (void)setOptionalLengthOfZAxisEdge:(AKConstant *)lengthOfZAxisEdge {
    _lengthOfZAxisEdge = lengthOfZAxisEdge;
}
- (void)setOptionalXLocation:(AKControl *)xLocation {
    _xLocation = xLocation;
}
- (void)setOptionalYLocation:(AKControl *)yLocation {
    _yLocation = yLocation;
}
- (void)setOptionalZLocation:(AKControl *)zLocation {
    _zLocation = zLocation;
}
- (void)setOptionalDiffusion:(AKConstant *)diffusion {
    _diffusion = diffusion;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ babo %@, %@, %@, %@, %@, %@, %@, %@",
            self,
            _audioSource,
            _xLocation,
            _yLocation,
            _zLocation,
            _lengthOfXAxisEdge,
            _lengthOfYAxisEdge,
            _lengthOfZAxisEdge,
            _diffusion];
}

@end
