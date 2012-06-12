//
//  EffectsProcessor.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"

@interface EffectsProcessor : CSDInstrument {
    CSDParam * input;
}
@property (nonatomic, strong) CSDParam * input;
-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra;

@end
