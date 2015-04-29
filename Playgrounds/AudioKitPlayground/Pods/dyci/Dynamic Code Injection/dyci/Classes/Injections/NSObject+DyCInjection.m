//
//  NSObject+DyCInjection(DCInjection)
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/21/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//

#if TARGET_IPHONE_SIMULATOR

#import <objc/runtime.h>
#import "NSObject+DyCInjection.h"
//#import "SFDynamicCodeInjection.h"
#import "SFInjectionsNotificationsCenter.h"


void swizzle(Class c, SEL orig, SEL new) {
   Method origMethod = class_getInstanceMethod(c, orig);
   Method newMethod = class_getInstanceMethod(c, new);
   if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
      class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
   } else {
      method_exchangeImplementations(origMethod, newMethod);
   }
}


@interface NSObject (DyCInjectionObserver) <SFInjectionObserver>

@end


@implementation NSObject (DyCInjection)

#pragma mark - Swizzling

+ (void)allowInjectionSubscriptionOnInitMethod {
   swizzle([NSObject class], @selector(init), @selector(_swizzledInit));
   swizzle([NSObject class], NSSelectorFromString(@"dealloc"), @selector(_swizzledDealloc));
    
   // Storyboard support
//   swizzle(NSClassFromString(@"UINib"), @selector(instantiateWithOwner:options:), @selector(_swizzledInstantiateWithOwner:options:));
}


#pragma mark - Subscription check

+ (BOOL)shouldPerformRuntimeCodeInjectionOnObject:(__unsafe_unretained id)instance {
   if (!instance) {
      return NO;
   }

//#warning We should skip more than just NS, CF, and private classes
   char const * className = object_getClassName(instance);
   
   switch (className[0]) {
      case '_':
         return NO;
      case 'N':
         if (className[1] == 'S') {
            return NO;
         }
         break;
      case 'C':
         if (className[1] == 'A' ||
             className[1] == 'F' ) {
            return NO;
         }
         break;
      case 'U':
         if (className[1] == 'I') {
            // Allowing to inject UIViewControllers
             if (strcmp(className, "UIViewController") == 0) {
                 return YES;
             }
             if (strcmp(className, "UITableViewController") == 0) {
                 return YES;
             }
            return NO;
         }
         break;
      case 'W':
         if (className[1] == 'e' && className[2] == 'b') {
            return NO;
         }
         break;
      case 'D':
         if (className[1] == 'O' && className[2] == 'M') {
            return NO;
         }
         break;
      case 'S':
         if (className[1] == 'F' && className[2] == 'I' && className[3] == 'n' && className[4] == 'j') {
            return NO;
         }
         break;
       case 'O':
         if (className[1] == 'S' && className[2] == '_') {
            return NO;
         }
         break;

      default:
         break;
   }

   // Disable injection on NSManagedObject object classes
   // They have slightly different lifecycle...
   Class clz = NSClassFromString(@"NSManagedObject");
   if (clz && [instance isKindOfClass:clz]) {
      return NO;
   }

   return YES;
}

#pragma mark - On Injection methods

- (void)updateOnClassInjection {

}


- (void)updateOnResourceInjection:(NSString *)resourcePath {

}


#pragma  mark - Swizzled methods

- (id)_swizzledInit {
    
   // Calling previous init

   id result = self;
   result = [result _swizzledInit];

   if (result) {

       // In case, if we are in need to inject
      if ([NSObject shouldPerformRuntimeCodeInjectionOnObject:result]) {
          SFInjectionsNotificationsCenter * notificationCenter = [SFInjectionsNotificationsCenter sharedInstance];
          [notificationCenter addObserver:result];
      }

   }
   return result;
}

- (void)_swizzledDealloc {

   if ([NSObject shouldPerformRuntimeCodeInjectionOnObject:self]) {
      [[SFInjectionsNotificationsCenter sharedInstance] removeObserver:self];
   }

   // Swizzled methods are fun
   // Calling previous dealloc implementation
   [self _swizzledDealloc];

}

@end

#endif
