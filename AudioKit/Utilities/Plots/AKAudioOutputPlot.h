//
//  AKAudioOutputPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "CsoundObj.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
/// Plot the raw samples of the audio output to the DAC
IB_DESIGNABLE
@interface AKAudioOutputPlot : UIView
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
/// Plot the raw samples of the audio output to the DAC
IB_DESIGNABLE
@interface AKAudioOutputPlot : NSView
#endif

@end
