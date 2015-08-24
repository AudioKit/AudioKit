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
    float *_history;
    int _historySize;
    int _index;
}

- (void)defaultValues
{
    _index = 0;
    _historySize = 64;
    _history = malloc(_historySize * sizeof(float));
    bzero(_history, _historySize * sizeof(float));
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
    free(_history);
}

- (void)drawRect:(CGRect)rect
{
#if !TARGET_OS_IPHONE
    [self.backgroundColor setFill];
    NSRectFill(rect);
#endif
    // Draw waveform
    AKBezierPath *wavePath = [AKBezierPath bezierPath];
    
    CGFloat yScale  =  self.bounds.size.height / (_maximum - _minimum);
    
    CGFloat deltaX = (self.frame.size.width / _historySize);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    BOOL first = YES;
    for (int i = _index; i < _index+_historySize; i++) {
        
        y = self.bounds.size.height - (_history[i % _historySize] - _minimum) * yScale;
        y = AK_CLAMP(y, 0.0, self.bounds.size.height);
        
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
    
    [wavePath setLineWidth:self.lineWidth];
    [self.lineColor setStroke];
    [wavePath stroke];
}

- (void)updateWithValue:(float)value
{
    _history[_index ++] = value;
    if (_index >= _historySize)
        _index = 0;
    [self updateUI];
}

@end
