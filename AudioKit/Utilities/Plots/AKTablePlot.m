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
    CGFloat lastY;
    int tableLength;
    MYFLT *displayData;
    int fTableNumber;
}

- (void)defaultValues
{
    fTableNumber = 0;
    _lineWidth = 4.0f;
    _lineColor = [AKColor blueColor];
}

- (void)setTable:(AKTable *)table
{
    fTableNumber = table.number;
    CSOUND *cs = [[[AKManager sharedManager] engine]  getCsound];
    while (csoundTableLength(cs, fTableNumber) < 0) {
        // do nothing
    }
    MYFLT *tableValues;
    if ((tableLength = csoundGetTable(cs, &tableValues, fTableNumber)) > 0) {
        
        float scalingFactor = 0.9;
        CGFloat width = self.frame.size.width;
        CGFloat middle = (self.frame.size.height / 2.0);
        
        displayData = malloc(sizeof(MYFLT) * width);
        
        float max = 0.00001;
        
        for(int i = 0; i < tableLength; i++) {
            if (tableValues[i] > max)
                max = tableValues[i];
        }
        for(int i = 0; i < width; i++) {
            float percent = i / width;
            int index = (int)(percent * tableLength);
            displayData[i] = (-(tableValues[index]/max) * middle * scalingFactor) + middle;
        }
        [self updateUI];
    }
}

- (instancetype)initWithFrame:(CGRect)frame table:(AKTable *)table
{
   
    self = [super initWithFrame:frame];
    if (self) {
        self.table = table;
    }
    return self;
}

- (void)dealloc
{
    free(displayData);
}

- (void)drawRect:(CGRect)rect
{
    if (fTableNumber == 0) {
        return;
    }
#if TARGET_OS_IPHONE
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
#elif TARGET_OS_MAC
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
    CGFloat y = displayData[0];
    
    CGPathMoveToPoint(fill_path, &CGAffineTransformIdentity, x, y);
    
    for(int i = 1; i < width; i++) {
        CGPathAddLineToPoint(fill_path, &CGAffineTransformIdentity, i, displayData[i]);
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
