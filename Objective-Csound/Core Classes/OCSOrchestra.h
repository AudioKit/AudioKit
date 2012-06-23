//
//  OCSOrchestra.h
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
// OCSOrchestra is a collection of instruments.  

@class OCSInstrument;

@interface OCSOrchestra : NSObject {
    NSMutableArray *instruments;
}
@property (nonatomic, strong) NSMutableArray *instruments;

- (void)addInstrument:(OCSInstrument *) instrument;
- (NSString *)instrumentsForCsd;

@end
