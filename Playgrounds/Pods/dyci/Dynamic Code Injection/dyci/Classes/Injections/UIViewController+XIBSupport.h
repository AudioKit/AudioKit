//
//  UIViewController+XIBSupport.h
//  Dynamic Code Ibjection
//
//  Created by Paul Taykalo on 11/30/12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import <UIKit/UIKit.h>


#if TARGET_IPHONE_SIMULATOR

/*
 This category allows Xibs to be injected in runtime
 */
@interface UIViewController (XIBSupport)

/*
 Overriden updateOnResource Injection
 this method will check, if injected path is same as our xib,
 And will reinitialize xib with new nib instance
 
 This functionality is experimental. So, in case if it isn't working, 
 describe the steps, and setup and issue on the Github
 https://github.com/DyCI/dyci-main/issues?sort=updated&state=open
 */
- (void)updateOnResourceInjection:(NSString *)path;

@end

#endif
