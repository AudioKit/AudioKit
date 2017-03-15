//
//  AKSporthStack.h
//  AudioKit For iOS
//
//  Created by Joseph Constantakis on 3/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

@interface AKSporthStack : NSObject
- (const char *)popString;
- (float)popFloat;

- (void)pushFloat:(float)f;
- (void)pushString:(char *)str;
@end
