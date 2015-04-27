//
//  AKAudioInputFFTPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioInputFFTPlot.h"
#import "CsoundObj.h"

@implementation AKAudioInputFFTPlot

- (NSMutableData *)bufferWithCsound:(CsoundObj *)cs
{
    return [cs getMutableInSamples];
}

@end