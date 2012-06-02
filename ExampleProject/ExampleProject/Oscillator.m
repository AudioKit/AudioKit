//
//  Oscillator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "Oscillator.h"

@implementation Oscillator
@synthesize orchestra;

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra {
    self = [super init];
    if (self) {
        orchestra = newOrchestra;
        instrumentNumberInOrchestra = [orchestra addInstrument:self];
    }
    return self;
}

-(NSString *) textForOrchestra {
    NSString * text=  @"iSine ftgen 0, 0, 8192, 10, 1\n"\
                       "aOut1 oscil 0.4, p4, iSine\n"\
                       "out aOut1";
    return text;
}

-(void) playNoteForDuration:(float)dur withFrequency:(float)freq {
    NSString * note = [NSString stringWithFormat:@"%0.2f %0.2f", dur, freq];
    [[CSDManager sharedCSDManager] playNote:note OnInstrument:instrumentNumberInOrchestra];
}

@end
