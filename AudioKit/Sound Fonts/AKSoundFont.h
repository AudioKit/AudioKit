//
//  AKSoundFont.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKSoundFont : NSObject

/// A reference lookup number for the sound font.
@property (readonly) int number;

/// Create soundfont with a filename
/// @param filename Sound font file to load.
- (instancetype)initWithFilename:(NSString *)filename;

@end
