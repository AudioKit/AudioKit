//
//  CSDInstrument.h
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDOpcode.h"
#import "CSDFunctionTable.h"
#import "CSDManager.h"
#import "CSDAssignment.h"

//#import "CSDPropertyManager.h"
#import "CSDProperty.h"
#import "CSDOrchestra.h"

@interface CSDInstrument : NSObject {
    CSDOrchestra * orchestra;
    NSMutableString * csdRepresentation;
    CSDParamConstant * duration;
   int  _myID;
    NSMutableArray * propertyList;
}

@property (nonatomic, strong) CSDOrchestra * orchestra;
@property (assign) int finalOutput;
@property (nonatomic, strong) NSMutableString * csdRepresentation;
@property (nonatomic, strong) NSMutableArray * propertyList;

-(id) initWithOrchestra:(CSDOrchestra *) newOrchestra;
-(NSString *) uniqueName;
-(void) joinOrchestra:(CSDOrchestra *) newOrchestra;
-(void) addOpcode:(CSDOpcode *) newOpcode;
-(void)addFunctionTable:(CSDFunctionTable *)newFunctionTable;
-(void)playNote:(NSDictionary *)noteEvent;
-(void)playNoteForDuration:(float)duration;
+(void) resetID;
-(void)addProperty:(CSDProperty *)prop;
//-(void)addProperties:(NSArray *)propertyList;
-(void)resetParam:(CSDParam *) p;
-(void)assignOutput:(CSDParam *)out To:(CSDParam *) in; 
@end
