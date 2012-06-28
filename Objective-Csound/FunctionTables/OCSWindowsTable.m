//
//  OCSWindowsTable.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSWindowsTable.h"

@implementation OCSWindowsTable
//normalized to one version

- (id)initWithSize:(int)tableSize 
        windowType:(WindowType)windowType 
          maxValue:(int)maximumValue
{
    return [self initWithType:(-kFTWindows)
                         size:tableSize 
                   parameters:[NSString stringWithFormat:@"%d %d", windowType, maximumValue]];
}

- (id)initWithSize:(int)tableSize windowType:(WindowType)windowType
{
    return [self initWithType:kFTWindows 
                         size:tableSize 
                   parameters:[NSString stringWithFormat:@"%d", windowType]];
}

@end
