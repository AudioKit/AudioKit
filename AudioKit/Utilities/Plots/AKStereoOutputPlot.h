//
//  AKStereoOutputPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPlotView.h"

/// Plot the raw samples of the audio output to the DAC as left and right signals
IB_DESIGNABLE
@interface AKStereoOutputPlot : AKPlotView

@property IBInspectable AKColor *leftLineColor, *rightLineColor;
@property IBInspectable CGFloat lineWidth;

@end
