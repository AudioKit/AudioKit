//
//  AKLazyTap.h
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AKRenderTap.h"

@interface AKLazyTap : NSObject

/*!
 * Initializes a tap by adding a render notify callback to the node's
 * underlying audioUnit.
 *
 * The render notify will be removed on dealloc.
 *
 * @param node The AVAudioNode that will the tap will pull buffers from.
 * @return An AKLazyTap if successful in adding the renderNotify.
 */
-(instancetype _Nullable)initWithNode:(AVAudioNode * _Nonnull)node;

/*!
 * Initializes a tap by adding a render notify callback to the audioUnit.
 *
 * The render notify will be removed on dealloc.
 *
 * @param audioUnit The audioUnit that the tap will pull buffers from.
 * @return An AKLazyTap if successful in adding the renderNotify.
 */
-(instancetype _Nullable)initWithAudioUnit:(AudioUnit _Nonnull)audioUnit;

/*!
 * Initializes a tap by adding a render notify callback to the node's
 * underlying audioUnit.
 *
 * The render notify will be removed on dealloc.
 *
 * @param node The AVAudioNode that will the tap will pull buffers from.
 * @param seconds Minumum seconds of audio that the tap will hold.
 * @return An AKLazyTap if successful in adding the renderNotify.
 */
-(instancetype _Nullable)initWithNode:(AVAudioNode * _Nonnull)node queueTime:(double)seconds;

/*!
 * Initializes a tap by adding a render notify callback to the audioUnit.
 *
 * The render notify will be removed on dealloc.
 *
 * @param audioUnit The audioUnit that the tap will pull buffers from.
 * @param seconds Minumum seconds of audio that the tap will hold.
 * @return An AKLazyTap if successful in adding the renderNotify.
 */
-(instancetype _Nullable)initWithAudioUnit:(AudioUnit _Nonnull)audioUnit queueTime:(double)seconds NS_DESIGNATED_INITIALIZER;
-(instancetype _Nonnull )init NS_UNAVAILABLE;

/*!
 * Removes all audio held in the inernal buffer.
 */
-(void)clear;

/*!
 * Will pull the next audioBufferlist from the queue and copy
 * it to bufferlistOut.
 *
 * @param bufferlistOut An audioBufferList that the audio will be copied
 * to,  Should be allocated to store at least one render cylce of audio.
 * @param timeStamp On output, the timeStamp for the audioBufferlist.
 * @return True if audio was copied, false if no audio to copy.
 */
-(BOOL)copyNextBufferList:(AudioBufferList * _Nonnull)bufferlistOut timeStamp:(inout AudioTimeStamp * _Nullable)timeStamp;

/*!
 * Will fill the suplied buffer with as much audio as it can hold or
 * as much audio as the internal buffer contains, whichever is less.
 *
 * @param buffer A buffer that will be filled with audio.
 * @param timeStamp On output, the timeStamp for the first sample of
 *  audio in the buffer.
 * @return True if audio was copied, false if no audio to copy.
 */
-(BOOL)fillNextBuffer:(AVAudioPCMBuffer * _Nonnull)buffer timeStamp:(inout AudioTimeStamp * _Nullable)timeStamp;

@end
