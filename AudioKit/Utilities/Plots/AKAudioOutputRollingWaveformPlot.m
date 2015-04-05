//
//  AKAudioOutputRollingWaveformPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioOutputRollingWaveformPlot.h"
#import "AKFoundation.h"
#import "EZAudioPlot.h"
#import "CsoundObj.h"

@interface AKAudioOutputRollingWaveformPlot() <CsoundBinding>
{
    // AudioKit sound data
    NSMutableData *outSamples;
    int sampleSize;
    
    CsoundObj *cs;
    
    EZAudioPlot *audioPlot;
}
@end

@implementation AKAudioOutputRollingWaveformPlot

- (void)defaultValues
{
    _plotColor = [AKColor yellowColor];
    
    audioPlot = [[EZAudioPlot alloc] initWithFrame:self.frame];
    audioPlot.bounds = self.bounds;
    audioPlot.frame = self.frame;
    [audioPlot setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    audioPlot.backgroundColor = [AKColor blackColor];
    
    audioPlot.color = self.plotColor;
    audioPlot.shouldFill   = YES;
    audioPlot.shouldMirror = YES;
    [audioPlot setRollingHistoryLength:4096];
    [self addSubview:audioPlot];
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

- (void)setPlotColor:(AKColor *)plotColor
{
    _plotColor = plotColor;
    dispatch_async(dispatch_get_main_queue(),^{
        audioPlot.color = plotColor;
    });
}

- (void)updateValuesFromCsound
{
    @synchronized(self) {
        outSamples = [cs getMutableOutSamples];
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
        @synchronized(self) {
            [audioPlot updateBuffer:(MYFLT *)outSamples.mutableBytes withBufferSize:sampleSize];
        }
    });
}


@end
