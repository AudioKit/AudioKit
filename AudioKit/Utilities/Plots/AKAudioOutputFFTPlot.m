//
//  AKAudioOutputFFTPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioOutputFFTPlot.h"
#import "CsoundObj.h"

@import Accelerate;

@implementation AKAudioOutputFFTPlot

- (NSMutableData *)bufferWithCsound:(CsoundObj *)cs
{
    return [cs getMutableOutSamples];
}

@end