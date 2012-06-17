//
//  CSDSoundFileTable.m
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDSoundFileTable.h"

@implementation CSDSoundFileTable

-(id) initWithFilename:(NSString *) file {
    NSString * parameters = [NSString stringWithFormat:@"%@ 0 0 0", file];
    return [super initWithTableSize:0 GenRoutine:kGenRoutineSoundFile Parameters:parameters];
}
@end
