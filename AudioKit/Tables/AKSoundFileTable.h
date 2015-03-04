//
//  AKSoundFileTable.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKTable.h"

/** Transfers data from a soundfile into a table.

 File types supported are given here: http://www.mega-nerd.com/libsndfile/
*/

@interface AKSoundFileTable : AKTable

/// Store file with a filename
/// @param filename Audio file to load.  Most types are supported.
- (instancetype)initWithFilename:(NSString *)filename;

/// Store file with a filename
/// @param filename Audio file to load.  Most types are supported.
/// @param size Size of the table
- (instancetype)initWithFilename:(NSString *)filename size:(int)size;

/// Store mono file from the left channel of a file
/// @param filename Audio file to load.  Most types are supported.
- (instancetype)initAsMonoFromLeftChannelOfStereoFile:(NSString *)filename;

/// Store mono file from the right channel of a file
/// @param filename Audio file to load.  Most types are supported.
- (instancetype)initAsMonoFromRightChannelOfStereoFile:(NSString *)filename;

/// Returns the string to retrieve the number of channels of a sound file table
- (AKConstant *)channels;

@end


