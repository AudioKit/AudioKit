//
//  UIKnob.m
//  MulitFX
//
//  Created by Thomas Hass on 11/19/11.
//  Copyright (c) 2011 Csound Ninjas. All rights reserved.
//

#import "UIKnob.h"

@implementation UIKnob

@synthesize value;
@synthesize defaultValue;
@synthesize minimumValue;
@synthesize maximumValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        defaultValue = value = 0;
        minimumValue = 0;
        maximumValue = 0;
        angle = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        defaultValue = value = 0;
        minimumValue = 0;
        maximumValue = 0;
        angle = 0;
    }
    return self;
}

- (void)setValue:(Float32)value_
{
    value = value_;
    angle = ((value - minimumValue) / (maximumValue - minimumValue)) * 270.0f;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
}

#pragma mark - UIControl Overrides

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[self superview]];
    if (touchPoint.y < lastTouchPoint.y) {
        angle += angle < 270 ? 4 : 0;
    } else {
        angle -= angle > 0 ? 4 : 0;
    }
    value = minimumValue + angle/270.0f * (maximumValue - minimumValue);
    lastTouchPoint = touchPoint;
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[self superview]];
    if (touchPoint.y < lastTouchPoint.y) {
        angle += angle < 270 ? 4 : 0;
    } else {
        angle -= angle > 0 ? 4 : 0;
    }
    value = minimumValue + angle/270.0f * (maximumValue - minimumValue);
    lastTouchPoint = touchPoint;
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{    
    self.transform = CGAffineTransformMakeRotation(angle*M_PI/180.0f - 135.0f*M_PI/180.0f);
    if (angle >= 360) {
        angle -= 360.0f;
    }
    
    // Draw image
    UIImage *knobImage = [UIImage imageNamed:@"knob_complete.png"];
    [knobImage drawInRect:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height)];
    
    // Get the context
	//CGContextRef context = UIGraphicsGetCurrentContext();
	//CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Flip coordinate system
	//CGContextTranslateCTM(context, 0, rect.size.height);
	//CGContextScaleCTM(context, 1.0, -1.0);
    
    /*
    // Draw circle
    CGFloat redComponents[] = {1.0f, 0.1f, 0.0f, 1.0f};
	CGColorRef redColor = CGColorCreate(colorSpace, redComponents);
	CGContextSetFillColorWithColor(context, redColor);
    CGContextAddEllipseInRect(context, rect);
    //CGContextFillEllipseInRect(context, rect);
    CGColorRelease(redColor);
        
    // Draw line
    CGContextMoveToPoint(context, 40.0f, 40.0f);
    CGContextAddLineToPoint(context, rect.size.width/2.0f, rect.size.height/2.0f);
    CGFloat blackComponents[] = {0.0f, 0.0f, 0.0f, 1.0f};
	CGColorRef blackColor = CGColorCreate(colorSpace, blackComponents);
	CGContextSetStrokeColorWithColor(context, blackColor);
    //CGContextStrokePath(context);
    CGColorRelease(blackColor);
    */
    
    //CGColorSpaceRelease(colorSpace);
}

@end
