//
//  AKSoundFileTable.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFTable.h"

/** Transfers data from a soundfile into a function table.

 File types supported are given here: http://www.mega-nerd.com/libsndfile/
 
 `tableSize` is the number of points in the table. Ordinarily a power of 2 or a power-of-2 plus 1 
 The maximum tableSize is 16777216 (224) points. The allocation of table memory can be deferred 
 by setting this parameter to 0; the size allocated is then the number of points in the file 
 (probably not a power-of-2), and the table is not usable by normal oscillators, but it is usable 
 by an AKLoopoingOscillator. The soundfile can also be mono or stereo.
 
 *Important:* Reading stops at end-of-file or when the table is full. 
 Table locations not filled will contain zeros.
 
 @warning *Unsupported Functions* 
 
 `skiptime` -- begin reading at skiptime seconds into the file.
 
 `channel` -- channel number to read in. 0 denotes read all channels.
 
 `format` -- specifies the audio data-file format:
 
    1 - 8-bit signed character    4 - 16-bit short integers 
    2 - 8-bit A-law bytes         5 - 32-bit long integers 
    3 - 8-bit U-law bytes         6 - 32-bit floats
 
 If `format` = 0 the sample format is taken from the soundfile header, or by default from the CSound -o command-line flag.
 
*/

@interface AKSoundFileTable : AKFTable

/// Store file with a filename
/// @param filename Audio file to load.  Most types are supported.
- (instancetype)initWithFilename:(NSString *)filename;

/// Store file with a filename using a specifically sized function table
/// @param filename  Audio file to load.  Most types are supported.
/// @param tableSize Size of the table to use.  Necessary for some opcodes.
- (instancetype)initWithFilename:(NSString *)filename
                       tableSize:(int)tableSize;

/// Returns the string to retrieve the number of channels of a sound file table
- (AKConstant *)channels;

@end


