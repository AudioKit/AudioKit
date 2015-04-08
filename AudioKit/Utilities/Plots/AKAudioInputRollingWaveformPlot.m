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
    NSMutableData *inSamples;
    UInt32 sampleSize;
    
    CsoundObj *cs;
}
@end

@implementation AKAudioInputRollingWaveformPlot

- (void)defaultValues
{
    [super defaultValues];

    [self setRollingHistoryLength:2048];
}



- (void)drawRect:(CGRect)rect
{
    @synchronized(self) {
        [self updateBuffer:(MYFLT *)inSamples.mutableBytes withBufferSize:sampleSize];
    }
    [super drawRect:rect];
}

// -----------------------------------------------------------------------------
# pragma mark - CsoundBinding
// -----------------------------------------------------------------------------

- (void)setup:(CsoundObj *)csoundObj
{
    cs = csoundObj;

    sampleSize = AKSettings.settings.numberOfChannels * AKSettings.settings.samplesPerControlPeriod;
    
    void *samples = malloc(sampleSize * sizeof(MYFLT));
    bzero(samples, sampleSize * sizeof(MYFLT));
    inSamples = [NSMutableData dataWithBytesNoCopy:samples length:sampleSize * sizeof(MYFLT)];
}

- (void)updateValuesFromCsound
{
    @synchronized(self) {
        inSamples = [cs getMutableInSamples];
    }
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}


@end
