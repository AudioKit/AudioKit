//
//  KZPPresenterInfoViewController.m
//  Playground
//
//  Created by Krzysztof Zabłocki on 21/10/2014.
//  Copyright (c) 2014 pixle. All rights reserved.
//

#import "KZPPresenterInfoViewController.h"

@interface KZPPresenterInfoViewController ()
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UIImageView *imageView;

@property(nonatomic, strong) UIImage *image;

@end

@implementation KZPPresenterInfoViewController

- (void)setFromImage:(UIImage *)image title:(NSString *)title
{
  self.image = image;
  self.title = title;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.imageView.image = self.image;
  self.titleLabel.text = self.title;
  [self.view setNeedsLayout];
}

- (CGSize)preferredContentSize
{
  static const NSInteger padding = 10;
  CGSize labelSize = [self.titleLabel sizeThatFits:CGSizeMake(1024, CGRectGetHeight(self.titleLabel.bounds))];
  return CGSizeMake(MAX(self.image.size.width, labelSize.width) + padding * 2, self.image.size.height + CGRectGetHeight(self.titleLabel.bounds) + padding);
}
@end
