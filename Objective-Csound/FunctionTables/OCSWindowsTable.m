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

- (id)initWithType:(WindowType)windowType
          maxValue:(int)maximumValue    
              size:(int)tableSize; 
{
    return [self initWithType:(-kFTWindows)
                         size:tableSize 
                   parameters:[NSString stringWithFormat:@"%d %g", windowType, maximumValue]];
}


- (id)initWithType:(WindowType)windowType
              size:(int)tableSize; 
{
    return [self initWithType:windowType
                     maxValue:1
                         size:tableSize];
}

- (id)initGaussianTypeWithBroadness:(float)windowBroadness
                           maxValue:(int)maximumValue  
                               size:(int)tableSize;
{
    return [self initWithType:kFTWindows 
                         size:tableSize 
                   parameters:[NSString stringWithFormat:@"%d %g", kWindowGaussian, maximumValue, windowBroadness]];
}

- (id)intKaiserTypeWithOpenness:(float)windowOpenness
                       maxValue:(int)maximumValue  
                           size:(int)tableSize
{
    return [self initWithType:kFTWindows 
                         size:tableSize 
                   parameters:[NSString stringWithFormat:@"%d %g", kWindowKaiser, maximumValue, windowOpenness]];
    
}
@end
