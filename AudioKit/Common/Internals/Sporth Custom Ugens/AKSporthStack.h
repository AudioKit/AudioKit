//
//  AKSporthStack.h
//  AudioKit
//
//  Created by Joseph Constantakis, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

@interface AKSporthStack : NSObject
- (const char *)popString;
- (float)popFloat;

- (void)pushFloat:(float)f;
- (void)pushString:(char *)str;
@end
