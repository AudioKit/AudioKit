//
//  AKAudioPlot.m
//  AudioKit
//
//  Created by Stéphane Peter on 4/27/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKAudioPlot.h"
#import "CsoundObj.h"
#import "AKFoundation.h"
#import "AKSettings.h"

@interface AKAudioPlot() <CsoundBinding>
{
    NSData *_samples;
    UInt32 _sampleSize;
    CsoundObj *_cs;
}

@end

@implementation AKAudioPlot

- (void) defaultValues
{
    _lineWidth = 4.0f;
}

- (NSData *)bufferWithCsound:(CsoundObj *)cs
{
    NSAssert(nil, @"Override bufferWithCsound: in subclasses.");
    return nil;
}


- (void)drawRect:(CGRect)rect
{
#if !TARGET_OS_IPHONE
    [self.backgroundColor setFill];
    NSRectFill(rect);
#endif
    if (!_sampleSize)
        return;
    
    // Draw waveform
    AKBezierPath *waveformPath = [AKBezierPath bezierPath];
    @synchronized(self) {
        const float *samples = _samples.bytes;
        
        CGFloat x = 0.0f;
        CGFloat y = 0.0f;
        const UInt32 sz = _sampleSize/2;
        BOOL first = YES;
        
        for (int i = 0; i < sz; i++) {
            y = AK_CLAMP(samples[i*2], -1.0f, 1.0f);
            y = self.bounds.size.height * (y + 1.0) / 2.0;
            
            if (isfinite(y)) {
                if (first) {
                    [waveformPath moveToPoint:CGPointMake(x, y)];
                    first = NO;
                } else {
#if TARGET_OS_IPHONE
                    [waveformPath addLineToPoint:CGPointMake(x, y)];
#elif TARGET_OS_MAC
                    [waveformPath lineToPoint:CGPointMake(x, y)];
#endif
                }
            }
            x += self.frame.size.width / sz;
        }
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
    _cs = csoundObj;
    
    _sampleSize = AKSettings.shared.numberOfChannels * AKSettings.shared.samplesPerControlPeriod;
    
    void *samples = malloc(_sampleSize * sizeof(float));
    bzero(samples, _sampleSize * sizeof(float));
    _samples = [NSData dataWithBytesNoCopy:samples length:_sampleSize * sizeof(float)];
}

- (void)updateValuesFromCsound
{
    @synchronized(self) {
        _samples = [self bufferWithCsound:_cs];
    }
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

@end
