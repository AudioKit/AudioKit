//
//  AKTestTriggers.h
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 AKTrigger contains a sample time and a block.
*/
@interface AKTrigger: NSObject
@property Float64 sampleTime;
@property _Nonnull dispatch_block_t block;
-(instancetype _Nonnull)init NS_UNAVAILABLE;
-(instancetype _Nonnull)initWithSampleTime:(Float64)sampleTime andBlock:(dispatch_block_t _Nonnull)block NS_SWIFT_NAME(init(sample:block:));
@end

/**
 AKTestTriggers is meant for scheduling (inaccurately) parameters during an offline render.
 It needs to be initialized with a node that has an underlying audio unit. (Not AVAudioMixerNode)
 It takes an array of AKTriggers. During the rendering, if the render block contains a trigger's sample time, it's block will be executed.  If scheduling a parameter, the parameter change will not take effect until the next (offline) render cycle, which is 4096 samples.
 */
@interface AKTestTriggers : NSObject
@property NSArray <AKTrigger *>  * _Nonnull triggers;
-(instancetype _Nonnull)init NS_UNAVAILABLE;
/// Init with an AVAudioNode other than an AVAudioMixerNode or an AKMixer.
-(instancetype _Nonnull)initWithNode:(AVAudioNode * _Nonnull) node;
/// Call this in the pre-render block.
-(void)start;
@end
