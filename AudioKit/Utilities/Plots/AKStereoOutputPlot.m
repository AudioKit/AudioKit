//
//  AKAudioOutputPlot.m
//  AudioKIt
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoOutputPlot.h"
#import "AKFoundation.h"

@interface AKStereoOutputPlot()
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

@implementation AKStereoOutputPlot

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

- (void)drawChannel:(int)channel offset:(float)offset color:(UIColor *)color width:(float)width
{
    int plotPoints = sampleSize / 2;
    // Draw waveform
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
    
    CGFloat yOffset = self.bounds.size.height * offset;
    CGFloat yScale  = self.bounds.size.height / 4;
    
    CGFloat deltaX = (self.frame.size.width / plotPoints);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    for (int i = 0; i < plotPoints; i++) {
        y = CLAMP(y, -1.0f, 1.0f);
        y = samples[(i * 2) + channel] * yScale + yOffset;
        if (i == 0) {
            [wavePath moveToPoint:CGPointMake(x, y)];
        } else {
            [wavePath addLineToPoint:CGPointMake(x, y)];
        }
        x += deltaX;
    };
    
    [wavePath setLineWidth:width];
    [color setStroke];
    [wavePath stroke];
}

- (void)drawRect:(CGRect)rect {
    [self drawChannel:0 offset:0.25 color:[UIColor greenColor] width:4.0];
    [self drawChannel:1 offset:0.75 color:[UIColor redColor]   width:4.0];
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
