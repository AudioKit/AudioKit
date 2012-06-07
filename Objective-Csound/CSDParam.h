//
//  CSDParam.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/5/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDOpcode.h"

@interface CSDParam : NSObject
{
    NSString * parameterString;
}
@property (nonatomic, strong) NSString *parameterString;

-(id)init;
-(id)initWithString:(NSString *)aString;
-(id)initWithFloat:(float)aFloat;
-(id)initWithInt:(int)aInt;
-(id)initWithOpcode:(CSDOpcode *)aOpcode;
-(id)initWithPValue:(int)aPValue;
+(id)paramWithString:(NSString *)aString;
+(id)paramWithFloat:(float)aFloat;
+(id)paramWithInt:(int)aInt;
+(id)paramWithOpcode:(CSDOpcode *)aOpcode;
+(id)paramWithPValue:(int)aPValue;

@end
