//
//  AKSoundFile.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKSoundFile.h"
#import "AKArray.h"

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
