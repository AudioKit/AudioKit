//
//  OCSFoscili.h
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "OCSOpcode.h"

/** Basic frequency modulated oscillator with linear interpolation.
 */
 
@interface OCSFoscili : OCSOpcode 

@property (nonatomic, strong) OCSParam *output;

/// Initialization Statement
- (id)initWithAmplitude:(OCSParam *)amp
              Frequency:(OCSParamControl *)cps
                Carrier:(OCSParam *)car
             Modulation:(OCSParam *)mod
               ModIndex:(OCSParamControl *)aModIndex
          FunctionTable:(OCSFunctionTable *)f
       AndOptionalPhase:(OCSParamConstant *)phs;

@end
