
@import Foundation;
@import UIKit;

@interface KZPImagePickerCollectionViewCell : UICollectionViewCell
@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, weak) UILabel *titleLabel;
@end

@interface KZPImagePickerCollectionViewController : UICollectionViewController
@property(nonatomic, copy) void (^onSelectionBlock)(UIImage *);
@end