//
//  AKAudioOutputRollingWaveformPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"
#import "AKAudioOutputRollingWaveformPlot.h"

@implementation AKAudioOutputRollingWaveformPlot

- (const float *)bufferWithCsound:(CsoundObj *)cs
{
    return [cs getOutSamples].bytes;
}

@end
