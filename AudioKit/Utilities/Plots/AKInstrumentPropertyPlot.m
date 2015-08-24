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
    float *_history;
    int _historySize;
    int _index;
}

- (void)defaultValues
{
    _index = 0;
    _historySize = 512;
    _history = malloc(_historySize * sizeof(float));
    bzero(_history, _historySize * sizeof(float));
    _lineWidth = 4.0f;
    _lineColor = [AKColor blueColor];
    _connectPoints = YES;
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
    free(_history);
}

- (void)drawRect:(CGRect)rect 
{
#if !TARGET_OS_IPHONE
    [self.backgroundColor setFill];
    NSRectFill(rect);
#endif
    // Draw waveform
    AKBezierPath *waveformPath = [AKBezierPath bezierPath];
    
    CGFloat yMin = self.property.minimum;
    CGFloat yScale  =  self.bounds.size.height / (self.property.maximum - self.property.minimum);
    
    CGFloat deltaX = (self.frame.size.width / _historySize);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    
    BOOL first = YES;
    for (int i = _index; i < _index+_historySize; i++) {
        
        y = self.bounds.size.height - (_history[i % _historySize] - yMin) * yScale;
        y = AK_CLAMP(y, 0.0, self.bounds.size.height);
        if (x != x || y != y) {
            if ([[AKManager sharedManager] isLogging])
                NSLog(@"Something is not a number");
        } else {
            if (_connectPoints) {
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
            } else {
                AKBezierPath *circle = [AKBezierPath bezierPath];
                [circle moveToPoint:CGPointMake(x, y)];
#if TARGET_OS_IPHONE
                [circle addArcWithCenter:CGPointMake(x, y) radius:_lineWidth/2.0 startAngle:0 endAngle:2*M_PI clockwise:YES];
#elif TARGET_OS_MAC
                [circle appendBezierPathWithArcWithCenter:CGPointMake(x, y) radius:_lineWidth/2.0 startAngle:0 endAngle:2*M_PI clockwise:YES];
#endif
                [circle setLineWidth:_lineWidth/2.0];
                [_lineColor setStroke];
                [circle stroke];
            }
        }
        x += deltaX;
    }
    
    [waveformPath setLineWidth:_lineWidth];
    [_lineColor setStroke];
    [waveformPath stroke];
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
    if (self.plottedValue) {
        self.property = self.plottedValue;
    }
    _history[_index ++] = self.property.value;
    if (_index >= _historySize)
        _index = 0;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

@end
