//
//  OCSSoundFileTable.m
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSSoundFileTable.h"

@implementation OCSSoundFileTable

- (id)initWithFilename:(NSString *)filename {
    return [super initWithType:kFTSoundFile 
                          size:0 
                    parameters:[NSString stringWithFormat:@"\"%@\", 0, 0, 0", filename]];

}

- (id)initWithFilename:(NSString *)filename tableSize:(int)tableSize {
    return [super initWithType:kFTSoundFile 
                          size:tableSize 
                    parameters:[NSString stringWithFormat:@"\"%@\", 0, 0, 0", filename]];
}
@end
