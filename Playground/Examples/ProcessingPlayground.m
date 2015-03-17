//
//  ProcessingPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/11/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground

- (void) setup
{
    [super setup];
}

- (void)run
{
    [super run];
    
    AKInstrument *mic = [AKInstrument instrumentWithNumber:1];
    AKAudioInput *audioIn = [[AKAudioInput alloc] init];
    [mic connect:audioIn];
    [mic enableParameterLog:@"mic" parameter:audioIn timeInterval:1];
    [AKOrchestra addInstrument:mic];
    [mic play];
    
    [self addAudioInputPlot];
}

@end
