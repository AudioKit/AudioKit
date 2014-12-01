//
//  AKVibes.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Customized by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vibes:
//  http://www.csounds.com/manual/html/vibes.html
//

#import "AKVibes.h"
#import "AKFoundation.h"

@implementation AKVibes

- (instancetype)initWithFrequency:(AKControl *)frequency
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                tremoloShapeTable:(AKFTable *)tremoloShapeTable
                 tremoloFrequency:(AKControl *)tremoloFrequency
                 tremoloAmplitude:(AKControl *)tremoloAmplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
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
        _frequency = akp(220);
        _stickHardness = akp(0.1);
        _strikePosition = akp(0.1);
        _tremoloShapeTable = [AKManager standardSineTable];
        
        _tremoloFrequency = akp(0);
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
    AKConstant *_maximumDuration = akp(1);
    NSLog(@"%@ %@", [[AKManager sharedAKManager] fullPathToAudioKit], [NSString class]);
    NSString *file;
    if ([[[AKManager sharedAKManager] fullPathToAudioKit] isKindOfClass:[NSString class]]) {
        file = [[AKManager sharedAKManager] fullPathToAudioKit];
        file = [file stringByAppendingPathComponent:@"AudioKit/Operations/Signal Generators/Physical Models/Marimba/marmstk1.wav"];
    } else {
        file = [[NSBundle mainBundle] pathForResource:@"marmstk1" ofType:@"wav"];
    }
    NSLog(@"file %@", file);
    AKSoundFileTable *_strikeImpulseTable;
    _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];
    
    return [NSString stringWithFormat:
            @"%@\n"
            @"%@ vibes %@, %@, %@, %@, %@, %@, %@, %@, %@",
            [_strikeImpulseTable stringForCSD],
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
