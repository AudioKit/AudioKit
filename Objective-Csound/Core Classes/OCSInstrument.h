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

@interface OCSInstrument : NSObject {
    OCSOrchestra * orchestra;
    NSMutableString * csdRepresentation;
    OCSParamConstant * duration;
   int  _myID;
    NSMutableArray * propertyList;
}

@property (nonatomic, strong) OCSOrchestra * orchestra;
@property (assign) int finalOutput;
@property (nonatomic, strong) NSMutableString * csdRepresentation;
@property (nonatomic, strong) NSMutableArray * propertyList;

-(id) initWithOrchestra:(OCSOrchestra *) newOrchestra;
-(NSString *) uniqueName;
-(void) joinOrchestra:(OCSOrchestra *) newOrchestra;
-(void) addOpcode:(OCSOpcode *) newOpcode;
-(void)addFunctionTable:(OCSFunctionTable *)newFunctionTable;
-(void)playNote:(NSDictionary *)noteEvent;
-(void)playNoteForDuration:(float)duration;
+(void) resetID;
-(void)addProperty:(OCSProperty *)prop;
//-(void)addProperties:(NSArray *)propertyList;
-(void)resetParam:(OCSParam *) p;
-(void)assignOutput:(OCSParam *)out To:(OCSParam *) in; 
@end
