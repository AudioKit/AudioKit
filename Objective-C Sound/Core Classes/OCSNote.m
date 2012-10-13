//
//  OCSNote.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSNote.h"
#import "OCSManager.h"

@interface OCSNote () {
    NSMutableString *scoreLine;
    int _myID;
    float eventNumber;
    NSMutableArray *propOrder;
    BOOL isPlayingP;
}
@end


@implementation OCSNote

@synthesize instrument;
@synthesize properties;
@synthesize eventNumber;
@synthesize duration;

static int currentID = 1;
+ (void)resetID { currentID = 1; }

- (id)initWithInstrument:(OCSInstrument *)anInstrument
             forDuration:(float)noteDuration {
    self = [super init];
    if (self) {
        if (currentID > 99000) {
            [OCSNote resetID];
        }
        _myID = currentID++;
        
        isPlayingP = NO;
        instrument = anInstrument;
        duration = [[OCSNoteProperty alloc] initWithMinValue:-2 maxValue:1000000];
        [self addProperty:duration withName:@"Duration"];
        [instrument addNoteProperty:duration];
        duration.value = noteDuration;
        properties = [[NSMutableDictionary alloc] init];
        propOrder = [[NSMutableArray alloc] init];
        eventNumber  = [instrument instrumentNumber] + _myID/100000.0;
        scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 %@",
                     eventNumber, duration];
    }
    return self;
}

- (id)initWithInstrument:(OCSInstrument *)anInstrument {
    return [self initWithInstrument:anInstrument forDuration:-1];
}

- (void)updateProperties {
    if (isPlayingP) {
        [[OCSManager sharedOCSManager] updateNote:self];
    }
}

- (void)play {
    [[OCSManager sharedOCSManager] updateNote:self];
    isPlayingP = YES;
}

- (void)stop {
    [[OCSManager sharedOCSManager] stopNote:self];
    isPlayingP = NO;
}

- (NSString *)stringForCSD;
{
    scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 %f", eventNumber, duration.value];
    for (NSString* key in propOrder) {
        OCSNoteProperty *prop = [properties objectForKey:key];
        [scoreLine appendFormat:@" %f", [prop value]];
    }
    return [NSString stringWithFormat:@"%@",scoreLine];
}

- (NSString *)stopStringForCSD;
{
    scoreLine = [NSMutableString stringWithFormat:@"i -%0.5f 0 0.1", eventNumber];
    return [NSString stringWithFormat:@"%@",scoreLine];
}

- (void) addProperty:(OCSNoteProperty *)newProperty
            withName:(NSString *)name
{
    // AOP the name functionality may not be working
    [self.properties setValue:newProperty forKey:name];
    [propOrder addObject:name];
    [newProperty setPValue:propOrder.count +3];
    [newProperty setNote:self];
}

- (void) addProperty:(OCSNoteProperty *)newProperty
{
    [self addProperty:newProperty withName:[newProperty description]];
}


@end
