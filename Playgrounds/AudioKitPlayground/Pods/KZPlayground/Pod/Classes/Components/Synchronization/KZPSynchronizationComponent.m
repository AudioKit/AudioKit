//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 20/10/14.
//
//
//

#import <objc/runtime.h>
#import "KZPSynchronizationComponent.h"

void KZPWaitForEvaluation(id (^valueGetter)(), void (^completion)(id)) {
  [KZPSynchronizationComponent addComponentWithGetter:valueGetter completion:completion];
}

static const void *kComponentsKey = &kComponentsKey;
static const void *kIsFinishedKey = &kIsFinishedKey;

@interface KZPSynchronizationComponent ()
@property(nonatomic, copy) id (^valueGetter)(void);
@property(nonatomic, copy) void (^completion)(id);
@end

@implementation KZPSynchronizationComponent

+ (void)addComponentWithGetter:(id (^)())valueGetter completion:(void (^)(id))completion
{
  KZPSynchronizationComponent *component = [KZPSynchronizationComponent new];
  component.valueGetter = valueGetter;
  component.completion = completion;
  [self addComponent:component];
}

+ (void)addComponent:(KZPSynchronizationComponent *)component
{
  @synchronized (self) {
    [self.components addObject:component];
  }
}

+ (NSMutableArray *)components
{
  NSMutableArray *components = objc_getAssociatedObject(self, kComponentsKey);
  if (!components) {
    components = [NSMutableArray new];
    objc_setAssociatedObject(self, kComponentsKey, components, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return components;
}

+ (void)load
{
  [self performSelectorInBackground:@selector(backgroundProcessing) withObject:nil];
}

+ (BOOL)isResetting
{
  return [objc_getAssociatedObject(self, kIsFinishedKey) boolValue];
}

+ (void)setFinished:(BOOL)finished
{
  objc_setAssociatedObject(self, kIsFinishedKey, @(finished), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)backgroundProcessing
{
  @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-noreturn"
    while (YES) {
      NSArray *components = nil;
      @synchronized (self) {
        components = [self.components copy];
      }

      NSMutableArray *componentsToRemove = [NSMutableArray new];

      [components enumerateObjectsUsingBlock:^(KZPSynchronizationComponent *component, NSUInteger idx, BOOL *stop) {
        *stop = [self isResetting];

        BOOL finished = [component evaluate];
        if (finished) {
          [componentsToRemove addObject:component];
        }
      }];

      @synchronized (self) {
        if ([self isResetting]) {
          [self.components removeObjectsInArray:componentsToRemove];
        }
      }

      [NSThread sleepForTimeInterval:0.1];
    }
#pragma clang diagnostic pop
  }
}

- (BOOL)evaluate
{
  __block BOOL finished = NO;
  dispatch_sync(dispatch_get_main_queue(), ^{
    id value = self.valueGetter();
    if (value) {
      self.completion(value);
      finished = YES;
    }
  });

  return finished;
}

+ (void)reset
{
  @synchronized (self) {
    self.finished = YES;
    [[self components] removeAllObjects];
  }
}


@end