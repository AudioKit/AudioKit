//
//  AKInverse.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter+Operation.h"

NS_ASSUME_NONNULL_BEGIN
@interface AKInverse : AKParameter

- (instancetype)initWIthInput:(AKParameter *)input;

@end
NS_ASSUME_NONNULL_END
