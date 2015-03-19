//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 20/10/14.
//
//
//


@import Foundation;
@import UIKit;
@import QuartzCore;

#import "KZPComponent.h"

extern void __attribute__((overloadable)) KZPShow(CALayer *layer);

extern void __attribute__((overloadable)) KZPShow(UIView *view);

extern void __attribute__((overloadable)) KZPShow(UIBezierPath *path);

extern void __attribute__((overloadable)) KZPShow(CGPathRef path);

extern void __attribute__((overloadable)) KZPShow(CGImageRef image);

extern void __attribute__((overloadable)) KZPShow(UIImage *image);

extern void __attribute__((overloadable)) KZPShow(NSString *format, ...);

extern void __attribute__((overloadable)) KZPShow(id obj);

@protocol KZPPresenterDebugProtocol <NSObject>
//! preffered
- (UIImage *)kzp_debugImage;

//! will use if object provides any of [CALayer, UIView, UIBezierPath, UIImage, NSString]
@optional
- (id)debugQuickLookObject;
@end

@interface KZPPresenterComponent : UIView <KZPComponent>
@property(nonatomic, strong) UIImage *image;

- (instancetype)initWithImage:(UIImage *)image type:(NSString *)type;
@end