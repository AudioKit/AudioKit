//
//  OCSWindowsTable.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSWindowsTable.h"

@implementation OCSWindowsTable

- (instancetype)initWithType:(WindowTableType)windowType
                maximumValue:(float)maximumValue
                        size:(int)tableSize;
{
    return [self initWithType:kFTWindows
                         size:tableSize
                   parameters:[OCSArray arrayFromConstants:
                               ocspi(windowType),ocsp(maximumValue), nil]];
}


- (instancetype)initWithType:(WindowTableType)windowType
                        size:(int)tableSize;
{
    return [self initWithType:windowType
                 maximumValue:1.0f
                         size:tableSize];
}

- (instancetype)initGaussianTypeWithBroadness:(float)windowBroadness
                                 maximumValue:(float)maximumValue
                                         size:(int)tableSize;
{
    return [self initWithType:kFTWindows
                         size:tableSize
                   parameters:[OCSArray arrayFromConstants:
                               ocspi(kWindowGaussian),
                               ocsp(maximumValue),
                               ocsp(windowBroadness), nil] ];
}

- (instancetype)initKaiserTypeWithOpenness:(float)windowOpenness
                              maximumValue:(float)maximumValue
                                      size:(int)tableSize
{
    return [self initWithType:kFTWindows
                         size:tableSize
                   parameters:[OCSArray arrayFromConstants:
                               ocspi(kWindowKaiser),
                               ocsp(maximumValue),
                               ocsp(windowOpenness), nil] ];
    
}
@end
