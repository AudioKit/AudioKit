//
//  UINib(StoryBoardSupport)
//  dyci
//
//  Created by Paul Taykalo on 5/27/13.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#if TARGET_IPHONE_SIMULATOR

/*
 It seems that storyboard passing some options, when instantiating the nibs
 So, we would save those, and reuse after injections
 */
@interface UINib (StoryBoardSupport)


/*
Returns options, saved for the owner
 */
+ (NSDictionary *)optionsByOwner:(id)owner;

@end

#endif