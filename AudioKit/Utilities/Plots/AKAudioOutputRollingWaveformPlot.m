//
//  AKAudioOutputRollingWaveformPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioOutputRollingWaveformPlot.h"
#import "AKFoundation.h"
#import "CsoundObj.h"

@interface AKAudioOutputRollingWaveformPlot() <CsoundBinding>
{
    // AudioKit sound data
    NSMutableData *outSamples;
    int sampleSize;
    
    CsoundObj *cs;
}
@end

@implementation AKAudioOutputRollingWaveformPlot

- (void)defaultValues
{
    [super defaultValues];
    
    [self setRollingHistoryLength:2048];
}

- (void)drawRect:(CGRect)rect
{
    @synchronized(self) {
        [self updateBuffer:(MYFLT *)outSamples.mutableBytes withBufferSize:sampleSize];
    }
    [super drawRect:rect];
}

// -----------------------------------------------------------------------------
# pragma mark - CsoundBinding
// -----------------------------------------------------------------------------

- (void)setup:(CsoundObj *)csoundObj
{
    cs = csoundObj;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AudioKit" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    int samplesPerControlPeriod = [dict[@"Samples Per Control Period"] intValue];
    int numberOfChannels = [dict[@"Number Of Channels"] intValue];
    sampleSize = numberOfChannels * samplesPerControlPeriod;

    void *samples = malloc(sampleSize * sizeof(MYFLT));
    bzero(samples, sampleSize * sizeof(MYFLT));
    outSamples = [NSMutableData dataWithBytesNoCopy:samples length:sampleSize*sizeof(MYFLT)];
}

- (void)updateValuesFromCsound
{
    @synchronized(self) {
        outSamples = [cs getMutableOutSamples];
    }
    
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}


@end
