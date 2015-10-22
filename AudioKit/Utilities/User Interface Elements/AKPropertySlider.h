//
//  AKPropertySLider.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter.h"

#if !TARGET_OS_TV

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
/// A slider that sets the value of a property (within the property's bounds)
@interface AKPropertySlider : UISlider
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
/// A slider that sets the value of a property (within the property's bounds)
@interface AKPropertySlider : NSSlider
#endif


@property (nonatomic) AKParameter *property;

@end

#endif
