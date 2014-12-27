//
//  AKSoundFile.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKSoundFile.h"
#import "AKArray.h"

/** 
 
 `tableSize` is the number of points in the table. Ordinarily a power of 2 or a power-of-2 plus 1
 The maximum tableSize is 16777216 (224) points. The allocation of table memory can be deferred
 by setting this parameter to 0; the size allocated is then the number of points in the file
 (probably not a power-of-2), and the table is not usable by normal oscillators, but it is usable
 by an AKLoopoingOscillator. The soundfile can also be mono or stereo.
 
 *Important:* Reading stops at end-of-file or when the table is full.
 Table locations not filled will contain zeros.
 
 */


@implementation AKSoundFile

- (instancetype)initWithFilename:(NSString *)filename
{
    AKArray *parameters = [AKArray arrayFromConstants:
                                 akpfn(filename), akp(0), akp(0), akp(0), nil];
    return [super initWithType:AKFunctionTableTypeSoundFile
                   parameters:parameters];
}

- (AKConstant *)channels 
{
    AKConstant * new = [[AKConstant alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ftchnls(%@)", self]];
    return new;
}

@end
