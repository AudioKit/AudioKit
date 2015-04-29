//
//  AKTablePlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/9/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTablePlot.h"
#import "AKManager.h"
#import "CsoundObj.h"

@implementation AKTablePlot
{
    float *_displayData;
}

- (void)defaultValues
{
    _scalingFactor = 0.9f;
    _lineWidth = 4.0f;
    _lineColor = [AKColor blueColor];
}

- (void)setTable:(AKTable *)table
{
    _table = table;
    
    float *tableValues = table.values;
    if (tableValues) {
        
        CGFloat width = self.frame.size.width;
        CGFloat middle = (self.frame.size.height / 2.0);
        
        _displayData = realloc(_displayData, sizeof(float) * width);
        
        float max = 0.00001;
        NSUInteger len = table.size;
        
        for(int i = 0; i < len; i++) {
            if (tableValues[i] > max)
                max = tableValues[i];
        }
        for(int i = 0; i < width; i++) {
            float percent = i / width;
            NSUInteger index = (percent * len);
            _displayData[i] = (-(tableValues[index]/max) * middle * self.scalingFactor) + middle;
        }
        [self updateUI];
    }
}

- (void)dealloc
{
    free(_displayData);
}

- (void)drawRect:(CGRect)rect
{
    if (!self.table) {
        return;
    }
#if TARGET_OS_IPHONE
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
#elif TARGET_OS_MAC
    [self.backgroundColor setFill];
    NSRectFill(rect);
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef context = (CGContextRef) [nsGraphicsContext graphicsPort];
#endif

    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, rect);
    
    int width = self.frame.size.width;
    
    CGContextSetRGBStrokeColor(context, 255, 255, 255, 1);
    CGContextSetRGBFillColor(context, 255, 255, 255, 1);
    CGMutablePathRef fill_path = CGPathCreateMutable();
    CGFloat x = 0;
    CGFloat y = _displayData[0];
    
    CGPathMoveToPoint(fill_path, &CGAffineTransformIdentity, x, y);
    
    for(int i = 1; i < width; i++) {
        CGPathAddLineToPoint(fill_path, &CGAffineTransformIdentity, i, _displayData[i]);
    }
    CGContextAddPath(context, fill_path);
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetLineWidth(context, 4);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(fill_path);
#if TARGET_OS_IPHONE
    CGContextRestoreGState(context);
#elif TARGET_OS_MAC
    [[NSGraphicsContext currentContext] restoreGraphicsState];
#endif
}


@end
