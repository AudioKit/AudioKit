//
//  AKParameter.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#define akp(__f__)  [[AKParameter alloc] initAsConstant:__f__]

#import <Foundation/Foundation.h>

@interface AKParameter : NSObject

- (instancetype)initAsConstant:(float)value;

- (void)bind:(float *)binding;

// Probably goes to AKOperation
- (void)create;
- (Float32)compute;
- (void)destroy;

//- (float **)value;
@property float *value;

@end
