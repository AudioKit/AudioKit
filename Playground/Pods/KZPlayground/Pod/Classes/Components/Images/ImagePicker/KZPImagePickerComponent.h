//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 21/10/14.
//
//
//


@import Foundation;

#import "KZPComponent.h"

@class KZPPresenterComponent;

extern void __attribute__((overloadable)) KZPAdjust(NSString *name, void (^block)(UIImage *));
#define KZPAdjustImage(name) __block UIImage *name = nil; KZPAdjust(@#name, ^(UIImage* value) { name = value; })

@interface KZPImagePickerComponent : NSObject <KZPComponent>
+ (void)addImagePickerWithName:(NSString *)name block:(void (^)(UIImage *))block;
@end