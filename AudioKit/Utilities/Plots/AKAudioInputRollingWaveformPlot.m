//
//  AKAudioInputRollingWaveformPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioInputRollingWaveformPlot.h"
#import "AKFoundation.h"
#import "AKSettings.h"
#import "CsoundObj.h"

@interface AKAudioInputRollingWaveformPlot() <CsoundBinding>
{
    // AudioKit sound data
    UInt32 _sampleSize;
    NSDate *_lastUpdate;
    
    CsoundObj *_cs;
}
@end

@implementation AKAudioInputRollingWaveformPlot

- (void)defaultValues
{
    [super defaultValues];

    [self setRollingHistoryLength:2048];
    _lastUpdate = [NSDate date];
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
    [self updateBuffer:[_cs getInSamples].bytes withBufferSize:_sampleSize];
    if ([_lastUpdate timeIntervalSinceNow] < -self.updateInterval) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
            _lastUpdate = [NSDate date];
        });
    }
}


@end
