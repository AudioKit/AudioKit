//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 20/10/14.
//
//
//


#import <objc/runtime.h>
#import "KZPPresenterComponent.h"
#import "KZPTimelineViewController.h"
#import "KZPSnapshotView.h"
#import "KZPPresenterInfoViewController.h"

static NSString *KZPShowType = nil;

void KZPShowRegisterType(NSString *format, ...) {
  if (format == nil) {
    KZPShowType = nil;
    return;
  }

  if (KZPShowType) {
    return;
  }

  va_list args;
  va_start(args, format);
  KZPShowType = [[NSString alloc] initWithFormat:format arguments:args];
  va_end(args);
}

void KZPShowRegisterClass(id instance, Class baseClass) {
  if (![instance isMemberOfClass: baseClass]) {
    KZPShowRegisterType(@"%@:%@", NSStringFromClass([instance class]), NSStringFromClass(baseClass));
    return;
  }

  KZPShowRegisterType(NSStringFromClass(baseClass));
}

void __attribute__((overloadable)) KZPShow(CALayer *layer) {
  KZPShowRegisterClass(layer, CALayer.class);

  UIGraphicsBeginImageContextWithOptions(layer.bounds.size, NO, 0);
  [layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  KZPShow(copied);
}

void __attribute__((overloadable)) KZPShow(UIView *view) {
  KZPShowRegisterClass(view, UIView.class);

  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
  [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  KZPShow(image);
}

void __attribute__((overloadable)) KZPShow(CGPathRef path) {
  KZPShowRegisterType(@"CGPathRef");

  UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path];
  [bezierPath setLineWidth:3];
  [bezierPath setLineJoinStyle:kCGLineJoinBevel];
  KZPShow(bezierPath);
}


void __attribute__((overloadable)) KZPShow(UIBezierPath *path) {
  KZPShowRegisterType(@"UIBezierPath");

  CGRect rect = CGRectMake(0, 0, CGRectGetWidth(path.bounds) + path.lineWidth, CGRectGetHeight(path.bounds) + path.lineWidth);
  CGContextRef context = UIGraphicsGetCurrentContext();
  UIGraphicsPushContext(context);
  UIGraphicsBeginImageContext(rect.size);
  UIBezierPath *copiedPath = path.copy;
  [copiedPath applyTransform:CGAffineTransformMakeTranslation(path.lineWidth * 0.5, path.lineWidth * 0.5)];
  [copiedPath stroke];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsPopContext();
  UIGraphicsEndImageContext();

  KZPShow(image);
}

void __attribute__((overloadable)) KZPShow(CGImageRef image) {
  KZPShowRegisterType(@"CGImageRef");

  KZPShow([UIImage imageWithCGImage:image]);
}

void __attribute__((overloadable)) KZPShow(UIImage *image) {
  KZPShowRegisterType(@"UIImage");

  KZPPresenterComponent *presenter = [[KZPPresenterComponent alloc] initWithImage:image type:KZPShowType];
  if (!presenter) {
    KZPShow(@"Error: Unable to present image with size %@", NSStringFromCGSize(image.size));
    return;
  }
  [[KZPTimelineViewController sharedInstance] addView:presenter];
  KZPShowRegisterType(nil);
}

void __attribute__((overloadable)) KZPShow(NSString *format, ...) {
  KZPShowRegisterType(@"NSString");

  va_list args;
  va_start(args, format);
  NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
  va_end(args);

  UILabel *label = [[UILabel alloc] init];
  label.text = message;
  label.numberOfLines = 0;
  label.textColor = [UIColor blackColor];
  CGSize size = [label sizeThatFits:CGSizeMake([KZPTimelineViewController sharedInstance].maxWidthForSnapshotView, CGFLOAT_MAX)];
  label.frame = CGRectMake(0, 0, size.width, size.height);

  [[KZPTimelineViewController sharedInstance] addView:label];
  KZPShowRegisterType(nil);
}

void __attribute__((overloadable)) KZPShow(id obj) {
  if ([obj respondsToSelector:@selector(kzp_debugImage)]) {
    UIImage *image = [obj performSelector:@selector(kzp_debugImage)];
    KZPShow(image);
    return;
  }

  if ([obj respondsToSelector:@selector(debugQuickLookObject)]) {
    id debugObject = [obj debugQuickLookObject];

#define SHOW_IF(type) if([debugObject isKindOfClass:type.class]) {KZPShow((type*)debugObject); return;}
    SHOW_IF(CALayer);
    SHOW_IF(UIView);
    SHOW_IF(UIBezierPath);
    SHOW_IF(UIImage);
    SHOW_IF(NSString);
#undef SHOW_IF
  }

  KZPShow([NSString stringWithFormat:@"%@ : %@", NSStringFromClass([obj class]), [obj description]]);
}

@interface KZPPresenterComponent () <KZPSnapshotView>
@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, copy) NSString *type;
@end

@implementation KZPPresenterComponent
- (instancetype)initWithImage:(UIImage *)image type:(NSString *)type
{
  self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
  if (!self) {
    return nil;
  }

  _image = image;
  _type = [type copy];
  [self setup];
  return self;
}

- (void)setup
{
  UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.frame = self.bounds;
  imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self addSubview:imageView];
  self.imageView = imageView;
}

- (BOOL)hasExtraInformation
{
  return YES;
}

- (void)setImage:(UIImage *)image
{
  _image = image;
  self.imageView.image = image;
}


- (UIViewController *)extraInfoController
{
  KZPPresenterInfoViewController *presenterInfoViewController = [KZPPresenterInfoViewController new];
  NSString *title = [NSString stringWithFormat:@"%@ %.0f x %.0f", self.type, self.image.size.width, self.image.size.height];
  [presenterInfoViewController setFromImage:self.image title:title];
  return presenterInfoViewController;
}

+ (void)reset
{

}

@end