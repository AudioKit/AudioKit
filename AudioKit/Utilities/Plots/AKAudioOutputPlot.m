//
//  AKAudioOutputPlot.m
//  AudioKIt
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioOutputPlot.h"
#import "AKFoundation.h"
#import "CsoundObj.h"

@interface AKAudioOutputPlot() <CsoundBinding>
{
    NSData *outSamples;
    int sampleSize;
    int index;
    CsoundObj *cs;
}
@end

@implementation AKAudioOutputPlot

- (void)defaultValues
{
    _lineWidth = 4.0f;
    _lineColor = [AKColor greenColor];
}

- (void)drawRect:(CGRect)rect
{
    int plotPoints = sampleSize / 2;
    // Draw waveform
    AKBezierPath *wavePath = [AKBezierPath bezierPath];
    
    CGFloat yScale  = self.bounds.size.height / 2;
    
    CGFloat deltaX = (self.frame.size.width / plotPoints);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    
    @synchronized(self) {
        const MYFLT *samples = (const MYFLT *)outSamples.bytes;
        for (int i = 0; i < plotPoints; i++) {
            y = AK_CLAMP(y, -1.0f, 1.0f);
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
    }
    
    [wavePath setLineWidth:self.lineWidth];
    [self.lineColor setStroke];
    [wavePath stroke];
}

//        y = AK_CLAMP(samples[i*2], -1.0f, 1.0f);
//        y = self.bounds.size.height * (y + 1.0) / 2.0;

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
    outSamples = [NSData dataWithBytesNoCopy:samples length:sampleSize * sizeof(MYFLT)];
}

- (void)updateValuesFromCsound
{
    @synchronized(self) {
        outSamples = [cs getOutSamples];
    }

    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}


@end
