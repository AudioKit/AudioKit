//
//  OCSSoundFileTable.m
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSSoundFileTable.h"

@implementation OCSSoundFileTable

-(id) initWithFilename:(NSString *)file {
    parameters = [NSString stringWithFormat:@"\"%@\", 0, 0, 0", file];
    return [super initWithSize:0 
                    GenRoutine:kGenSoundFile 
                    Parameters:parameters];
}

-(id) initWithFilename:(NSString *)file TableSize:(int)size {
    parameters = [NSString stringWithFormat:@"\"%@\", 0, 0, 0", file];
    return [super initWithSize:size 
                    GenRoutine:kGenSoundFile 
                    Parameters:parameters];
}
@end
