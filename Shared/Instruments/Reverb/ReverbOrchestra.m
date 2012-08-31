//
//  ReverbOrchestra.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ReverbOrchestra.h"
#import "OCSManager.h"

@implementation ReverbOrchestra
@synthesize fx = _fx;
@synthesize toneGenerator = _toneGenerator;

- (id)init
{
    self = [super init];
    if (self) {
        _toneGenerator = [[ToneGenerator alloc] init];
        _fx = [[EffectsProcessor alloc] initWithToneGenerator:_toneGenerator];
        
        [self addInstrument:_toneGenerator];
        [self addInstrument:_fx];
        
        [[OCSManager sharedOCSManager] runOrchestra:self];
    }
    return self;
}


@end
