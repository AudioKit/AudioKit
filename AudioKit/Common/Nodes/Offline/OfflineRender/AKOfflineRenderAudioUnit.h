//
//  AKOfflineRenderAudioUnit.h
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

NS_DEPRECATED(10_10, 10_13, 8_0, 11_0)
@interface AKOfflineRenderAudioUnit : AKAudioUnit
@property BOOL internalRenderEnabled; // default = true;

-(AVAudioPCMBuffer * _Nullable)renderToBuffer:(NSTimeInterval)duration
                                        error:(NSError *_Nullable*__null_unspecified)outError;

-(BOOL)renderToFile:(NSURL * _Nonnull)fileURL
           duration:(double)duration
           settings:(NSDictionary<NSString *, id> * _Nullable)settings
              error:(NSError * _Nullable * _Nullable)error;

@end
