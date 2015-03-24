//
//  AKInstrumentPropertyPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrumentProperty.h"
#import "CsoundObj.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
/// Plot of the given instrument property
@interface AKInstrumentPropertyPlot : UIView <CsoundBinding>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
/// Plot of the given instrument property
@interface AKInstrumentPropertyPlot : NSView <CsoundBinding>
#endif

@property AKInstrumentProperty *property;
@property AKInstrumentProperty *plottedValue;

- (instancetype)initWithProperty:(AKInstrumentProperty *)property;

@end
