//
//  LinearPartition.h
//  BalancedFlowLayout
//
//  Created by Niels de Hoog on 08-10-13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Partitions a sequence of non-negative integers into the required number of partitions.
 * Based on implementation in Python by Óscar López: http://stackoverflow.com/a/7942946
 * Example: [LinearPartition linearPartitionForSequence:@[9,2,6,3,8,5,8,1,7,3,4] numberOfPartitions:3] => @[@[9,2,6,3],@[8,5,8],@[1,7,3,4]]
 */
@interface NHLinearPartition : NSObject

+ (NSArray *)linearPartitionForSequence:(NSArray *)sequence numberOfPartitions:(NSInteger)numberOfPartitions;

@end
