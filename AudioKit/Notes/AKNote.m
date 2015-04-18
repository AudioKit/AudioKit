//
//  AKNote.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKNote.h"
#import "AKManager.h"

@implementation AKNote
{
    int _myID;
    NSMutableArray *propOrder;
    BOOL isPlaying;
    float playbackDelay;
}

static int currentID = 1;

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

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
        playbackDelay = 0;
        
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

- (void)setInstrument:(AKInstrument *)instr
{
    _instrument = instr;
    if (_instrument.noteProperties.count == 0) {
        [_instrument addNoteProperty:_duration];
    }
}

- (instancetype)initWithInstrument:(AKInstrument *)anInstrument
{
    return [self initWithInstrument:anInstrument forDuration:-1];
}

- (void)updateProperties
{
    if (isPlaying) {
        [[AKManager sharedManager] updateNote:self];
    }
}

- (void)updatePropertiesAfterDelay:(float)time
{
    playbackDelay = time;
    [self updateProperties];
}

// -----------------------------------------------------------------------------
#  pragma mark - Properties and Property Management
// -----------------------------------------------------------------------------

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
- (AKNoteProperty *)createPropertyWithValue:(float)value
                                    minimum:(float)minimum
                                    maximum:(float)maximum
{
    AKNoteProperty *property = [[AKNoteProperty alloc] initWithValue:value minimum:minimum maximum:maximum];
    [self addProperty:property];
    return property;
}



// -----------------------------------------------------------------------------
#  pragma mark - Playback Controls
// -----------------------------------------------------------------------------


- (void)play
{
    [[AKManager sharedManager] updateNote:self];
    isPlaying = YES;
}

- (void)playAfterDelay:(float)delay
{
    playbackDelay = delay;
    [self play];
}

- (void)stop
{
    [[AKManager sharedManager] stopNote:self];
    isPlaying = NO;
}
- (void)stopAfterDelay:(float)delay
{
    playbackDelay = delay;
    [self stop];
}

- (NSString *)stringForCSD;
{
    float eventNumber  = [_instrument instrumentNumber] + _myID/100000.0;
    NSMutableString *scoreLine = [NSMutableString stringWithFormat:@"i %0.5f %f %f", eventNumber, playbackDelay, _duration.value];
    for (NSString *key in propOrder) {
        AKNoteProperty *prop = _properties[key];
        [scoreLine appendFormat:@" %f", [prop value]];
    }
    return [NSString stringWithFormat:@"%@",scoreLine];
}

- (NSString *)stopStringForCSD;
{
    float eventNumber  = [_instrument instrumentNumber] + _myID/100000.0;
    NSString *scoreLine = [NSString stringWithFormat:@"i -%0.5f %f 0.1", eventNumber, playbackDelay];
    return [NSString stringWithFormat:@"%@",scoreLine];
}

@end
