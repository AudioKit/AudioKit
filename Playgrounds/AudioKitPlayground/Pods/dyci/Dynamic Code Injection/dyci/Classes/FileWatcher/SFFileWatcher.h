//
//  SFFileWatcher.h
//  Dynamic Code Injection
//
//  Created by adenisov on 16.10.12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFFileWatcherDelegate.h"

#if TARGET_IPHONE_SIMULATOR

/*
 File watcher object.
 Watching for changes on the specified path
 */
@interface SFFileWatcher : NSObject

/*
 Path on which current watcher is watching
 */
@property(nonatomic, readonly) NSString * watchingPath;

/*
 Delegate that will be notified each time, as something changed
 */
@property(nonatomic, assign) id<SFFileWatcherDelegate> delegate;

/*
 Designated initializer
 Starts watching on specified path and with specified delegate
 */
- (id)initWithFilePath:(NSString *)watchingFilePath delegate:(id<SFFileWatcherDelegate>)delegate;
+ (id)fileWatcherWithPath:(NSString *)watchingFilePath delegate:(id<SFFileWatcherDelegate>)delegate;


@end

#endif