//
//  CSDFunctionTable.m
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDFunctionTable.h"

@implementation CSDFunctionTable
@synthesize output;
@synthesize integerIdentifier;
@synthesize loadTime;
@synthesize tableSize;
@synthesize generatingRoutine;
@synthesize parameters;
@synthesize text;


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

-(id)initWithOutput:(NSString *)aOutput TableSize:(int)size GenRouting:(int)gen AndParameters:(NSString *)params
{
    self = [super init];
    if (self) {
        output = aOutput;
        //loadTime = t;
        tableSize = size;
        generatingRoutine = gen;
        parameters = params;
        
        //iSine ftgentmp 0, 0, 4096, 10, 1
        //ifno ftgentmp ip1, ip2dummy, isize, igen, iarga, iargb, ...
        if (parameters == nil) {
            text = [NSString stringWithFormat:@"%@ ftgentmp 0, 0, %i, %i\n",
                    output, tableSize, generatingRoutine];
        } else {
            text = [NSString stringWithFormat:@"%@ ftgentmp 0, 0, %i, %i, %@\n",
                    output, tableSize, generatingRoutine, parameters];
        }
        
    }
    NSLog(@"FunctionStatement text: %@", text);
    return self;
    
}
/*
-(NSString *) text {
    return [NSString stringWithFormat:@"f%i %0.2f %i %i %@", 
            integerIdentifier, loadTime, tableSize, generatingRoutine, parameters]; 
}
 */
@end
