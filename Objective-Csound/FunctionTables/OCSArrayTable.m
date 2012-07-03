//
//  OCSArrayTable.m
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSArrayTable.h"

@implementation OCSArrayTable


- (id)initWithArray:(OCSParamArray *)parameterArray; 
{
    return [self initWithType:kFTArray
                         size:[parameterArray count]
                   parameters:parameterArray];
}
- (id)initWithArray:(OCSParamArray *)parameterArray size:(int)tableSize;
{
    return [self initWithType:kFTArray
                         size:tableSize
                   parameters:parameterArray];
}

@end
