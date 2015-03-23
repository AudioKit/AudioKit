//
//  AKPropertySLider.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
@interface AKPropertySlider : UISlider
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
@interface AKPropertySlider : NSSlider
#endif


@property (nonatomic) id property;

@end
