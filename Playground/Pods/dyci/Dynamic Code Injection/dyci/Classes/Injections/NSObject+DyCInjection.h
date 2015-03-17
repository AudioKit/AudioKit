//
//  NSObject+DyCInjection(DCInjection)
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/21/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR

/*
 Methods that will be called on object, that are waiting for injection
 */
@interface NSObject (DyCInjection)


+ (void)allowInjectionSubscriptionOnInitMethod;

/*
  This method will be called in order to determine,
  do we need to subscribe to Injection notifications, or not

  By default all objects that have prefixes:
    _
    NS
    CF
    Web
    UI
    DOM
    SFInj
    OS_

  are skipped

  This behaviour can be changed in next releases
 */
+ (BOOL)shouldPerformRuntimeCodeInjectionOnObject:(id)instance;



/*
  Will be called, when some class (X) will be injected in application runtime
  On All instances of class X, and instances of subclasses of X, this method will be called
*/
- (void)updateOnClassInjection;

/*
  This method will be called for all classes, that are waiting for resources changes.
  Before this method is called, Image cache is flushed, so you don't have to call memory warnings
  Resource that was injected is passed with parameter. But in general, you don't need to care

*/
- (void)updateOnResourceInjection:(NSString *)resourcePath;


@end

#endif