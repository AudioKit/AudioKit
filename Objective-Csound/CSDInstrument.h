
//
//  CSDInstrument.h
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDOrchestra.h"
#import "CSDOpcode.h"
#import "CSDFunctionStatement.h"

@interface CSDInstrument : NSObject 

@property (nonatomic, strong) CSDOrchestra * orchestra;
@property (assign) int finalOutput;
@property (nonatomic, strong) NSMutableString * csdRepresentation;

-(id) initWithOrchestra:(CSDOrchestra *) newOrchestra;
-(void) joinOrchestra:(CSDOrchestra *) newOrchestra;
-(void) addOpcode:(CSDOpcode *) newOpcode;
-(void)addFunctionStatement:(CSDFunctionStatement *)newFunctionStatement;
-(NSString *) textForOrchestra;

@end
