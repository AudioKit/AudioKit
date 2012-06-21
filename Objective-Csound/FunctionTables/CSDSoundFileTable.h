//
//  CSDSoundFileTable.h
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDFunctionTable.h"

@interface CSDSoundFileTable : CSDFunctionTable

-(id) initWithFilename:(NSString *) file;
-(id) initWithFilename:(NSString *) file TableSize:(int)tableSize;

@end


