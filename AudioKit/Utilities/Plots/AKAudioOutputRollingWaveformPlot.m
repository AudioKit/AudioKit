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
    NSData *outSamples;
    int sampleSize;
    
    CsoundObj *cs;
    
    EZAudioPlot *audioPlot;
}
@end

@implementation AKAudioOutputRollingWaveformPlot

- (void)defaultValues
{
    _plotColor = [AKColor yellowColor];
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
    outSamples = [NSData dataWithBytesNoCopy:samples length:sampleSize*sizeof(MYFLT)];
    
    audioPlot = [[EZAudioPlot alloc] initWithFrame:self.frame];
    audioPlot.backgroundColor = [AKColor blackColor];
    [self addSubview:audioPlot];
    
    audioPlot.color = self.plotColor;
    audioPlot.shouldFill   = YES;
    audioPlot.shouldMirror = YES;
    [audioPlot setRollingHistoryLength:4096];
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
    outSamples = [cs getOutSamples];
    
    dispatch_async(dispatch_get_main_queue(),^{
        audioPlot.bounds = self.bounds;
        audioPlot.frame = self.frame;
        [audioPlot setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
        [audioPlot updateBuffer:(MYFLT *)outSamples.bytes withBufferSize:sampleSize];
    });
}


@end
