//
//  UINib(StoryBoardSupport)
//  dyci
//
//  Created by Paul Taykalo on 5/27/13.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import "UINib+StoryBoardSupport.h"

#if TARGET_IPHONE_SIMULATOR


@implementation UINib (StoryBoardSupport)

static NSMutableDictionary * cachedOptions;

- (NSArray *)_swizzledInstantiateWithOwner:(id)owner options:(NSDictionary *)options {

    //
    if (!cachedOptions) {
        cachedOptions = [[NSMutableDictionary alloc] init];
    }

    // Saving options per owner (View Controller address)
    if ( owner && options) {
//        [cachedOptions setObject:options forKey:[NSString stringWithFormat:@"%0x", owner]];
    }

    NSArray *items = [self _swizzledInstantiateWithOwner:owner options:options];
    return items;
}


+ (NSDictionary *)optionsByOwner:(id)owner {
//    NSString * optionsKey = [NSString stringWithFormat:@"%0x", owner];
    NSString *optionsKey = @"";
    return cachedOptions[optionsKey];
}


@end

#endif