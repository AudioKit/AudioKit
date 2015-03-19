//
//  SFFileWatcherDelegate.h
//  Dynamic Code Injection
//
//  Created by adenisov on 16.10.12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import <Foundation/Foundation.h>


#if TARGET_IPHONE_SIMULATOR

/*
 Object that get notified by SFFileWatcher, when some files are changed in the
 some directory
 */
@protocol SFFileWatcherDelegate<NSObject>

@optional

/*
 This method will be called each time, when something changes in watching directory
 */
- (void)newFileWasFoundAtPath:(NSString *)filePath;

@end

#endif
