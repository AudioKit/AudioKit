//
//  Oscillator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "Oscillator.h"

@implementation Oscillator

-(id) initWithFunctionStatement:(CSDFunctionStatement *)f {
    self = [super init];
    if (self) {
        functionStatement = f;
    }
    return self;
}

-(NSString *) textForOrchestra {
    return [NSString stringWithFormat:@"\
    aOut1 oscil 1, p4, %i\
    out aOut1", [functionStatement integerIdentifier]  ];
}

-(void) playNoteForDuration:(float)dur withFrequency:(float)freq {
    NSString * note = [NSString stringWithFormat:@"%0.2f 0.2f", dur, freq];
    [[CSDManager sharedCSDManager] playNote:note];
}

@end
