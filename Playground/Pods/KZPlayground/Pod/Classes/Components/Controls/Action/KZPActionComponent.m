//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 21/10/14.
//
//
//


#import <objc/runtime.h>
#import "KZPActionComponent.h"
#import "KZPTimelineViewController.h"

static const void *kActionBlockKey = &kActionBlockKey;

void __attribute__((overloadable)) KZPAction(NSString *name, void (^block)(void)) {
  [KZPActionComponent addCallToActionWithName:name block:block];
}

@implementation KZPActionComponent
+ (void)addCallToActionWithName:(NSString *)name block:(void (^)())block
{
  KZPTimelineViewController *timelineViewController = [KZPTimelineViewController sharedInstance];

  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  [button setTitle:name forState:UIControlStateNormal];
  [button setTitleColor:UIColor.brownColor forState:UIControlStateNormal];
  button.titleLabel.adjustsFontSizeToFitWidth = YES;
  CGSize size = [button sizeThatFits:CGSizeMake(timelineViewController.maxWidthForSnapshotView, CGFLOAT_MAX)];
  button.frame = CGRectMake(0, 0, size.width, size.height);
  objc_setAssociatedObject(button, kActionBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
  [button addTarget:self action:@selector(actionWithButton:) forControlEvents:UIControlEventTouchUpInside];
  [timelineViewController addView:button];
}

+ (void)actionWithButton:(UIButton *)button
{
  void(^block)(void) = objc_getAssociatedObject(button, kActionBlockKey);
  block();
}

+ (void)reset
{

}

@end