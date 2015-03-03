//
//  AKSoundFileTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKSoundFileTable.h"

@implementation AKSoundFileTable

- (instancetype)initWithFilename:(NSString *)filename
{
    filename = [NSString stringWithFormat:@"\"%@\"", filename];
    NSArray *parameters = @[filename, @0, @0, @0];
    return [super initWithType:1 size:0 parameters:parameters];
}

- (instancetype)initAsMonoFromLeftChannelOfStereoFile:(NSString *)filename
{
    filename = [NSString stringWithFormat:@"\"%@\"", filename];
    NSArray *parameters = @[filename, @0, @0, @1];
    return [super initWithType:1 size:0 parameters:parameters];
}

- (instancetype)initAsMonoFromRightChannelOfStereoFile:(NSString *)filename
{
    filename = [NSString stringWithFormat:@"\"%@\"", filename];
    NSArray *parameters = @[filename, @0, @0, @2];
    return [super initWithType:1 size:0 parameters:parameters];
}


- (AKConstant *)channels
{
    AKConstant * new = [[AKConstant alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ftchnls(%@)", self]];
    return new;
}

@end
