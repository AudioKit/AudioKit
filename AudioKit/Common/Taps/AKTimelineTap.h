//
//  AKTimelineTap.h
//  AudioKit
//
//  Created by David O'Neill on 8/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AKTimeline.h"


@interface AKTimelineTap : NSObject {
@public
    AKTimeline _timeline;
}

/**
 A block that will be called with timeline information.
 
 Will be called from the render thread, so no locks, Swift functions or
 Objective-C messages from within this block.  Make sure not to capture self.
 
 @param timeline The AKTimeline.
 @param timeStamp A timestamp with mSampleTime representing position in a zero indexed timeline.
 @ param offset The number of samples from render start to timeStamp->mSampleTime.  Will be
 non-zero when a render goes past the loop end and block is called twice in one render.
 frames The number of samples rendered.
 ioData The Audio buffer, may be invalid if preRender is true.
 */
typedef void(^AKTimelineBlock)( AKTimeline      * _Nonnull  timeline,
                               AudioTimeStamp  * _Nonnull  timeStamp,
                               UInt32                      offset,
                               UInt32                      frames,
                               AudioBufferList * _Nonnull  ioData);


/**
 A block that will be called with timeline information.
 Will be called from the render thread, so no locks, Swift functions or
 Objective-C messages from within this block.  Make sure not to capture self.
 */
@property (readonly) AKTimelineBlock _Nullable timelineCallback NS_SWIFT_UNAVAILABLE("No render code in Swift");

/** 
 Dictates if timelineCallback will be called pre-render or post-render, defaults to false (postRender).
 
 Pre-render is better for triggering MIDI as the sample offset is taken into consideration. Post-render
 is neccessary for ioData buffer manipulation as buffers' mData is NULL during pre-render.
 */
@property BOOL preRender;

/**
 The underlying timeline.
 */
@property (readonly) AKTimeline * _Nonnull timeline;

/**
 Initializes a timelineTap, holds reference to audioUnit.
 
 @param audioUnit The audioUnit that will the tap notify on.
 @param block The block tha will be called on render thread.
 @return A renderTap ready to start.
 */
-(instancetype _Nullable )initWithAudioUnit:(AudioUnit _Nonnull)audioUnit
                              timelineBlock:(AKTimelineBlock _Nullable )block NS_DESIGNATED_INITIALIZER NS_SWIFT_UNAVAILABLE("No render code in Swift");
/**
 Initializes a renderTap, holds reference to underlying audioUnit.
 
 @param node The AVAudioNode that will the tap will notify on.
 @param block The block tha will be called on render thread.
 @return A renderTap ready to start, or NULL if node has no accessible audioUnit.
 */
-(instancetype _Nullable )initWithNode:(AVAudioNode * _Nonnull)node
                         timelineBlock:(AKTimelineBlock _Nullable )block NS_SWIFT_UNAVAILABLE("No render code in Swift");
-(instancetype _Nonnull )init NS_UNAVAILABLE;

@end
