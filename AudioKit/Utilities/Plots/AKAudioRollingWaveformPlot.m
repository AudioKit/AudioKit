//
//  AKAudioRollingWaveformPlot.m
//  AudioKit
//
//  Created by Stéphane Peter on 4/23/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKAudioRollingWaveformPlot.h"
#import "AKFoundation.h"
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
    
    [self setRollingHistoryLength:2048];
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
    [self updateBuffer:[self bufferWithCsound:_cs] withBufferSize:_sampleSize];
    if ([_lastUpdate timeIntervalSinceNow] < -self.updateInterval) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
            _lastUpdate = [NSDate date];
        });
    }
}


@end
