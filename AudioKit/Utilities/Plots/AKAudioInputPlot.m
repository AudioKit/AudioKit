//
//  AKAudioInputPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
#import "CsoundObj.h"
#import "AKFoundation.h"
#import "AKSettings.h"
#import "AKAudioInputPlot.h"

@implementation AKAudioInputPlot

- (void) defaultValues
{
    [super defaultValues];
    self.lineColor = [AKColor yellowColor];
}

- (NSData *)bufferWithCsound:(CsoundObj *)cs
{
    return [cs getInSamples];
}

@end
