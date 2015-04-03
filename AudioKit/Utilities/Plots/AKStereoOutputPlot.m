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
    MYFLT *samples;
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
#if TARGET_OS_IPHONE
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
#elif TARGET_OS_MAC
    NSBezierPath *wavePath = [NSBezierPath bezierPath];
#endif
    
    CGFloat yOffset = self.bounds.size.height * offset;
    CGFloat yScale  = self.bounds.size.height / 4;
    
    CGFloat deltaX = (self.frame.size.width / plotPoints);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
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
    };
    
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
    samples = (MYFLT *)malloc(sampleSize * sizeof(MYFLT));
}

- (void)updateValuesFromCsound
{
    outSamples = [cs getOutSamples];
    samples = (MYFLT *)[outSamples bytes]; // FIXME: Probably memory leak

    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];

}


@end
