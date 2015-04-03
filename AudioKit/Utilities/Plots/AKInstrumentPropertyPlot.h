//
//  AKInstrumentPropertyPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrumentProperty.h"
#import "AKPlotView.h"

/// Plot of the given instrument property
IB_DESIGNABLE
@interface AKInstrumentPropertyPlot : AKPlotView

@property IBInspectable AKColor *lineColor;

@property AKInstrumentProperty *property;
@property AKInstrumentProperty *plottedValue;

@property IBInspectable CGFloat lineWidth;

- (instancetype)initWithProperty:(AKInstrumentProperty *)property;

@end
