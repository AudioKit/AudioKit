//
//  OCSSoundFileTable.m
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSSoundFileTable.h"

@implementation OCSSoundFileTable

- (id)initWithFilename:(NSString *)filename {
    return [super initWithSize:0 
                    GenRoutine:kGenSoundFile 
                    Parameters:[NSString stringWithFormat:@"\"%@\", 0, 0, 0", filename]];
}

- (id)initWithFilename:(NSString *)filename TableSize:(int)tableSize {
    return [super initWithSize:tableSize 
                    GenRoutine:kGenSoundFile 
                    Parameters:[NSString stringWithFormat:@"\"%@\", 0, 0, 0", filename]];
}
@end
