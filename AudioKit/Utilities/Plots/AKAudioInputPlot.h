//
//  AKAudioInputPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "CsoundObj.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
/// Plots the incoming audio source signal, usually the microphone
@interface AKAudioInputPlot : UIView <CsoundBinding>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
/// Plots the incoming audio source signal, usually the microphone
@interface AKAudioInputPlot : NSView <CsoundBinding>
#endif

@end
