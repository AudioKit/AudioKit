//
//  AKArrayTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKArrayTable.h"

@implementation AKArrayTable


- (instancetype)initWithArray:(AKArray *)parameterArray; 
{
    return [self initWithType:kFTArray
                         size:[parameterArray count]
                   parameters:parameterArray];
}
- (instancetype)initWithArray:(AKArray *)parameterArray size:(int)tableSize;
{
    return [self initWithType:kFTArray
                         size:tableSize
                   parameters:parameterArray];
}

@end
