//
//  CSDOpcode.h
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDOpcode : NSObject 

@property (nonatomic, strong) NSString * output;
@property (nonatomic, strong) NSString * opcode;
@property (nonatomic, strong) NSString * parameters; 

-(NSString *) textWithPValue:(int)p;

@end
