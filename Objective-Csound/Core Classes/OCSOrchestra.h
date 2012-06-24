//
//  OCSOrchestra.h
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
// OCSOrchestra is a collection of instruments.  

@class OCSInstrument;
@class OCSUserDefinedOpcode;

@interface OCSOrchestra : NSObject {
    NSMutableArray *instruments;
    NSMutableArray *myUDOs;
}
@property (nonatomic, strong) NSMutableArray *instruments;

- (void)addInstrument:(OCSInstrument *)instrument;
- (void)addUDO:(OCSUserDefinedOpcode *)udo;
- (NSString *)stringForCSD;

@end
