//
//  AKNote.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKNote.h"
#import "AKManager.h"

@implementation AKNote
{
    int _myID;
    NSMutableArray *propOrder;
    BOOL isPlaying;
}

static int currentID = 1;
+ (void)resetID { currentID = 1; }

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (currentID > 99000) {
            [AKNote resetID];
        }
        _myID = currentID++;
        
        isPlaying = NO;
        _duration = [AKNoteProperty duration];
        [self addProperty:_duration];
        
        _properties = [[NSMutableDictionary alloc] init];
        propOrder = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithInstrument:(AKInstrument *)anInstrument
                       forDuration:(float)noteDuration {
    self = [self init];
    if (self) {
        _instrument = anInstrument;
        _duration.value = noteDuration;
    }
    return self;
}

- (void)setInstrument:(AKInstrument *)instr {
    _instrument = instr;
    [_instrument addNoteProperty:_duration];
}

- (instancetype)initWithInstrument:(AKInstrument *)anInstrument {
    return [self initWithInstrument:anInstrument forDuration:-1];
}

- (void)updateProperties {
    if (isPlaying) {
        [[AKManager sharedAKManager] updateNote:self];
    }
}

- (void)play {
    [[AKManager sharedAKManager] updateNote:self];
    isPlaying = YES;
}

- (void)stop {
    [[AKManager sharedAKManager] stopNote:self];
    isPlaying = NO;
}

- (NSString *)stringForCSD;
{
    float eventNumber  = [_instrument instrumentNumber] + _myID/100000.0;
    NSMutableString *scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 %f", eventNumber, _duration.value];
    for (NSString *key in propOrder) {
        AKNoteProperty *prop = _properties[key];
        [scoreLine appendFormat:@" %f", [prop value]];
    }
    return [NSString stringWithFormat:@"%@",scoreLine];
}

- (NSString *)stopStringForCSD;
{
    float eventNumber  = [_instrument instrumentNumber] + _myID/100000.0;
    NSString *scoreLine = [NSString stringWithFormat:@"i -%0.5f 0 0.1", eventNumber];
    return [NSString stringWithFormat:@"%@",scoreLine];
}

- (void) addProperty:(AKNoteProperty *)newProperty
            withName:(NSString *)name
{
    [self.properties setValue:newProperty forKey:name];
    [propOrder addObject:name];
    [newProperty setPValue:(int)propOrder.count + 3];
    [newProperty setNote:self];
}

- (void) addProperty:(AKNoteProperty *)newProperty
{
    [self addProperty:newProperty withName:[newProperty description]];
}


@end
