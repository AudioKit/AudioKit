//
//  TouchView.m
//  TouchRegions
//
//  Created by Aurelius Prochazka on 8/6/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "TouchView.h"

@interface TouchView () {
    UITouch *firstTouch;
}
@end

@implementation TouchView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *touchSet = [[event allTouches] allObjects];
    for (UITouch *touch in touchSet) {
        if ((!firstTouch) || (touch == firstTouch)) {
            CGPoint touchPoint = [touch locationInView:self];
            [self setPercentagesWithTouchPoint:touchPoint];
        }
    }

}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *touchSet = [[event allTouches] allObjects];
    for (UITouch *touch in touchSet) {
        if ((!firstTouch) || (touch == firstTouch)) {
            CGPoint touchPoint = [touch locationInView:self];
            [self setPercentagesWithTouchPoint:touchPoint];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *touchSet = [[event allTouches] allObjects];
    for (UITouch *touch in touchSet) {
        if ((!firstTouch) || (touch == firstTouch)) {
            CGPoint touchPoint = [touch locationInView:self];
            [self setPercentagesWithTouchPoint:touchPoint];
            firstTouch=nil;
        }
    }
}

- (void)setPercentagesWithTouchPoint:(CGPoint) touchPoint
{
    if (touchPoint.x > 0 && touchPoint.x < self.bounds.size.width &&
        touchPoint.y > 0 && touchPoint.y < self.bounds.size.height)
    {
        self.horizontalPercentage = touchPoint.x/self.bounds.size.width;
        self.verticalPercentage = touchPoint.y/self.bounds.size.height;
    }
}


@end
