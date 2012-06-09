//
//  CSDInstrument.h
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDOpcode.h"
#import "CSDFunctionTable.h"

@class CSDOrchestra;

@interface CSDInstrument : NSObject {
    CSDOrchestra * orchestra;
    NSMutableString * csdRepresentation;
}

@property (nonatomic, strong) CSDOrchestra * orchestra;
@property (assign) int finalOutput;
@property (nonatomic, strong) NSMutableString * csdRepresentation;

-(id) initWithOrchestra:(CSDOrchestra *) newOrchestra;
-(void) joinOrchestra:(CSDOrchestra *) newOrchestra;
-(void) addOpcode:(CSDOpcode *) newOpcode;
-(void)addFunctionTable:(CSDFunctionTable *)newFunctionTable;

@end
