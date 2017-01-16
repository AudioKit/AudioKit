//
//  AKTanhDistortionAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"

@interface AKTanhDistortionAudioUnit : AKAudioUnit
@property (nonatomic) float pregain;
@property (nonatomic) float postgain;
@property (nonatomic) float postiveShapeParameter;
@property (nonatomic) float negativeShapeParameter;
@end

