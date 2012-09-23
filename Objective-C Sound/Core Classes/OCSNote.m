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
        eventNumber  = [instrument instrumentNumber] + _myID/100000.0;
        scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 -1", eventNumber];
    }
    return self;
}

- (void)kill
{
    [[OCSManager sharedOCSManager] killNote:self];
}

- (void)updateProperties {
    [[OCSManager sharedOCSManager] updateNote:self];
}

- (id)initDeactivation:(OCSNote *)targetNote;
{
    self = [self init];
    if (self) {
        scoreLine = [NSMutableString stringWithFormat:@"i -%0.5f 0.0 0.1",
                     [targetNote eventNumber]];
        
        // This next method uses the turnoff2 opcode which might prove advantageous
        // so I won't delete it just yet.
        //        scoreLine = [NSString stringWithFormat:@"i \"Deactivator\" %f 0.1 %0.3f\n",
        //                     delay, [event eventNumber]];
    }
    return self;
}


- (NSString *)stringForCSD;
{
    scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 -1", eventNumber];
    //NSLog(@"Count: %u", [properties count]);
    for (NSString* key in properties) {
        OCSNoteProperty *prop = [properties objectForKey:key];
        [scoreLine appendFormat:@" %f", [prop value]];
        //NSLog(@"Setting Note Property %@ to %f", key, [prop value]);
    }
    return [NSString stringWithFormat:@"%@",scoreLine];
}

- (NSString *)killStringForCSD;
{
    scoreLine = [NSMutableString stringWithFormat:@"i -%0.5f 0 0.1", eventNumber];
    return [NSString stringWithFormat:@"%@",scoreLine];
}



@end
