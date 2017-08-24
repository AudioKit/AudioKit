//
//  AKRenderTap.h
//  AudioKit
//
//  Created by David O'Neill on 8/16/17.
//  Copyright © AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
/**
 * A block that will be called every pre and post render for an audio unit.
 */
typedef void(^AKRenderNotifyBlock)(AudioUnitRenderActionFlags * _Nonnull ioActionFlags,const AudioTimeStamp * _Nonnull inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList * _Nullable ioData);

@interface AKRenderTap : NSObject

/**
 * A block that will be called every pre and post render for an audio unit.
 * Meant to be implemented by subclasses.  Will be called from the render
 * thread, so no locks, Swift functions or Objective-C messages from within
 * this block.  Make sure not to capture self.
 */
@property (readonly) AKRenderNotifyBlock _Nullable renderNotifyBlock NS_SWIFT_UNAVAILABLE("No render code in Swift");

/**
 * return Is renderNotify added.
 */
@property (readonly) BOOL started;

/*!
 * Initializes a renderTap, holds reference to underlying audioUnit.
 * underlying audioUnit.
 *
 * This is a base class implemtation.
 *
 * @param node The AVAudioNode that will the tap will notify on.
 * @return A renderTap ready to start.
 */
-(instancetype _Nullable )initWithNode:(AVAudioNode * _Nonnull)node;

/*!
 * Initializes a renderTap, holds reference to audioUnit.
 *
 * This is a base class implemtation.
 *
 * @param audioUnit The audioUnit that will the tap notify on.
 * @return A renderTap ready to start.
 */
-(instancetype _Nullable )initWithAudioUnit:(AudioUnit _Nonnull)audioUnit NS_DESIGNATED_INITIALIZER;

/*!
 * Starts a renderTap by adding a renderNotify to the internal audioUnit.
 *
 * @param outError On ouput, an error or NULL if successful.
 * @return true if success.
 */
-(BOOL)start:(NSError * _Nullable  *_Nullable)outError;

/*!
 * Stops a renderTap by removing a renderNotify from the internal audioUnit.
 */
-(void)stop;

-(instancetype _Nonnull )init NS_UNAVAILABLE;

@end
