//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 25/10/14.
//
//
//


@import Foundation;
@import UIKit;

#import "KZPComponent.h"

void KZPWaitForEvaluation(id (^valueGetter)(), void (^completion)(id));

#define KZPWhenSet(value, completion) KZPWaitForEvaluation(^{return value;}, completion)

@interface KZPSynchronizationComponent : NSObject <KZPComponent>
+ (void)addComponentWithGetter:(id (^)())valueGetter completion:(void (^)(id))completion;

- (BOOL)evaluate;
@end