//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 21/10/14.
//
//
//


#import <objc/runtime.h>
#import "KZPImagePickerComponent.h"
#import "KZPTimelineViewController.h"
#import "KZPPresenterComponent.h"
#import "KZPImagePickerCollectionViewController.h"

void __attribute__((overloadable)) KZPAdjust(NSString *name, void (^block)(UIImage *)) {
  [KZPImagePickerComponent addImagePickerWithName:name block:block];
}

static const void *kAdjusterLifetimeKey = &kAdjusterLifetimeKey;

static const NSInteger kLibraryButtonIndex = 0;
static const NSInteger kAssetButtonIndex = 1;

@interface KZPImagePickerComponent () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property(nonatomic, weak) KZPPresenterComponent *presenterComponent;
@property(nonatomic, copy) void (^changeBlock)(UIImage *);
@property(nonatomic, copy) NSString *name;
@end

@implementation KZPImagePickerComponent
+ (void)addImagePickerWithName:(NSString *)name block:(void (^)(UIImage *))block
{
  id __unused unused = [[KZPImagePickerComponent alloc] initWithName:name block:block];
}

- (id)initWithName:(NSString *)name block:(void (^)(UIImage *))block
{
  self = [super init];
  if (!self) {
    return nil;
  }

  self.name = name;

  KZPTimelineViewController *timelineViewController = [KZPTimelineViewController sharedInstance];

  KZPPresenterComponent *presenterComponent = [[KZPPresenterComponent alloc] initWithImage:self.class.lastValues[name] type:@"UIImage"];
  presenterComponent.frame = CGRectMake(0, 0, timelineViewController.maxWidthForSnapshotView, timelineViewController.maxWidthForSnapshotView);
  presenterComponent.backgroundColor = UIColor.blackColor;

  UIButton *button = [self setupButtonWithName:name];

  button.center = presenterComponent.center;
  [presenterComponent addSubview:button];

  [timelineViewController addView:presenterComponent];
  self.presenterComponent = presenterComponent;
  self.changeBlock = block;
  objc_setAssociatedObject(presenterComponent, kAdjusterLifetimeKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  return self;
}

- (UIButton *)setupButtonWithName:(NSString *)name
{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
  [button setTitle:[NSString stringWithFormat:@" %@", name] forState:UIControlStateNormal];
  button.titleLabel.adjustsFontSizeToFitWidth = YES;
  button.titleLabel.font = [UIFont systemFontOfSize:14];
  button.layer.cornerRadius = 8;
  [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
  [button setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
  [button sizeToFit];
  [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  return button;
}

- (void)buttonPressed:(UIButton *)button
{
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Assets", nil];
  [sheet showFromRect:[button.superview convertRect:button.bounds fromView:button] inView:button.superview animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == kLibraryButtonIndex) {
    [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
  } else if (buttonIndex == kAssetButtonIndex) {
    [self showAssetPicker];
  }
}

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
  UIImagePickerController *controller = [UIImagePickerController new];
  controller.modalPresentationStyle = UIModalPresentationCurrentContext;
  controller.sourceType = sourceType;
  controller.delegate = self;

  KZPTimelineViewController *timelineViewController = [KZPTimelineViewController sharedInstance];
  [timelineViewController presentViewController:controller animated:YES completion:nil];
}

- (void)showAssetPicker
{
  KZPImagePickerCollectionViewController *assetCollectionViewController =
    [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:@"KZPImagePickerCollectionViewController"];

  __weak typeof(self) weakSelf = self;
  assetCollectionViewController.onSelectionBlock = ^(UIImage *image) {
    weakSelf.selectedImage = image;
  };

  KZPTimelineViewController *timelineViewController = [KZPTimelineViewController sharedInstance];
  [timelineViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:assetCollectionViewController] animated:YES completion:nil];
}

- (void)setSelectedImage:(UIImage*)image
{
  self.presenterComponent.image = image;
  self.changeBlock(image);
  self.class.lastValues[self.name] = image;
}
#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
  self.selectedImage = image;
  [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Helpers

static const void *kLastValuesKey = &kLastValuesKey;

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