//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 20/10/14.
//
//
//


@import Foundation;
@import UIKit;

#import "KZPComponent.h"

// from - to - from - to

extern void __attribute__((overloadable)) KZPAnimate(CGFloat from, CGFloat to, void (^block)(CGFloat));

extern void __attribute__((overloadable)) KZPAnimate(void (^block)(void));

#define KZPAnimateValue(name, from, to) __block CGFloat name = from; KZPAnimate(from, to, ^(CGFloat f) { name = f; });
#define KZPAnimateValueAR(name, from, to) __block CGFloat name = from; KZPAnimate(0, M_PI, ^(CGFloat f) { name = sinf(f) * (to - from) + from; });

#define KZPWhenChanged(value, completion) __block typeof(value) kzp_previous__##value = value; KZPAnimate(^{ if (kzp_previous__##value != value) { kzp_previous__##value = value; completion(value); }})

@interface KZPAnimatorComponent : NSObject <KZPComponent>
+ (void)addAnimatorFromValue:(CGFloat)from toValue:(CGFloat)to withBlock:(void (^)(CGFloat))block;
@end