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
}
@end


@implementation OCSNote

@synthesize instrument;
@synthesize properties;
@synthesize eventNumber;

static int currentID = 1;
+ (void)resetID { currentID = 1; }

- (id)initWithInstrument:(OCSInstrument *)anInstrument {
    self = [super init];
    if (self) {
        if (currentID > 99000) {
            [OCSEvent resetID];
        }
        _myID = currentID++;
        
        instrument = anInstrument;
        properties = [[NSMutableDictionary alloc] init];
        propOrder = [[NSMutableArray alloc] init];
        eventNumber  = [instrument instrumentNumber] + _myID/100000.0;
        scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 -1", eventNumber];
    }
    return self;
}

- (void)play {
    [[OCSManager sharedOCSManager] updateNote:self];
}

- (void)kill {
    [[OCSManager sharedOCSManager] killNote:self];
}

- (void)updateProperties {
    [[OCSManager sharedOCSManager] updateNote:self];
}

- (NSString *)stringForCSD;
{
    scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 -1", eventNumber];
    for (NSString* key in propOrder) {
        OCSNoteProperty *prop = [properties objectForKey:key];
        [scoreLine appendFormat:@" %f", [prop value]];
    }
    return [NSString stringWithFormat:@"%@",scoreLine];
}

- (NSString *)killStringForCSD;
{
    scoreLine = [NSMutableString stringWithFormat:@"i -%0.5f 0 0.1", eventNumber];
    return [NSString stringWithFormat:@"%@",scoreLine];
}

- (void) addProperty:(OCSNoteProperty *)newProperty
            withName:(NSString *)name
{
    [newProperty setConstant:[OCSConstant parameterWithString:name]];
    [self.properties setValue:newProperty forKey:name];
    [propOrder addObject:name];
}


@end
