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

@interface AKAudioOutputRollingWaveformPlot()
{
    // AudioKit sound data
    NSData *outSamples;
    MYFLT *samples;
    int sampleSize;
    
    CsoundObj *cs;
    
    EZAudioPlot *audioPlot;
}
@end

@implementation AKAudioOutputRollingWaveformPlot

#if TARGET_OS_IPHONE
#define AKColor UIColor
#elif TARGET_OS_MAC
#define AKColor NSColor
#endif

// -----------------------------------------------------------------------------
# pragma mark - CsoundBinding
// -----------------------------------------------------------------------------

- (void)setup:(CsoundObj *)csoundObj
{
    cs = csoundObj;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AudioKit" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    int samplesPerControlPeriod = [[dict objectForKey:@"Samples Per Control Period"] intValue];
    int numberOfChannels = [[dict objectForKey:@"Number Of Channels"] intValue];
    sampleSize = numberOfChannels * samplesPerControlPeriod;
    samples = (MYFLT *)malloc(sampleSize * sizeof(MYFLT));
    
    audioPlot = [[EZAudioPlot alloc] initWithFrame:self.frame];
    audioPlot.backgroundColor = [AKColor blackColor];
    [self addSubview:audioPlot];
    
    audioPlot.color = [AKColor yellowColor];
    audioPlot.shouldFill   = YES;
    audioPlot.shouldMirror = YES;
    [audioPlot setRollingHistoryLength:4096];
}

- (void)updateValuesFromCsound
{
    outSamples = [cs getOutSamples];
    samples = (MYFLT *)[outSamples bytes];
    
    dispatch_async(dispatch_get_main_queue(),^{
        audioPlot.bounds = self.bounds;
        audioPlot.frame = self.frame;
        [audioPlot setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
        audioPlot.backgroundColor = [AKColor blackColor];
        [audioPlot updateBuffer:samples withBufferSize:sampleSize];
    });
}


@end
