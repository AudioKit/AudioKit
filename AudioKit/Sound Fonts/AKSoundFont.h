//
//  AKSoundFont.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

@interface AKSoundFont : NSObject

/// A reference lookup number for the sound font.
@property (readonly) int number;

/// Array of instruments in the sound font
@property NSMutableArray *instruments;

// Array of presets in the sound font
@property NSMutableArray *presets;

/// Create soundfont with a filename
/// @param filename Sound font file to load.
- (instancetype)initWithFilename:(NSString *)filename;

@end
