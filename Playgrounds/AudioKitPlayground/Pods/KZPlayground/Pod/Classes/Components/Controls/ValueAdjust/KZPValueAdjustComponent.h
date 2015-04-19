//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 21/10/14.
//
//
//


@import Foundation;
@import UIKit;
@class KZPValueAdjustComponent;

//! only generates rounded values
extern KZPValueAdjustComponent * __attribute__((overloadable)) KZPAdjust(NSString *name, int from, int to, void (^block)(int));

extern KZPValueAdjustComponent * __attribute__((overloadable)) KZPAdjust(NSString *name, float from, float to, void (^block)(float));

#define KZPAdjustValue(name, from, to) __block typeof(from) name = from; KZPAdjust(@#name, from, to, ^(typeof(from) value) { name = value; })

@interface KZPValueAdjustComponent : NSObject
@property(nonatomic, weak) UISlider *valueSlider;
@property(nonatomic, copy, readonly) void (^defaultValue)(CGFloat);
+ (KZPValueAdjustComponent*)addValueAdjustWithName:(NSString *)name fromValue:(CGFloat)from toValue:(CGFloat)to withBlock:(CGFloat (^)(CGFloat))block;
@end