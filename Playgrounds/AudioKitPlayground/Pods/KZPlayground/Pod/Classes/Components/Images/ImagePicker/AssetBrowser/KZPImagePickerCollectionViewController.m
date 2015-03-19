#import "KZPImagePickerCollectionViewController.h"
#import "NHBalancedFlowLayout.h"

@interface CUICommonAssetStorage : NSObject

- (NSArray *)allAssetKeys;

- (NSArray *)allRenditionNames;

- (id)initWithPath:(NSString *)p;

- (NSString *)versionString;

@end

@interface CUINamedImage : NSObject

- (CGImageRef)image;

@end

@interface CUIRenditionKey : NSObject
@end

@interface CUIThemeFacet : NSObject

+ (unsigned long long)themeWithContentsOfURL:(NSURL *)u error:(NSError **)e;

@end

@interface CUICatalog : NSObject

- (id)initWithName:(NSString *)n fromBundle:(NSBundle *)b;

- (id)allKeys;

- (NSArray *)allImageNames;

- (CUINamedImage *)imageWithName:(NSString *)n scaleFactor:(CGFloat)s;

- (CUINamedImage *)imageWithName:(NSString *)n scaleFactor:(CGFloat)s deviceIdiom:(int)idiom;

@end


@implementation KZPImagePickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setupViews];
  }

  return self;
}

- (void)prepareForReuse
{
  self.imageView.image = nil;
  self.titleLabel.text = nil;
}

- (void)setupViews
{
  UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  self.imageView = imageView;
  [self.contentView addSubview:self.imageView];

  UILabel *label = [UILabel new];
  label.textColor = UIColor.whiteColor;
  label.textAlignment = NSTextAlignmentCenter;
  self.titleLabel = label;
  [self.contentView addSubview:label];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  const NSUInteger labelHeight = 44;

  CGRect bounds = self.contentView.bounds;
  bounds.size.height -= labelHeight;
  self.imageView.frame = bounds;
  self.titleLabel.frame = CGRectMake(0, CGRectGetHeight(bounds), CGRectGetWidth(bounds), labelHeight);
}
@end

@interface KZPImagePickerCollectionViewController () <NHBalancedFlowLayoutDelegate>

@property(nonatomic, copy) NSArray *imageNames;
@property(nonatomic, copy) NSArray *images;
@end

@implementation KZPImagePickerCollectionViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.collectionView registerClass:KZPImagePickerCollectionViewCell.class forCellWithReuseIdentifier:@"ImageCell"];
  [self loadImages];
}

- (void)loadImages
{
  NSString *carPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Assets.car"];
  CUICatalog *catalog = [[NSClassFromString(@"CUICatalog") alloc] init];
  NSError *error = nil;
  Class facetClass = NSClassFromString(@"CUIThemeFacet");
  NSURL *url = [NSURL fileURLWithPath:carPath];
  unsigned long long facet = [facetClass themeWithContentsOfURL:url error:&error];
  /* Override CUICatalog to point to a file rather than a bundle */
  [catalog setValue:@(facet) forKey:@"_storageRef"];

  self.imageNames = [catalog allImageNames];
}

- (void)setImageNames:(NSArray *)imageNames
{
  NSMutableArray *images = [[NSMutableArray alloc] init];
  for (int i = 0; i < imageNames.count; i++) {
    [images addObject:[UIImage imageNamed:imageNames[i]]];
  }
  self.images = images;
  _imageNames = [imageNames copy];
  [self.collectionView reloadData];
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(NHBalancedFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  CGSize size = [self.images[(NSUInteger)indexPath.item] size];
  return size;
}

#pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
  return [self.images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
  KZPImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];

  NSUInteger index = (NSUInteger)indexPath.item;
  //! TODO: add image decompression to avoid the decompression lag on first draw
  cell.imageView.image = self.images[index];
  cell.titleLabel.text = self.imageNames[index];
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  if (self.onSelectionBlock) {
    self.onSelectionBlock(self.images[(NSUInteger)indexPath.item]);
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end