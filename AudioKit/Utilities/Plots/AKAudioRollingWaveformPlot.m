//
//  AKAudioRollingWaveformPlot.m
//  AudioKit
//
//  Created by Stéphane Peter on 4/23/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"
#import "AKAudioRollingWaveformPlot.h"
#import "AKSettings.h"
#import "CsoundObj.h"

@interface AKAudioRollingWaveformPlot() <CsoundBinding>
{
    // AudioKit sound data
    UInt32 _sampleSize;
    
    CsoundObj *_cs;
}
@end


@implementation AKAudioRollingWaveformPlot

- (void)defaultValues
{
}

- (void)setupPlot
{
    self.plotType = EZPlotTypeRolling;
    self.shouldFill = YES;
    self.shouldMirror = YES;
    [self setRollingHistoryLength:1024];
}

- (const float *)bufferWithCsound:(CsoundObj *)cs
{
    NSAssert(nil, @"Override the bufferWithCsound: method in subclasses.");
    return NULL;
}

// -----------------------------------------------------------------------------
# pragma mark - CsoundBinding
// -----------------------------------------------------------------------------

- (void)setup:(CsoundObj *)csoundObj
{
    _cs = csoundObj;
    
    _sampleSize = AKSettings.shared.numberOfChannels * AKSettings.shared.samplesPerControlPeriod;
}

- (void)updateValuesFromCsound
{
    [self updateBuffer:[self bufferWithCsound:_cs] withBufferSize:_sampleSize];
}


@end
