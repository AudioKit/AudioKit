//
//  AKWindowsTable.m
//  AudioKit
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKWindowsTable.h"

@implementation AKWindowsTable

- (instancetype)initWithType:(WindowTableType)windowType
                maximumValue:(float)maximumValue
                        size:(int)tableSize;
{
    return [self initWithType:kFTWindows
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:
                               akpi(windowType),akp(maximumValue), nil]];
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
                   parameters:[AKArray arrayFromConstants:
                               akpi(kWindowGaussian),
                               akp(maximumValue),
                               akp(windowBroadness), nil] ];
}

- (instancetype)initKaiserTypeWithOpenness:(float)windowOpenness
                              maximumValue:(float)maximumValue
                                      size:(int)tableSize
{
    return [self initWithType:kFTWindows
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:
                               akpi(kWindowKaiser),
                               akp(maximumValue),
                               akp(windowOpenness), nil] ];
    
}
@end
