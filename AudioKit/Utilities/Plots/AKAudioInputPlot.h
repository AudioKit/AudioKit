//
//  AKAudioInputPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPlotView.h"

/// Plots the incoming audio source signal, usually the microphone
IB_DESIGNABLE
@interface AKAudioInputPlot : AKPlotView

@property IBInspectable AKColor *lineColor;
@property IBInspectable CGFloat lineWidth;

@end
