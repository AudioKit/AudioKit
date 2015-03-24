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
@interface AKAudioOutputPlot : UIView <CsoundBinding>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
/// Plot the raw samples of the audio output to the DAC
@interface AKAudioOutputPlot : NSView <CsoundBinding>
#endif

@end
