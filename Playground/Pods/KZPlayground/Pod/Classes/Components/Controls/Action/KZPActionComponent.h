//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 21/10/14.
//
//
//


@import Foundation;

#import "KZPComponent.h"

extern void __attribute__((overloadable)) KZPAction(NSString *name, void (^block)(void));

@interface KZPActionComponent : NSObject <KZPComponent>
+ (void)addCallToActionWithName:(NSString *)name block:(void (^)())block;
@end