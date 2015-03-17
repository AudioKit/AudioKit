//
//  Created by merowing on 22/10/14.
//
//
//

#import "KZPAnimatorComponent.h"
#import "KZPPresenterComponent.h"
#import "KZPValueAdjustComponent.h"
#import "KZPActionComponent.h"
#import "KZPSynchronizationComponent.h"
#import "KZPImagePickerComponent.h"
#import "KZPPlaygroundViewController.h"

@import Foundation;
@import UIKit;@class KZPPlaygroundViewController;

extern NSString *const KZPPlaygroundDidChangeImplementationNotification;

//! adapt KZPActivePlayground in a KZPPlayground class that you want to use as active playground
@protocol KZPActivePlayground
@end

@interface KZPPlayground : NSObject
@property(nonatomic, weak, readonly) UIView *worksheetView;
@property(nonatomic, weak, readonly) UIViewController *viewController;
@property(nonatomic, weak, readonly) KZPPlaygroundViewController *playgroundViewController;

//! objects store that will be re-created with recompilation, use eg. instead of instance variables
@property(nonatomic, strong, readonly) NSMutableDictionary *transientObjects;

- (instancetype)init NS_REQUIRES_SUPER NS_DESIGNATED_INITIALIZER;

//! called only once
- (void)setup;

//! called on each code change
- (void)run;
@end