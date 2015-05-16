//
//  AKStereoOutputPlot.m
//  AudioKIt
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoOutputPlot.h"
#import "AKFoundation.h"
#import "AKSettings.h"
#import "CsoundObj.h"

@interface AKStereoOutputPlot() <CsoundBinding>
{
    NSData *_outSamples;
    UInt32 _sampleSize;
    int    _index;
    CsoundObj *_cs;
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
    int plotPoints = _sampleSize / 2;
    // Draw waveform
    AKBezierPath *wavePath = [AKBezierPath bezierPath];
    
    CGFloat yOffset = self.bounds.size.height * offset;
    CGFloat yScale  = self.bounds.size.height / 4;
    
    CGFloat deltaX = (self.frame.size.width / plotPoints);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    
    @synchronized(self) {
        const float *samples = _outSamples.bytes;
        BOOL first = YES;
        for (int i = 0; i < plotPoints; i++) {
            y = AK_CLAMP(y, -1.0f, 1.0f);
            y = samples[(i * 2) + channel] * yScale + yOffset;
            if (isfinite(y)) {
                if (first) {
                    [wavePath moveToPoint:CGPointMake(x, y)];
                    first = NO;
                } else {
#if TARGET_OS_IPHONE
                    [wavePath addLineToPoint:CGPointMake(x, y)];
#elif TARGET_OS_MAC
                    [wavePath lineToPoint:CGPointMake(x, y)];
#endif
                }
            }
            x += deltaX;
        }
    }
    
    [wavePath setLineWidth:width];
    [color setStroke];
    [wavePath stroke];
}

- (void)drawRect:(CGRect)rect
{
#if !TARGET_OS_IPHONE
    [self.backgroundColor setFill];
    NSRectFill(rect);
#endif
    if (_sampleSize) { // Csound may not be setup yet
        [self drawChannel:0 offset:0.25 color:self.leftLineColor    width:self.lineWidth];
        [self drawChannel:1 offset:0.75 color:self.rightLineColor   width:self.lineWidth];
    }
}

// -----------------------------------------------------------------------------
# pragma mark - CsoundBinding
// -----------------------------------------------------------------------------

- (void)setup:(CsoundObj *)csoundObj
{
    _cs = csoundObj;

    _sampleSize = AKSettings.shared.numberOfChannels * AKSettings.shared.samplesPerControlPeriod;
    
    void *samples = malloc(_sampleSize * sizeof(float));
    bzero(samples, _sampleSize * sizeof(float));
    _outSamples = [NSData dataWithBytesNoCopy:samples length:_sampleSize * sizeof(float)];
}

- (void)updateValuesFromCsound
{
    @synchronized(self) {
        _outSamples = [_cs getOutSamples];
    }
    
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}


@end
