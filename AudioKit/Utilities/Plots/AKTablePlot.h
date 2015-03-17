//
//  AKTablePlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/9/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTable.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
@interface AKTablePlot : UIView
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
@interface AKTablePlot : NSView
#endif


- (instancetype)initWithFrame:(CGRect)frame table:(AKTable *)newtable;
@property AKTable *table;

@end
