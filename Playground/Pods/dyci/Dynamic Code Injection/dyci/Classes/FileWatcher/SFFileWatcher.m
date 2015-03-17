//
//  SFFileWatcher.m
//  Dynamic Code Injection
//
//  Created by adenisov on 16.10.12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import "SFFileWatcher.h"

#if TARGET_IPHONE_SIMULATOR

@implementation SFFileWatcher {

   /*
   Date on what last changes was loaded
    */
   NSDate *_lastLoadDate;

   /*
   Dispatching queue in which file watching operations will be performed
    */
   dispatch_queue_t _queue;

   /*
    Dispatch source of file changes notifications
    */
   dispatch_source_t _source;
}


+ (id)fileWatcherWithPath:(NSString *)watchDirectory delegate:(id<SFFileWatcherDelegate>)delegate {
   return [[SFFileWatcher alloc] initWithFilePath:watchDirectory delegate:delegate];
}


- (id)initWithFilePath:(NSString *)watchingFilePath delegate:(id<SFFileWatcherDelegate>)delegate {
   self = [super init];
   if (self) {
      _watchingPath = watchingFilePath;
      _delegate = delegate;
      _lastLoadDate = [NSDate date];

      [self setupHandlerOnFileChange:_watchingPath];

   }

   return self;

}


- (void)setupHandlerOnFileChange:(NSString *)filePath {

   // Resolving file descriptor
   uintptr_t fd = (uintptr_t) open([filePath cStringUsingEncoding:NSUTF8StringEncoding], O_EVTONLY);

   // Setting up queued and source of dispatch events
   _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,
                                    (uintptr_t) fd,
                                    DISPATCH_VNODE_WRITE,
                                    _queue);

   __block id weakSelf = self;
   dispatch_source_set_event_handler(_source, ^{
      dispatch_async(dispatch_get_main_queue(), ^{
         [weakSelf checkForFileCreationDate];
      });
   });

   dispatch_source_set_cancel_handler(_source, ^{
      close(fd);
   });

   dispatch_resume(_source);
}


- (void)checkForFileCreationDate {
   NSFileManager * fm = [NSFileManager defaultManager];

   NSArray * files = [fm contentsOfDirectoryAtPath:_watchingPath error:nil];

   // Using the most recent file, but date should be >> _lastLoadData

   for (NSString * file in files) {
      NSString * filePath = [_watchingPath stringByAppendingPathComponent:file];
      NSDictionary * fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
      NSDate * fileCreationDate = [fileAttributes fileCreationDate];

      // If new file has bigger creation date, then, let's notify our delegate about it
      NSTimeInterval diff = [_lastLoadDate timeIntervalSinceDate:fileCreationDate];
      if (diff < 0) {
         [self.delegate newFileWasFoundAtPath:filePath];
         _lastLoadDate = fileCreationDate;
      }
   }
}


@end

#endif