//
//  AKInstrumentPropertyPlot.m
//  AudioKIt
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrumentPropertyPlot.h"
#import "AKFoundation.h"

@implementation AKInstrumentPropertyPlot
{
    MYFLT *history;
    int historySize;
    int index;
}

- (id)init
{
    self = [super init];
    if (self) {
        index = 0;
        historySize = 512;
        history = (MYFLT *)malloc(historySize * sizeof(MYFLT));
    }
    return self;
}

- (id)initWithProperty:(AKInstrumentProperty *)property;
{
    self = [self init];
    if (self) {
        _property = property;
    }
    return self;
}

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))


#if TARGET_OS_IPHONE
#define AKColor UIColor
#elif TARGET_OS_MAC
#define AKColor NSColor
#endif

- (void)drawWithColor:(AKColor *)color width:(float)width
{
    // Draw waveform
#if TARGET_OS_IPHONE
    UIBezierPath *waveformPath = [UIBezierPath bezierPath];
#elif TARGET_OS_MAC
    NSBezierPath *waveformPath = [NSBezierPath bezierPath];
#endif
    
    CGFloat yMin = self.property.minimum;
    CGFloat yScale  =  self.bounds.size.height / (self.property.maximum - self.property.minimum);
    
    CGFloat deltaX = (self.frame.size.width / historySize);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    for (int i = index; i < index+historySize; i++) {
        
        y = self.bounds.size.height - (history[i % historySize] - yMin) * yScale;
        y = CLAMP(y, 0.0, self.bounds.size.height);
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
    [self drawWithColor:[AKColor blueColor] width:4.0];
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
    if (history) {
        if (_plottedValue) {
            _property = _plottedValue;
        }
        history[index] = self.property.value;
        index++;
        if (index >= historySize) index = 0;
        [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
    } else {
        index = 0;
        historySize = 512;
        history = (MYFLT *)malloc(historySize * sizeof(MYFLT));
    }
}

- (void)updateUI {
#if TARGET_OS_IPHONE
    [self setNeedsDisplay];
#elif TARGET_OS_MAC
    [self setNeedsDisplay:YES];
#endif
}

@end
