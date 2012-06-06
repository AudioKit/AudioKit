//
//  CSDFunctionStatement.h
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDFunctionStatement : NSObject
//f number  load-time  table-size  GEN  Routine  parameter1  parameter...  ; COMMENT
{
    NSString *text;
}

@property int   integerIdentifier;
@property float loadTime;
@property int   tableSize;
@property int   generatingRoutine;
@property (nonatomic, strong) NSString * parameters;
@property (nonatomic, strong) NSString * output;
@property (readonly) NSString *text;

//-(NSString *) text;

-(id) initWithTableSize:(int) size 
             GenRoutine:(int) gen 
          AndParameters:(NSString *) params;

-(id) initWithNumber:(int) i 
            LoadTime:(float) t 
           TableSize:(int) size 
          GenRoutine:(int) gen 
       AndParameters:(NSString *) params;

-(id)initWithOutput:(NSString *)aOutput
          TableSize:(int)size
         GenRouting:(int)gen
      AndParameters:(NSString *)params;

@end
