//
//  AKAudioInputFFTPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "CsoundObj.h"
#import <Accelerate/Accelerate.h>


#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
/// Plots the FFT of the audio input
@interface AKAudioInputFFTPlot : UIView <CsoundBinding>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
/// Plots the FFT of the audio input
@interface AKAudioInputFFTPlot : NSView
#endif

@end
