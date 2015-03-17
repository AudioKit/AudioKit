#import "KZPPlayground.h"

@interface KZPPlayground (Internal)
@property(nonatomic, weak, readwrite) UIView *worksheetView;
@property(nonatomic, weak, readwrite) UIViewController *viewController;
@property(nonatomic, weak, readwrite) KZPPlaygroundViewController *playgroundViewController;
@end