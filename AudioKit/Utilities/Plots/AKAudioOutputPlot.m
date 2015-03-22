//
//  AKAudioOutputPlot.m
//  AudioKIt
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioOutputPlot.h"
#import "AKFoundation.h"

@interface AKAudioOutputPlot()
{
    NSData *outSamples;
    MYFLT *samples;
    int sampleSize;
    MYFLT *history;
    int historySize;
    int index;
    CsoundObj *cs;
}
@end

@implementation AKAudioOutputPlot

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

#if TARGET_OS_IPHONE
#define AKColor UIColor
#elif TARGET_OS_MAC
#define AKColor NSColor
#endif

- (void)drawWithColor:(AKColor *)color lineWidth:(float)width
{
    int plotPoints = sampleSize / 2;
    // Draw waveform
#if TARGET_OS_IPHONE
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
#elif TARGET_OS_MAC
    NSBezierPath *wavePath = [NSBezierPath bezierPath];
#endif
    
    CGFloat yScale  = self.bounds.size.height / 2;
    
    CGFloat deltaX = (self.frame.size.width / plotPoints);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    for (int i = 0; i < plotPoints; i++) {
        y = CLAMP(y, -1.0f, 1.0f);
        y = (samples[(i * 2)]+1.0) * yScale;
        if (i == 0) {
            [wavePath moveToPoint:CGPointMake(x, y)];
        } else {
#if TARGET_OS_IPHONE
            [wavePath addLineToPoint:CGPointMake(x, y)];
#elif TARGET_OS_MAC
            [wavePath lineToPoint:CGPointMake(x, y)];
#endif
        }
        x += deltaX;
    };
    
    [wavePath setLineWidth:width];
    [color setStroke];
    [wavePath stroke];
}

//        y = CLAMP(samples[i*2], -1.0f, 1.0f);
//        y = self.bounds.size.height * (y + 1.0) / 2.0;

- (void)drawRect:(CGRect)rect {
    [self drawWithColor:[AKColor greenColor] lineWidth:4.0];
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
    outSamples = [cs getOutSamples];
    samples = (MYFLT *)[outSamples bytes];

    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];

}


@end
