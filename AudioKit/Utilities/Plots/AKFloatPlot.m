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
    bzero(history, historySize * sizeof(float));
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

- (void)drawRect:(CGRect)rect
{
    // Draw waveform
    AKBezierPath *wavePath = [AKBezierPath bezierPath];
    
    CGFloat yScale  =  self.bounds.size.height / (_maximum - _minimum);
    
    CGFloat deltaX = (self.frame.size.width / historySize);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    for (int i = index; i < index+historySize; i++) {
        
        y = self.bounds.size.height - (history[i % historySize] - _minimum) * yScale;
        y = AK_CLAMP(y, 0.0, self.bounds.size.height);
        
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
    
    [wavePath setLineWidth:self.lineWidth];
    [self.lineColor setStroke];
    [wavePath stroke];
}

- (void)updateWithValue:(float)value {
    history[index] = value;
    index++;
    if (index >= historySize)
        index = 0;
    [self updateUI];
}

@end
