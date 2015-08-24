//
//  AKSoundFontInstrument.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/29/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

@class AKSoundFont;

NS_ASSUME_NONNULL_BEGIN
/// The AudioKit class for sound font instruments
@interface AKSoundFontInstrument : NSObject

/// Unique number assigned to the instrument by the sound font
@property (readonly) NSUInteger number;

/// Name of the instrument
@property (readonly) NSString *name;

/// Sound font the instrument is part of
@property (readonly) AKSoundFont *soundFont;

/// Create the sound font instrument with information from the sf2 file format
/// @param name   Name of the instrument
/// @param number Unique number of the instrument
/// @param soundFont Sound Font this instrument is part of
- (instancetype)initWithName:(NSString *)name
                      number:(NSUInteger)number
                   soundFont:(AKSoundFont *)soundFont;

@end
NS_ASSUME_NONNULL_END