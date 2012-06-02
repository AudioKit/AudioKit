
//
//  CSDInstrument.h
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDOrchestra.h"

//#import "CSDOpcode.h"
//
@interface CSDInstrument : NSObject

@property (nonatomic, strong) CSDOrchestra * orchestra;

//@property (nonatomic, strong) NSString *output;
//@property (nonatomic, strong) NSMutableArray *opcodes;
//@property (nonatomic, strong) NSMutableArray *parameters;
//
//-(id) initWithOutput:(NSString *) outputString;
//-(void) addOpcode:(CSDOpcode *) opcode;
//-(void) addParameter:(id) p;
//-(NSDictionary *) createNoteWithParameters:(NSString *)parameters;
//-(NSString *) csdEntry;

-(id) initWithOrchestra:(CSDOrchestra *) newOrchestra;
-(void) joinOrchestra:(CSDOrchestra *) newOrchestra;
-(NSString *) textForOrchestra;

@end
