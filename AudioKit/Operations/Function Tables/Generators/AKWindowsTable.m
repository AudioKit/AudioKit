//
//  AKWindowsTable.m
//  AudioKit
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "AKWindowsTable.h"

@implementation AKWindowsTable

- (instancetype)initWithType:(AKWindowTableType)windowType
                     maximum:(float)maximum
                        size:(int)tableSize;
{
    return [self initWithType:AKFunctionTableTypeWindows
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:
                               akpi(windowType),akp(maximum), nil]];
}


- (instancetype)initWithType:(AKWindowTableType)windowType
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
    return [self initWithType:AKFunctionTableTypeWindows
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:
                               akpi(AKWindowTableTypeGaussian),
                               akp(maximum),
                               akp(windowBroadness), nil] ];
}

- (instancetype)initKaiserTypeWithOpenness:(float)windowOpenness
                                   maximum:(float)maximum
                                      size:(int)tableSize
{
    return [self initWithType:AKFunctionTableTypeWindows
                         size:tableSize
                   parameters:[AKArray arrayFromConstants:
                               akpi(AKWindowTableTypeKaiser),
                               akp(maximum),
                               akp(windowOpenness), nil] ];
    
}

@end
