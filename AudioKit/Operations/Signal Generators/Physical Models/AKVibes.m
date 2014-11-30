//
//  AKVibes.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vibes:
//  http://www.csounds.com/manual/html/vibes.html
//

#import "AKVibes.h"
#import "AKManager.h"

@implementation AKVibes

- (instancetype)initWithFrequency:(AKControl *)frequency
                  maximumDuration:(AKConstant *)maximumDuration
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                tremoloShapeTable:(AKFTable *)tremoloShapeTable
                 tremoloFrequency:(AKControl *)tremoloFrequency
                 tremoloAmplitude:(AKControl *)tremoloAmplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
            _frequency = frequency;
                _maximumDuration = maximumDuration;
                _stickHardness = stickHardness;
                _strikePosition = strikePosition;
                _tremoloShapeTable = tremoloShapeTable;
                _tremoloFrequency = tremoloFrequency;
                _tremoloAmplitude = tremoloAmplitude;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        
    // Default Values   
            _frequency = akp(440);        
            _maximumDuration = akp(0.5);        
            _stickHardness = akp(0.5);        
            _strikePosition = akp(0);        
           _tremoloShapeTable = [AKManager sharedAKManager].standardSineTable;
            
            _tremoloFrequency = akp(6);        
            _tremoloAmplitude = akp(0);            
    }
    return self;
}

+ (instancetype)audio
 {
    return [[AKVibes alloc] init];
}

- (void)setOptionalFrequency:(AKControl *)frequency {
    _frequency = frequency;
}

- (void)setOptionalMaximumDuration:(AKConstant *)maximumDuration {
    _maximumDuration = maximumDuration;
}

- (void)setOptionalStickHardness:(AKConstant *)stickHardness {
    _stickHardness = stickHardness;
}

- (void)setOptionalStrikePosition:(AKConstant *)strikePosition {
    _strikePosition = strikePosition;
}

- (void)setOptionalTremoloShapeTable:(AKFTable *)tremoloShapeTable {
    _tremoloShapeTable = tremoloShapeTable;
}

- (void)setOptionalTremoloFrequency:(AKControl *)tremoloFrequency {
    _tremoloFrequency = tremoloFrequency;
}

- (void)setOptionalTremoloAmplitude:(AKControl *)tremoloAmplitude {
    _tremoloAmplitude = tremoloAmplitude;
}

- (NSString *)stringForCSD {
        // Constant Values  
        AKConstant *_amplitude = akp(1.0);    
        AKConstant *_strikeImpulseTable = akp(0);
        return [NSString stringWithFormat:
            @"%@ vibes %@, %@, %@, %@, %@, %@, %@, %@, %@",
            self,
            _amplitude,
            _frequency,
            _stickHardness,
            _strikePosition,
            _strikeImpulseTable,
            _tremoloFrequency,
            _tremoloAmplitude,
            _tremoloShapeTable,
            _maximumDuration];
}


@end
