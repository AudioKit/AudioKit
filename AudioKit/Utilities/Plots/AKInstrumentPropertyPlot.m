//
//  AKInstrumentPropertyPlot.m
//  AudioKIt
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrumentPropertyPlot.h"
#import "AKFoundation.h"
#import "CsoundObj.h"

@interface AKInstrumentPropertyPlot () <CsoundBinding>

@end

@implementation AKInstrumentPropertyPlot
{
    MYFLT *history;
    int historySize;
    int index;
}

- (void)defaultValues
{
    index = 0;
    historySize = 512;
    history = (MYFLT *)malloc(historySize * sizeof(MYFLT));
    bzero(history, historySize * sizeof(MYFLT));
    _lineWidth = 4.0f;
    _lineColor = [AKColor blueColor];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultValues];
    }
    return self;
}

- (instancetype)initWithProperty:(AKInstrumentProperty *)property;
{
    self = [self init];
    if (self) {
        _property = property;
    }
    return self;
}

- (void)dealloc
{
    free(history);
}

- (void)drawWithColor:(AKColor *)color width:(float)width
{
    // Draw waveform
    AKBezierPath *waveformPath = [AKBezierPath bezierPath];
    
    CGFloat yMin = self.property.minimum;
    CGFloat yScale  =  self.bounds.size.height / (self.property.maximum - self.property.minimum);
    
    CGFloat deltaX = (self.frame.size.width / historySize);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    for (int i = index; i < index+historySize; i++) {
        
        y = self.bounds.size.height - (history[i % historySize] - yMin) * yScale;
        y = AK_CLAMP(y, 0.0, self.bounds.size.height);
        if (x != x || y != y) {
            NSLog(@"Something is not a number");
        } else {
            if (i == index) {
                [waveformPath moveToPoint:CGPointMake(x, y)];
            } else {
#if TARGET_OS_IPHONE
                [waveformPath addLineToPoint:CGPointMake(x, y)];
#elif TARGET_OS_MAC
                [waveformPath lineToPoint:CGPointMake(x, y)];
#endif
            }
        }
        x += deltaX;
    };
    
    [waveformPath setLineWidth:width];
    [color setStroke];
    [waveformPath stroke];
}

- (void)drawRect:(CGRect)rect {
    [self drawWithColor:self.lineColor width:self.lineWidth];
}

// -----------------------------------------------------------------------------
# pragma mark - CsoundBinding
// -----------------------------------------------------------------------------

- (void)setup:(CsoundObj *)csoundObj
{
    if ([[AKManager sharedManager] isLogging]) {
        NSLog(@"Setting up plot for %@", _property);
    }
}

- (void)updateValuesFromCsound
{
    if (_plottedValue) {
        _property = _plottedValue;
    }
    history[index] = self.property.value;
    index++;
    if (index >= historySize)
        index = 0;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

@end
