//
//  CSDFunctionStatement.m
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDFunctionStatement.h"

@implementation CSDFunctionStatement
@synthesize integerIdentifier;
@synthesize loadTime;
@synthesize tableSize;
@synthesize generatingRoutine;
@synthesize parameters;


-(id) initWithTableSize:(int) size 
             GenRoutine:(int) gen 
          AndParameters:(NSString *) params {
    return [self initWithNumber:1 LoadTime:0 TableSize:size GenRoutine:gen AndParameters:params];
}

-(id) initWithNumber:(int) i 
            LoadTime:(float) t 
           TableSize:(int) size 
          GenRoutine:(int) gen 
       AndParameters:(NSString *) params {
    self = [super init];
    if (self) {
        integerIdentifier = i;
        loadTime = t;
        tableSize = size;
        generatingRoutine = gen;
        parameters = params;
    }
    return self;
}

-(NSString *) text {
    return [NSString stringWithFormat:@"f%i %0.2f %i %i %@", 
            integerIdentifier, loadTime, tableSize, generatingRoutine, parameters]; 
}
@end
