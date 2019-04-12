//
//  AKRenderTap.h
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

/**
 * A block that will be called every pre and post render for an audio unit.
 * Will be called from the render thread, so no locks, Swift functions or
 * Objective-C messages from within this block.  Make sure not to capture self.
 */
typedef void(^AKRenderNotifyBlock)(AudioUnitRenderActionFlags * _Nonnull ioActionFlags,const AudioTimeStamp * _Nonnull inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList * _Nullable ioData);


@interface AKRenderTap : NSObject

/**
 * A block that will be called every pre and post render for an audio unit.
 * Will be called from the render thread, so no locks, Swift functions or
 * Objective-C messages from within this block.  Make sure not to capture self.
 * If not initialize with a renderNotify block, then this should be implemented
 * by subclasses.
 */
@property (readonly) AKRenderNotifyBlock _Nullable renderNotifyBlock NS_SWIFT_UNAVAILABLE("No render code in Swift");

/**
 * Internal audio unit;
 */
@property (readonly) AudioUnit _Nonnull audioUnit;

/**
 * Initializes a renderTap, holds reference to audioUnit.
 *
 * @param audioUnit The audioUnit that will the tap notify on.
 * @param block The block tha will be called every pre and post render.
 * @return A renderTap ready to start.
 */
-(instancetype _Nullable )initWithAudioUnit:(AudioUnit _Nonnull)audioUnit renderNotify:(AKRenderNotifyBlock _Nullable )block NS_DESIGNATED_INITIALIZER NS_SWIFT_UNAVAILABLE("No render code in Swift");

/**
 * Initializes a renderTap, holds reference to underlying audioUnit.
 * underlying audioUnit.
 *
 * @param node The AVAudioNode that will the tap will notify on.
 * @param block The block tha will be called every pre and post render.
 * @return A renderTap ready to start.
 */
-(instancetype _Nullable )initWithNode:(AVAudioNode * _Nonnull)node renderNotify:(AKRenderNotifyBlock _Nullable )block NS_SWIFT_UNAVAILABLE("No render code in Swift");

-(instancetype _Nonnull )init NS_UNAVAILABLE;

@end


