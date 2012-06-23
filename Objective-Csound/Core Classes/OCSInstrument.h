//
//  OCSInstrument.h
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSOpcode.h"
#import "OCSFunctionTable.h"
#import "OCSManager.h"
#import "OCSAssignment.h"

//#import "OCSPropertyManager.h"
#import "OCSProperty.h"
#import "OCSOrchestra.h"

#define ocsp(__f__) [OCSParamConstant paramWithFloat:__f__]

@interface OCSInstrument : NSObject {
    OCSOrchestra * orchestra;
    OCSParamConstant * duration;
    NSMutableString * innerCSDRepresentation;
    int  _myID;
    NSMutableArray * propertyList;
}

@property (nonatomic, strong) OCSOrchestra * orchestra;
@property (assign) int finalOutput;
@property (nonatomic, strong) NSMutableArray * propertyList;

- (NSString *)uniqueName;
- (void)joinOrchestra:(OCSOrchestra *) orch;
- (void)addOpcode:(OCSOpcode *)opcode;
- (void)addString:(NSString *) str;
- (void)addFunctionTable:(OCSFunctionTable *)newFunctionTable;
- (void)playNoteForDuration:(float)duration;
+ (void)resetID;
- (void)addProperty:(OCSProperty *)prop;
//-(void)addProperties:(NSArray *)propertyList;
- (void)resetParam:(OCSParam *) p;
- (void)assignOutput:(OCSParam *)out To:(OCSParam *) in; 
- (NSString *)csdRepresentation;
@end
