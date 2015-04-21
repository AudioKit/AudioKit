//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 20/10/14.
//
//
//

#import "KZPAnimatorComponent.h"


void __attribute__((overloadable)) KZPAnimate(CGFloat from, CGFloat to, void (^block)(CGFloat)) {
  [KZPAnimatorComponent addAnimatorFromValue:from toValue:to withBlock:block];
}

void __attribute__((overloadable)) KZPAnimate(void (^block)(void)) {
  [KZPAnimatorComponent addAnimatorFromValue:0 toValue:60 withBlock:^(CGFloat v) {
    block();
  }];
}

NSMutableArray *displayLinks = nil;

@interface KZPAnimatorComponent ()
@property(nonatomic, copy) void (^animationBlock)(CGFloat);
@property(nonatomic, assign) CGFloat from;
@property(nonatomic, assign) CGFloat to;

@property(nonatomic, assign) CGFloat accumulator;
@end

@implementation KZPAnimatorComponent

+ (void)addAnimatorFromValue:(CGFloat)from toValue:(CGFloat)to withBlock:(void (^)(CGFloat))block
{
  KZPAnimatorComponent *animation = [KZPAnimatorComponent new];
  animation.animationBlock = block;
  animation.from = from;
  animation.to = to;

  CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:animation selector:@selector(animate:)];
  [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

  if (!displayLinks) {
    displayLinks = [NSMutableArray new];
  }
  [displayLinks addObject:displayLink];
}

+ (void)reset
{
  [displayLinks enumerateObjectsUsingBlock:^(CADisplayLink *obj, NSUInteger idx, BOOL *stop) {
    [obj invalidate];
  }];
  [displayLinks removeAllObjects];
}

- (void)animate:(CADisplayLink *)displayLink
{
  self.accumulator += displayLink.duration * fabs(self.from - self.to) * 0.6;
  if (self.accumulator >= self.to) {
    self.accumulator = self.from;
  }
  self.animationBlock(self.accumulator);
}

- (void)setFrom:(CGFloat)from
{
  _from = from;
  self.accumulator = _from;
}


@end