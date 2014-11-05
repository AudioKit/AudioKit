//
//  AKSoundFileTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKSoundFileTable.h"
#import "AKArray.h"

@implementation AKSoundFileTable

- (instancetype)initWithFilename:(NSString *)filename {
    return [self initWithFilename:filename tableSize:0];

}

- (instancetype)initWithFilename:(NSString *)filename
                       tableSize:(int)tableSize {
    AKArray *parameters = [AKArray arrayFromConstants:
                                 akpfn(filename), akp(0), akp(0), akp(0), nil];
    return [super initWithType:kFTSoundFile 
                         size:tableSize 
                   parameters:parameters];
}

- (AKConstant *)channels 
{
    AKConstant * new = [[AKConstant alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ftchnls(%@)", self]];
    return new;
}


@end
