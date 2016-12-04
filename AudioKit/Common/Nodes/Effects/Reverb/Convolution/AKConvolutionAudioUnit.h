//
//  AKConvolutionAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKConvolutionAudioUnit_h
#define AKConvolutionAudioUnit_h

#import "AKAudioUnit.h"

@interface AKConvolutionAudioUnit : AKAudioUnit
- (void)setupAudioFileTable:(float *)data size:(UInt32)size;
- (void)setPartitionLength:(int)partitionLength;
@end

#endif /* AKConvolutionAudioUnit_h */
