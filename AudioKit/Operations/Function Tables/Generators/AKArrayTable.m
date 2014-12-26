//
//  AKArrayTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKArrayTable.h"

@implementation AKArrayTable


- (instancetype)initWithArray:(AKArray *)parameterArray; 
{
    return [self initWithType:AKFunctionTableTypeArray
                         size:[parameterArray count]
                   parameters:parameterArray];
}

- (instancetype)initWithArray:(AKArray *)parameterArray size:(int)tableSize;
{
    return [self initWithType:AKFunctionTableTypeArray
                         size:tableSize
                   parameters:parameterArray];
}

@end
