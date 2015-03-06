//
//  AKAudioInputView.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioInputView.h"
#import "AKFoundation.h"

@interface AKAudioInputView()
{
    NSData *inSamples;
    MYFLT *samples;
    int sampleSize;
    CsoundObj *cs;
}
@end

@implementation AKAudioInputView

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

- (void)drawWithColor:(UIColor *)color lineWidth:(float)width
{
    // Draw waveform
    UIBezierPath *waveformPath = [UIBezierPath bezierPath];
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    for (int i = 0; i < sampleSize/2; i++) {
        y = CLAMP(samples[i*2], -1.0f, 1.0f);
        y = self.bounds.size.height * (y + 1.0) / 2.0;

        if (i == 0) {
            [waveformPath moveToPoint:CGPointMake(x, y)];
        } else {
            [waveformPath addLineToPoint:CGPointMake(x, y)];
        }
        x += (self.frame.size.width / (sampleSize/2));
    };
    
    [waveformPath setLineWidth:width];
    [color setStroke];
    [waveformPath stroke];
}

- (void)drawRect:(CGRect)rect {
    [self drawWithColor:[UIColor yellowColor] lineWidth:4.0];
}

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
}

- (void)updateValuesFromCsound
{
    inSamples = [cs getInSamples];
    samples = (MYFLT *)[inSamples bytes];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}


@end
