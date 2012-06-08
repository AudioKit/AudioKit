//
//  CSDParamArray.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDParam.h"

@interface CSDParamArray : NSObject
{
    NSString * parameterString;
    NSUInteger count;
    float      numbers[0];
}
@property (nonatomic, strong) NSString *parameterString;
@property (readonly) NSUInteger count;

+ (id)paramFromFloats:(float *)numbers count:(NSUInteger)count;
+ (id)paramFromParams:(CSDParam *)params count:(NSUInteger)count;
@end
