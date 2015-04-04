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
    MYFLT *tableValues;
    int tableLength;
    MYFLT *displayData;
    int fTableNumber;
}


- (instancetype)initWithFrame:(CGRect)frame table:(AKTable *)table
{
   
    self = [super initWithFrame:frame];
    if (self) {
        fTableNumber = table.number;
        CSOUND *cs = [[[AKManager sharedManager] engine]  getCsound];
        while (csoundTableLength(cs, fTableNumber) < 0) {
            // do nothing
        }
        if ((tableLength = csoundTableLength(cs, fTableNumber)) > 0) {
            tableValues = malloc(tableLength * sizeof(MYFLT));
            csoundGetTable(cs, &tableValues, fTableNumber);
            
            float scalingFactor = 0.9;
            int width = self.frame.size.width;
            int height = self.frame.size.height;
            int middle = (height / 2);
            
            displayData = malloc(sizeof(MYFLT) * width);
            
            float max = 0.00001;
            
            for(int i = 0; i < width; i++) {
                float percent = i / (float)(width);
                int index = (int)(percent * tableLength);
                if (tableValues[index] > max) max = tableValues[index];
            }
            for(int i = 0; i < width; i++) {
                float percent = i / (float)(width);
                int index = (int)(percent * tableLength);
                displayData[i] = (-(tableValues[index]/max) * middle * scalingFactor) + middle;
            }
            [self updateUI];
        }
        
    }
    return self;
}

- (void)dealloc
{
    free(displayData);
    free(tableValues);
}

#if TARGET_OS_IPHONE
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

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

}


#elif TARGET_OS_MAC
// TODO
#endif

@end
