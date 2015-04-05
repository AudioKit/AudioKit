//
//  AKAudioInputPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
#import "CsoundObj.h"
#import "AKAudioInputPlot.h"
#import "AKFoundation.h"

@interface AKAudioInputPlot() <CsoundBinding>
{
    NSData *inSamples;
    int sampleSize;
    CsoundObj *cs;
}

@end

@implementation AKAudioInputPlot

- (void) defaultValues
{
    _lineWidth = 4.0f;
    _lineColor = [AKColor yellowColor];
}


- (void)drawRect:(CGRect)rect
{
    // Draw waveform
    AKBezierPath *waveformPath = [AKBezierPath bezierPath];
    @synchronized(self) {
        const MYFLT *samples = (const MYFLT *)inSamples.bytes;
        
        CGFloat x = 0.0f;
        CGFloat y = 0.0f;
        for (int i = 0; i < sampleSize/2; i++) {
            y = AK_CLAMP(samples[i*2], -1.0f, 1.0f);
            y = self.bounds.size.height * (y + 1.0) / 2.0;
            
            if (i == 0) {
                [waveformPath moveToPoint:CGPointMake(x, y)];
            } else {
#if TARGET_OS_IPHONE
                [waveformPath addLineToPoint:CGPointMake(x, y)];
#elif TARGET_OS_MAC
                [waveformPath lineToPoint:CGPointMake(x, y)];
#endif
                
            }
            x += (self.frame.size.width / (sampleSize/2));
        };
    }
    [waveformPath setLineWidth:self.lineWidth];
    [self.lineColor setStroke];
    [waveformPath stroke];
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
    inSamples = [NSData dataWithBytesNoCopy:samples length:sampleSize * sizeof(MYFLT)];
}

- (void)updateValuesFromCsound
{
    @synchronized(self) {
        inSamples = [cs getInSamples];
    }
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

@end
