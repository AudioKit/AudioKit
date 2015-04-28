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
    NSDate *_lastUpdate;
    
    CsoundObj *_cs;
}
@end


@implementation AKAudioRollingWaveformPlot

- (void)defaultValues
{
    [super defaultValues];
    // The plot now has a default of 1024 samples for its history (rollingHistoryLength property)
    _lastUpdate = [NSDate date];
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
    
    _sampleSize = AKSettings.settings.numberOfChannels * AKSettings.settings.samplesPerControlPeriod;
}

- (void)updateValuesFromCsound
{
    BOOL update = NO;
    if ([_lastUpdate timeIntervalSinceNow] < -self.updateInterval) {
        update = YES;
        _lastUpdate = [NSDate date];
    }
    [self updateBuffer:[self bufferWithCsound:_cs] withBufferSize:_sampleSize update:update];
}


@end
