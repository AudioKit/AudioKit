//
//  BalancedFlowLayout.h
//  BalancedFlowLayout
//
//  Created by Niels de Hoog on 31/10/13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * The BalancedFlowLayout class is designed to display items of different sizes and aspect ratios in a grid, without wasting any visual space. 
 * It takes the preferred sizes for the displayed items and a preferred row height as input to determine the optimal layout.
 *
 * In order to use this layout, the delegate for the collection view must implement the required methods in the BalancedFlowLayoutDelegate protocol.
 * Currently this class does not support supplementary or decoration views.
 *
 */
@interface NHBalancedFlowLayout : UICollectionViewLayout

// The preferred size for each row measured in the scroll direction
@property (nonatomic) CGFloat preferredRowSize;

// The size of each section's header. This maybe dynamically adjusted
// per section via the protocol method referenceSizeForHeaderInSection.
@property (nonatomic) CGSize headerReferenceSize;

// The size of each section's header. This maybe dynamically adjusted
// per section via the protocol method referenceSizeForFooterInSection.
@property (nonatomic) CGSize footerReferenceSize;

// The margins used to lay out content in a section.
@property (nonatomic) UIEdgeInsets sectionInset;

// The minimum spacing to use between lines of items in the grid.
@property (nonatomic) CGFloat minimumLineSpacing;

// The minimum spacing to use between items in the same row.
@property (nonatomic) CGFloat minimumInteritemSpacing;

// The scroll direction of the grid.
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;

@end


@protocol NHBalancedFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@required
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(NHBalancedFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end