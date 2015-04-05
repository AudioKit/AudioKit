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
    free(history);
}

- (void)drawRect:(CGRect)rect 
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
                if (_connectPoints) {
                    [waveformPath addLineToPoint:CGPointMake(x, y)];
                } else {
                    AKBezierPath *circle = [AKBezierPath bezierPath];
                    [circle moveToPoint:CGPointMake(x, y)];
                    [circle addArcWithCenter:CGPointMake(x, y) radius:_lineWidth/2.0 startAngle:0 endAngle:2*M_PI clockwise:YES];
                    [circle setLineWidth:_lineWidth/2.0];
                    [_lineColor setStroke];
                    [circle stroke];
                }
                
#elif TARGET_OS_MAC
                if (_connectPoints) {
                    [waveformPath lineToPoint:CGPointMake(x, y)];
                }
#endif
            }
        }
        x += deltaX;
    };
    
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
