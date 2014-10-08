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
                     maximum:(float)maximum
                        size:(int)tableSize;
{
    return [self initWithType:kFTWindows
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:
                               akpi(windowType),akp(maximum), nil]];
}


- (instancetype)initWithType:(WindowTableType)windowType
                        size:(int)tableSize;
{
    return [self initWithType:windowType
                      maximum:1.0f
                         size:tableSize];
}

- (instancetype)initGaussianTypeWithBroadness:(float)windowBroadness
                                      maximum:(float)maximum
                                         size:(int)tableSize;
{
    return [self initWithType:kFTWindows
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:
                               akpi(kWindowGaussian),
                               akp(maximum),
                               akp(windowBroadness), nil] ];
}

- (instancetype)initKaiserTypeWithOpenness:(float)windowOpenness
                                   maximum:(float)maximum
                                      size:(int)tableSize
{
    return [self initWithType:kFTWindows
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:
                               akpi(kWindowKaiser),
                               akp(maximum),
                               akp(windowOpenness), nil] ];
    
}
@end
