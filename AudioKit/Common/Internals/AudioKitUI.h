//
//  AudioKitUI.h
//  AudioKitUI
//
//  Created by Stéphane Peter on 8/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for AudioKitUI.
FOUNDATION_EXPORT double AudioKitUIVersionNumber;

//! Project version string for AudioKitUI.
FOUNDATION_EXPORT const unsigned char AudioKitUIVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AudioKitUI/PublicHeader.h>

//------------------------------------------------------------------------------
#pragma mark - EZAudio Interface Components
//------------------------------------------------------------------------------

#import "EZPlot.h"
#import "EZAudioDisplayLink.h"
#import "EZAudioPlot.h"
#import "EZAudioPlotGL.h"
