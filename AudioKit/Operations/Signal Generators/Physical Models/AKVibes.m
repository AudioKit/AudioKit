//
//  AKVibes.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vibes:
//  http://www.csounds.com/manual/html/vibes.html
//

#import "AKVibes.h"
#import "AKManager.h"
#import "AKSoundFileTable.h"

@implementation AKVibes

- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKParameter *)amplitude
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                tremoloShapeTable:(AKFTable *)tremoloShapeTable
                 tremoloFrequency:(AKParameter *)tremoloFrequency
                 tremoloAmplitude:(AKParameter *)tremoloAmplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _amplitude = amplitude;
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
        _amplitude = akp(1.0);    
        _stickHardness = akp(0.5);    
        _strikePosition = akp(0.2);    
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

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
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
- (void)setOptionalTremoloFrequency:(AKParameter *)tremoloFrequency {
    _tremoloFrequency = tremoloFrequency;
}
- (void)setOptionalTremoloAmplitude:(AKParameter *)tremoloAmplitude {
    _tremoloAmplitude = tremoloAmplitude;
}

- (NSString *)stringForCSD {
    NSString *file;
    if ([[[AKManager sharedManager] fullPathToAudioKit] isKindOfClass:[NSString class]]) {
        file = [[AKManager sharedManager] fullPathToAudioKit];
        file = [file stringByAppendingPathComponent:@"AudioKit/Operations/Signal Generators/Physical Models/Marimba/marmstk1.wav"];
    } else {
        file = [[NSBundle mainBundle] pathForResource:@"marmstk1" ofType:@"wav"];
    }
    NSLog(@"file %@", file);
    AKSoundFileTable *_strikeImpulseTable;
    _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];

    AKSoundFileTable *fileTable;
    fileTable = [[AKSoundFileTable alloc] initWithFilename:file];
            
    AKConstant *_maximumDuration = akp(1);        
    return [NSString stringWithFormat:
            @"%@\n"
            @"%@ vibes AKControl(%@), AKControl(%@), %@, %@, %@, AKControl(%@), AKControl(%@), %@, %@",
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
