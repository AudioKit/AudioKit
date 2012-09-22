//
//  OCSNote.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSNoteProperty.h"

@interface OCSNote : NSObject

@property (nonatomic, strong) OCSInstrument *instrument;
@property (nonatomic, strong) NSMutableDictionary *properties;

@end
