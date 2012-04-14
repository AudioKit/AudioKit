//
//  UIKnob.h
//  MulitFX
//
//  Created by Thomas Hass on 11/19/11.
//  Copyright (c) 2011 Csound Ninjas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@interface UIKnob : UIControl
{
    Float32 value;
    Float32 defaultValue;
    Float32 minimumValue;
    Float32 maximumValue;
    
    CGFloat angle;
    CGPoint lastTouchPoint;
}

@property (nonatomic, readwrite, setter = setValue:) Float32 value;
@property (nonatomic, readwrite) Float32 defaultValue;
@property (nonatomic, readwrite) Float32 minimumValue;
@property (nonatomic, readwrite) Float32 maximumValue;

@end
