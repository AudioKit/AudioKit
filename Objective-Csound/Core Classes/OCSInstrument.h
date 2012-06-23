//
//  OCSInstrument.h
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSOrchestra.h"
#import "OCSOpcode.h"
#import "OCSProperty.h"

#define ocsp(__f__) [OCSParamConstant paramWithFloat:__f__]

@interface OCSInstrument : NSObject {
    OCSOrchestra *orchestra;
    OCSParamConstant *duration;
    NSMutableString *innerCSDRepresentation;
    int  _myID;
    NSMutableArray *properties;
}
@property (nonatomic, strong) NSMutableArray *properties;

- (NSString *)uniqueName;
- (void)addProperty:(OCSProperty *)prop;
- (void)addFunctionTable:(OCSFunctionTable *)newFunctionTable;
- (void)addOpcode:(OCSOpcode *)opcode;
- (void)addString:(NSString *) str;
- (void)assignOutput:(OCSParam *)out To:(OCSParam *) in; 
- (void)resetParam:(OCSParam *) p;
- (void)joinOrchestra:(OCSOrchestra *) orch;
- (NSString *)csdRepresentation;
- (void)playNoteForDuration:(float)duration;
+ (void)resetID;

@end
