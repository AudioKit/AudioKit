//
//  AKSoundFontPreset.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/29/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

@class AKSoundFont;

NS_ASSUME_NONNULL_BEGIN

/// The AudioKit class for sound font presets
@interface AKSoundFontPreset : NSObject

/// Name of the preset
@property (readonly) NSString *name;

/// Unique number of the preset
@property (readonly) NSUInteger number;

/// Program Number
@property (readonly) NSUInteger program;

/// Bank Number
@property (readonly) NSUInteger bank;

/// Sound font the instrument is part of
@property (readonly) AKSoundFont *soundFont;

/// Create the sound font preset with information from the sf2 file format
/// @param name   Name of the preset
/// @param number Unique number of the preset
/// @param program Program Number
/// @param bank    Bank Number
/// @param soundFont Sound Font this preset is part of
- (instancetype)initWithName:(NSString *)name
                      number:(NSUInteger)number
                     program:(NSUInteger)program
                        bank:(NSUInteger)bank
                   soundFont:(AKSoundFont *)soundFont;

/// String for invocation when needed
- (NSString *)orchestraString;

@end
NS_ASSUME_NONNULL_END

