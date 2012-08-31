//
//  ReverbOrchestra.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOrchestra.h"
#import "ToneGenerator.h"
#import "EffectsProcessor.h"

@interface ReverbOrchestra : OCSOrchestra

@property (nonatomic, strong) EffectsProcessor *fx;
@property (nonatomic, strong) ToneGenerator *toneGenerator;

@end
