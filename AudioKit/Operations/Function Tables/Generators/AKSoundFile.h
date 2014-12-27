//
//  AKSoundFile.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFunctionTable.h"

/** Transfers data from a soundfile into a function table.

 File types supported are given here: http://www.mega-nerd.com/libsndfile/
 
 `tableSize` is the number of points in the table. Ordinarily a power of 2 or a power-of-2 plus 1 
 The maximum tableSize is 16777216 (224) points. The allocation of table memory can be deferred 
 by setting this parameter to 0; the size allocated is then the number of points in the file 
 (probably not a power-of-2), and the table is not usable by normal oscillators, but it is usable 
 by an AKLoopoingOscillator. The soundfile can also be mono or stereo.
 
 *Important:* Reading stops at end-of-file or when the table is full. 
 Table locations not filled will contain zeros.

*/

@interface AKSoundFile : AKFunctionTable

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


