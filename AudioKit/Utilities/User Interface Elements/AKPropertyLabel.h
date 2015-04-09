//
//  AKPropertyLabel.h
//  AudioKitPlayground
//
//  Created by Aurelius Prochazka on 3/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
/// Ties a label to the value of a property
@interface AKPropertyLabel : UILabel
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
/// Ties a label to the value of a property
@interface AKPropertyLabel : NSTextField
#endif

@property (nonatomic) AKParameter *property;

@end
