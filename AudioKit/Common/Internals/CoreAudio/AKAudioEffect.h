//
//  AKAudioEffect.h
//  AudioKit
//
//  Created by Andrew Voelkel on 8/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#ifndef AKAudioEffect_h
#define AKAudioEffect_h

#import <AVFoundation/AVFoundation.h>
#import "AKAudioUnit.h"


@interface AKAudioEffect : AKAudioUnit

- (void)standardSetup;

@end



#endif /* AKAudioEffect_h */
