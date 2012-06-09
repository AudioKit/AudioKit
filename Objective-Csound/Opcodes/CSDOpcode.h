//
//  CSDOpcode.h
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDParam.h"

@interface CSDOpcode : NSObject {
    NSString * type;
    CSDParam * output;
    NSString * opcode;
}

@property (nonatomic, strong) CSDParam * output;
@property (nonatomic, strong) NSString * opcode;

-(id) initWithType:(NSString *)t;
-(NSString *) convertToCsd;

@end
