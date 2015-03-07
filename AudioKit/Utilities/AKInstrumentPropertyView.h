//
//  AKInstrumentPropertyView.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrumentProperty.h"
#import "CsoundObj.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
@interface AKInstrumentPropertyView : UIView <CsoundBinding>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
@interface AKInstrumentPropertyView : NSView <CsoundBinding>
#endif

@property AKInstrumentProperty *property;
@property AKInstrumentProperty *plottedValue;

- (instancetype)initWithProperty:(AKInstrumentProperty *)property;

@end
