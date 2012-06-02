//
//  CSDOrchestra.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSDInstrument;
@class CSDFunctionStatement;

// H4Y - AOP still not sure whether instruments and F-Statements
// need to be classes or just implement protocols
@protocol CSDInstrument
-(NSString *) orchestraText;
@end
//
//@protocol CSDFunctionStatement
//-(NSString *) orchestraText;
//@end


@interface CSDOrchestra : NSObject 



@property (nonatomic, strong) NSMutableArray * instruments;
//@property (nonatomic, strong) NSMutableArray * functionStatements;

-(int) addInstrument:(CSDInstrument *) instrument;
//-(void) addFunctionStatement:(CSDFunctionStatement *) f;

@end
