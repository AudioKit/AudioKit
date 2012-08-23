//
//  OCSUserDefinedOperation.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOperation.h"

/** User-defined opcodes found on csounds.com and elsewhere.  Differs from
 OCS opcodes because the definition is made in .udo files.  
 */

@interface OCSUserDefinedOperation : OCSOperation 
/** @returns The location of the udo file */
- (NSString *) udoFile;
@end
