//
//  AKConvolutionAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKConvolutionAudioUnit : AKAudioUnit
- (void)setupAudioFileTable:(float *)data size:(UInt32)size;
- (void)setPartitionLength:(int)partitionLength;
@end

