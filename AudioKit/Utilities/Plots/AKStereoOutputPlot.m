//
//  AKStereoOutputPlot.m
//  AudioKIt
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoOutputPlot.h"
#import "AKFoundation.h"
#import "CsoundObj.h"

@interface AKStereoOutputPlot() <CsoundBinding>
{
    NSData *outSamples;
    int sampleSize;
    int index;
    CsoundObj *cs;
}
@end

@implementation AKStereoOutputPlot

- (void)defaultValues
{
    _lineWidth = 4.0f;
    _leftLineColor = [AKColor greenColor];
    _rightLineColor = [AKColor redColor];
}

- (void)drawChannel:(int)channel offset:(float)offset color:(AKColor *)color width:(CGFloat)width
{
    int plotPoints = sampleSize / 2;
    // Draw waveform
    AKBezierPath *wavePath = [AKBezierPath bezierPath];
    
    CGFloat yOffset = self.bounds.size.height * offset;
    CGFloat yScale  = self.bounds.size.height / 4;
    
    CGFloat deltaX = (self.frame.size.width / plotPoints);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    
    @synchronized(self) {
        const MYFLT *samples = (const MYFLT *)outSamples.bytes;
        
        for (int i = 0; i < plotPoints; i++) {
            y = AK_CLAMP(y, -1.0f, 1.0f);
            y = samples[(i * 2) + channel] * yScale + yOffset;
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
        }
    }
    
    [wavePath setLineWidth:width];
    [color setStroke];
    [wavePath stroke];
}

- (void)drawRect:(CGRect)rect {
    [self drawChannel:0 offset:0.25 color:self.leftLineColor    width:self.lineWidth];
    [self drawChannel:1 offset:0.75 color:self.rightLineColor   width:self.lineWidth];
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
