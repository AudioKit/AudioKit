//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 21/10/14.
//
//
//


#import "KZPValueAdjustComponent.h"
#import "KZPTimelineViewController.h"

@import ObjectiveC.runtime;

#import <objc/runtime.h>

static const void *kLastValuesKey = &kLastValuesKey;
static const void *kAdjusterLifetimeKey = &kAdjusterLifetimeKey;

extern KZPValueAdjustComponent *__attribute__((overloadable)) KZPAdjust(NSString *name, int from, int to, void (^block)(int)) {
  return [KZPValueAdjustComponent addValueAdjustWithName:name fromValue:from toValue:to withBlock:^(CGFloat d) {
    int rounded = (int)roundf(d);
    block(rounded);
    return (CGFloat)rounded;
  }];
}

extern KZPValueAdjustComponent *__attribute__((overloadable)) KZPAdjust(NSString *name, float from, float to, void (^block)(float)) {
  return [KZPValueAdjustComponent addValueAdjustWithName:name fromValue:(CGFloat)from toValue:(CGFloat)to withBlock:^CGFloat(CGFloat d) {
    block((float)d);
    return d;
  }];
}


@interface KZPValueAdjustComponent ()

@property(nonatomic, weak) UILabel *nameLabel;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) CGFloat (^changeBlock)(CGFloat);
@end

@implementation KZPValueAdjustComponent

+ (KZPValueAdjustComponent *)addValueAdjustWithName:(NSString *)name fromValue:(CGFloat)from toValue:(CGFloat)to withBlock:(CGFloat (^)(CGFloat))block
{
  return [[KZPValueAdjustComponent alloc] initWithName:name fromValue:from toValue:to changeBlock:block];
}

- (instancetype)initWithName:(NSString *)name fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue changeBlock:(CGFloat (^)(CGFloat))changeBlock
{
  self = [super init];
  if (!self) {
    return nil;
  }

  KZPTimelineViewController *timelineViewController = [KZPTimelineViewController sharedInstance];
  CGFloat controlWidth = timelineViewController.maxWidthForSnapshotView;

  UISlider *slider = [self createSliderWithWidth:controlWidth minValue:fromValue maxValue:toValue];
  UILabel *nameLabel = [self createNameLabelWithWidth:controlWidth];

  self.name = name;
  self.valueSlider = slider;
  self.nameLabel = nameLabel;
  self.changeBlock = changeBlock;

  [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];

  [timelineViewController addView:nameLabel];
  [timelineViewController addView:slider];

  //! bind adjuster lifetime to the slider itself
  objc_setAssociatedObject(slider, kAdjusterLifetimeKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  NSNumber *previousValue = self.class.lastValues[name];
  float value = previousValue ? previousValue.floatValue : fromValue;
  [self setCurrentValueWithoutPersistence:value];

  return self;
}

- (void (^)(CGFloat))defaultValue
{
  __weak typeof(self) weakSelf = self;
  return ^(CGFloat value) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    BOOL isInitializing = ![strongSelf.class lastValues][strongSelf.name];
    if (isInitializing) {
      [strongSelf setCurrentValueWithoutPersistence:value];
    }
  };

}

- (UISlider *)createSliderWithWidth:(CGFloat)sliderWidth minValue:(CGFloat)minValue maxValue:(CGFloat)maxValue
{
  UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, sliderWidth, 44)];
  slider.minimumValue = minValue;
  slider.maximumValue = maxValue;
  [slider sizeToFit];
  return slider;
}

- (UILabel *)createNameLabelWithWidth:(CGFloat)width
{
  UILabel *nameLabel = [UILabel new];
  nameLabel.textColor = [UIColor blackColor];
  nameLabel.textAlignment = NSTextAlignmentCenter;
  nameLabel.text = @"Sizing";
  [nameLabel sizeToFit];
  nameLabel.frame = CGRectMake(0, 0, width, CGRectGetHeight(nameLabel.bounds));
  return nameLabel;
}

- (void)setCurrentValueWithoutPersistence:(CGFloat)value
{
  CGFloat adjustedValue = self.changeBlock(value);
  [self.valueSlider setValue:adjustedValue];
  self.nameLabel.text = [NSString stringWithFormat:@"%@ %.2f", self.name, adjustedValue];
}

- (void)sliderChanged:(UISlider *)sliderChanged
{
  CGFloat adjustedValue = self.changeBlock(sliderChanged.value);
  self.nameLabel.text = [NSString stringWithFormat:@"%@ %.2f", self.name, adjustedValue];
  self.class.lastValues[self.name] = @(adjustedValue);
}

#pragma mark - Helpers

+ (NSMutableDictionary *)lastValues
{
  NSMutableDictionary *lastValues = objc_getAssociatedObject(self, kLastValuesKey);
  if (!lastValues) {
    lastValues = [NSMutableDictionary new];
    objc_setAssociatedObject(self, kLastValuesKey, lastValues, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return lastValues;
}

+ (void)reset
{
}

@end