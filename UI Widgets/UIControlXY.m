/* 
 
 UIControlXY.m:
 
 Copyright (C) 2011 Thomas Hass
 
 This file is part of Csound iOS Examples.
 
 The Csound for iOS Library is free software; you can redistribute it
 and/or modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.   
 
 Csound is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with Csound; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 02111-1307 USA
 
 */


#import "UIControlXY.h"

@interface UIControlXY ()
{
    CGFloat borderWidth;
    BOOL shouldTrack;
}
@end

@implementation UIControlXY

@synthesize cacheDirty = mCacheDirty;
@synthesize xValue;
@synthesize yValue;
@synthesize circleDiameter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        borderWidth = 10.0f;
        circleRect = CGRectMake(borderWidth, 
                                frame.size.height - 30.0f - borderWidth, 
                                30.0f, 
                                30.0f);
        xValue = 0.0f;
        yValue = 0.0f;
        shouldTrack = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        borderWidth = 10.0f;
        circleRect = CGRectMake(borderWidth, 
                                self.frame.size.height - 30.0f - borderWidth, 
                                30.0f, 
                                30.0f);
        xValue = 0.0f;
        yValue = 0.0f;
    }
    return self;
}

- (void)setXValue:(Float32)xValue_
{
    xValue = xValue_;
        
    // Limit it
    CGFloat minX = borderWidth;
    CGFloat maxX = self.frame.size.width - borderWidth - circleRect.size.width;
    
    // Redraw
    CGFloat xPosition = xValue * (maxX - minX);
    circleRect.origin.x = xPosition + borderWidth;
    
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setYValue:(Float32)yValue_
{
    yValue = yValue_;
    
    CGFloat minY = borderWidth;
    CGFloat maxY = self.frame.size.height - borderWidth - circleRect.size.height;
    
    CGFloat yPosition = yValue * (maxY - minY);
    yPosition = maxY - yPosition;
    circleRect.origin.y = yPosition;
    
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setCircleDiameter:(CGFloat)circleDiameter_
{
    circleRect = CGRectMake(borderWidth, 
                            self.frame.size.height - circleDiameter_ - borderWidth, 
                            circleDiameter_, 
                            circleDiameter_);
    [self setNeedsDisplay];
}

#pragma mark - UIControl Overrides

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:self];
    //if (CGRectContainsPoint(circleRect, location)) {
        
        // Reposition the touch (origin is top left)
        location.x -= circleRect.size.width/2.0f;
        location.y -= circleRect.size.height/2.0f;
        
        // Limit it
        CGFloat minX = borderWidth;
        CGFloat minY = borderWidth;
        CGFloat maxX = self.frame.size.width - borderWidth - circleRect.size.width;
        CGFloat maxY = self.frame.size.height - borderWidth - circleRect.size.height;
        location.x = location.x < minX ? minX : location.x;
        location.y = location.y < minY ? minY : location.y;
        location.x = location.x > maxX ? maxX : location.x;
        location.y = location.y > maxY ? maxY : location.y;
        
        // Redraw
        circleRect.origin.x = location.x;
        circleRect.origin.y = location.y;
        
        // Update values
        xValue = location.x / maxX;
        yValue = 1.0f - location.y / maxY;
        
        shouldTrack = YES;
    //}
    
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:self];
    if (shouldTrack) {
        
        // Reposition the touch (origin is top left)
        location.x -= circleRect.size.width/2.0f;
        location.y -= circleRect.size.height/2.0f;
        
        // Limit it
        CGFloat minX = borderWidth;
        CGFloat minY = borderWidth;
        CGFloat maxX = self.frame.size.width - borderWidth - circleRect.size.width;
        CGFloat maxY = self.frame.size.height - borderWidth - circleRect.size.height;
        location.x = location.x < minX ? minX : location.x;
        location.y = location.y < minY ? minY : location.y;
        location.x = location.x > maxX ? maxX : location.x;
        location.y = location.y > maxY ? maxY : location.y;
        
        // Redraw
        circleRect.origin.x = location.x;
        circleRect.origin.y = location.y;
        
        // Update values
        xValue = location.x / maxX;
        yValue = 1.0f - location.y / maxY;
    }
    
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    shouldTrack = NO;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10.0, 10.0)];
    [clipPath addClip];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Draw border lines.
    [[UIColor blackColor] set];
    CGContextSetLineWidth(context, borderWidth * 2.0f);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, borderWidth * 2.0f);
    
    // Line 1
    CGMutablePathRef borderPath = CGPathCreateMutable();
    CGPathMoveToPoint(borderPath, NULL, 0.0f, 0.0f);
    CGPathAddLineToPoint(borderPath, NULL, 0.0f, rect.size.height);
    CGPathAddLineToPoint(borderPath, NULL, rect.size.width, rect.size.height);
    CGPathAddLineToPoint(borderPath, NULL, rect.size.width, 0.0f);
    CGPathAddLineToPoint(borderPath, NULL, 0.0f, 0.0f);
    CGContextAddPath(context, borderPath);
    CGPathRelease(borderPath);
    CGContextDrawPath(context, kCGPathStroke);
	
	CGContextAddEllipseInRect(context, circleRect);
	CGContextFillEllipseInRect(context, circleRect);
    
    CGColorSpaceRelease(colorSpace);
}

#pragma mark - Value Cacheable

- (void)setup:(CsoundObj *)csoundObj
{
	channelPtrX = [csoundObj getInputChannelPtr:@"mix"];
	channelPtrY = [csoundObj getInputChannelPtr:@"pitch"];
    cachedValueX = xValue;
	cachedValueY = yValue;
    self.cacheDirty = YES;
    [self addTarget:self action:@selector(updateValueCache:) forControlEvents:UIControlEventValueChanged];
}

- (void)updateValueCache:(id)sender
{
	cachedValueX = ((UIControlXY*)sender).xValue;
	cachedValueY = ((UIControlXY*)sender).yValue;
    self.cacheDirty = YES;
}

- (void)updateValuesToCsound
{
	if (self.cacheDirty) {
        *channelPtrX = cachedValueX;
		*channelPtrY = cachedValueY;
        self.cacheDirty = NO;
    }
}

- (void)updateValuesFromCsound
{
	
}

- (void)cleanup
{
	[self removeTarget:self action:@selector(updateValueCache:) forControlEvents:UIControlEventValueChanged];
}

@end
