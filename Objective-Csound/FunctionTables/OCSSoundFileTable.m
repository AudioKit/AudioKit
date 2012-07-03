//
//  OCSSoundFileTable.m
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSSoundFileTable.h"
#import "OCSParameterArray.h"

@implementation OCSSoundFileTable

- (id)initWithFilename:(NSString *)filename {
    return [self initWithFilename:filename tableSize:0];

}

- (id)initWithFilename:(NSString *)filename tableSize:(int)tableSize {
    OCSParameterArray *parameters = [OCSParameterArray paramArrayFromParams:
                                 ocspfn(filename), ocsp(0), ocsp(0), ocsp(0), nil];
    return [super initWithType:kFTSoundFile 
                         size:tableSize 
                   parameters:parameters];
}
@end
