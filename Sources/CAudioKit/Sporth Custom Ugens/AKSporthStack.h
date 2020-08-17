// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <Foundation/Foundation.h>

@interface AKSporthStack : NSObject
- (const char *)popString;
- (float)popFloat;

- (void)pushFloat:(float)f;
- (void)pushString:(char *)str;
@end
