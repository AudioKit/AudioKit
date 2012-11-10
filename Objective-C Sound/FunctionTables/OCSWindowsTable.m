//
//  OCSWindowsTable.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSWindowsTable.h"

@implementation OCSWindowsTable

- (id)initWithType:(WindowType)windowType
          maxValue:(float)maximumValue    
              size:(int)tableSize; 
{
    return [self initWithType:kFTWindows
                         size:tableSize 
                   parameters:[OCSArray arrayFromParams:
                               ocspi(windowType),ocsp(maximumValue), nil]];
}


- (id)initWithType:(WindowType)windowType
              size:(int)tableSize; 
{
    return [self initWithType:windowType
                     maxValue:1.0f
                         size:tableSize];
}

- (id)initGaussianTypeWithBroadness:(float)windowBroadness
                           maxValue:(float)maximumValue  
                               size:(int)tableSize;
{
    return [self initWithType:kFTWindows 
                         size:tableSize 
                   parameters:[OCSArray arrayFromParams:
                               ocspi(kWindowGaussian),
                               ocsp(maximumValue),
                               ocsp(windowBroadness), nil] ];
}

- (id)initKaiserTypeWithOpenness:(float)windowOpenness
                        maxValue:(float)maximumValue  
                            size:(int)tableSize
{
    return [self initWithType:kFTWindows 
                         size:tableSize 
                   parameters:[OCSArray arrayFromParams:
                               ocspi(kWindowKaiser),
                               ocsp(maximumValue),
                               ocsp(windowOpenness), nil] ];
    
}
@end
