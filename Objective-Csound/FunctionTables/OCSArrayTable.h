//
//  OCSArrayTable.h
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFTable.h"

/** Constructs a function table out of an NSArray.  If size is unspecififed,
 the array count is used, otherwise if isze is greater than the array count, 
 the rest of the table will be filled with zeroes.
 */

@interface OCSArrayTable : OCSFTable

@end
