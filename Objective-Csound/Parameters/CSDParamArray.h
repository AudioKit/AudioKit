//
//  CSDParamArray.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDParamArray : NSObject
{
    NSString * parameterString;
    NSUInteger count;
    float      numbers[0];
}
@property (nonatomic, strong) NSString *parameterString;

+ (id)paramFromFloats:(float *)numbers count:(NSUInteger)count;
@end
