//
//  AKSoundFont.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

@class AKSoundFontInstrument;
@class AKSoundFontPreset;

NS_ASSUME_NONNULL_BEGIN
@interface AKSoundFont : NSObject

/// A reference lookup number for the sound font.
@property (readonly) int number;

/// Array of instruments in the sound font
@property (nonatomic,readonly) NSArray *instruments;

/// Array of presets in the sound font
@property (nonatomic,readonly) NSArray *presets;

/// Whether the file has been successfully loaded and parsed
@property (nonatomic,readonly) BOOL loaded;

/// Load a sound font from a file.
/// @param filename Sound font file to load.
- (instancetype)initWithFilename:(NSString *)filename;

// Utility methods to easily locate loaded presets and instruments

/// Locate a named instrument in the sound font.
/// @param name The name of the instrument as set in the file (case sensitive)
- (AKSoundFontInstrument * __nullable)findInstrumentNamed:(NSString *)name;

/// Locate a named preset in the sound font.
/// @param name The name of the preset as set in the file (case sensitive)
- (AKSoundFontPreset * __nullable)findPresetNamed:(NSString *)name;

/// Locate a particular preset by bank and program numbers.
/// @param program The program number
/// @param bank The bank number
- (AKSoundFontPreset * __nullable)findPresetProgram:(NSUInteger)program fromBank:(NSUInteger)bank;

@end
NS_ASSUME_NONNULL_END