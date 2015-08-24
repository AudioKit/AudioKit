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
@class AKSoundFont;

// A nil argument indicates the sound font failed to load.
typedef void (^AKSoundFontCompletionBlock)(AKSoundFont * __nullable);

NS_ASSUME_NONNULL_BEGIN
/// The AudioKit class for sound fonts
@interface AKSoundFont : NSObject

/// A reference lookup number for the sound font.
@property (readonly) int number;

/// Array of instruments in the sound font
@property (nonatomic,readonly,nullable) NSArray *instruments;

/// Array of presets in the sound font
@property (nonatomic,readonly,nullable) NSArray *presets;

/// Whether the presets and instruments have been successfully loaded and parsed
@property (nonatomic,readonly) BOOL loaded;

/// Load a sound font from a file.
/// The presets and instruments are not automatically loaded at this point, call fetchPresets: to initiate it.
/// @param filename Sound font file to load.
- (instancetype)initWithFilename:(NSString *)filename;

/// Loads the presets and instruments definitions from the file.
/// @param completionBlock A block to be called when the data has been fully loaded.
- (void)fetchPresets:(__nullable AKSoundFontCompletionBlock)completionBlock;


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