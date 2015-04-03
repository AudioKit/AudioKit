//
//  AKFloatPlot.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 3/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFloatPlot.h"

@implementation AKFloatPlot
{
    float *history;
    int historySize;
    int index;
}

- (void)defaultValues
{
    index = 0;
    historySize = 64;
    history = (float *)malloc(historySize * sizeof(float));
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

- (instancetype)initWithMinimum:(float)minimum
                        maximum:(float)maximum
{
    self = [self init];
    if (self) {
        _minimum = minimum;
        _maximum = maximum;
    }
    return self;
}

- (void)dealloc
{
    free(history);
}

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

- (void)drawWithColor:(AKColor *)color width:(CGFloat)width
{
    // Draw waveform
#if TARGET_OS_IPHONE
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
#elif TARGET_OS_MAC
    NSBezierPath *wavePath = [NSBezierPath bezierPath];
#endif
    
    
    CGFloat yScale  =  self.bounds.size.height / (_maximum - _minimum);
    
    CGFloat deltaX = (self.frame.size.width / historySize);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    for (int i = index; i < index+historySize; i++) {
        
        y = self.bounds.size.height - (history[i % historySize] - _minimum) * yScale;
        y = CLAMP(y, 0.0, self.bounds.size.height);
        
        if (i == index) {
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
    
    [self drawWithColor:self.lineColor width:self.lineWidth];
}

- (void)updateWithValue:(float)value {
    if (history) {
        history[index] = value;
        index++;
        if (index >= historySize) index = 0;
    } else {
        index = 0;
        historySize = 64;
        history = (float *)malloc(historySize * sizeof(float));
    }

#if TARGET_OS_IPHONE
    [self setNeedsDisplay];
#elif TARGET_OS_MAC
    [self setNeedsDisplay:YES];
#endif
    
}

@end
