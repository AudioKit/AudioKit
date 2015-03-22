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

- (id)init
{
    self = [super init];
    if (self) {
        index = 0;
        historySize = 64;
        history = (float *)malloc(historySize * sizeof(float));
    }
    return self;
}

- (instancetype)initWithMinimum:(float)minimum
                      maximum:(float)maximum;
{
    self = [self init];
    if (self) {
        _minimum = minimum;
        _maximum = maximum;
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
    
    [self drawWithColor:[AKColor blueColor] width:4.0];
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
