//
//  CSDOpcode.h
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDParamArray.h"
#import "CSDFunctionTable.h"

@interface CSDOpcode : NSObject {
    int _myID;
}

@property (nonatomic, strong) NSString * opcode;

-(NSString *) uniqueName;
-(NSString *) convertToCsd;
+(void) resetID;
@end
