//
//  NSSet+ClassesList(Classes)
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/21/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import <objc/runtime.h>
#import "NSSet+ClassesList.h"


#if TARGET_IPHONE_SIMULATOR

@implementation NSSet (ClassesList)

+ (NSMutableSet *)currentClassesSet {
   NSMutableSet * classesSet = [NSMutableSet set];

   int classesCount = objc_getClassList(NULL, 0);
   Class * classes = NULL;
   if (classesCount > 0) {
      classes = (Class *) malloc(sizeof(Class) * classesCount);
      classesCount = objc_getClassList(classes, classesCount);
      for (int i = 0; i < classesCount; ++i) {
         NSValue * wrappedClass = [NSValue value:&classes[i] withObjCType:@encode(Class)];
         [classesSet addObject:wrappedClass];
      }
      free(classes);
   }
   return classesSet;
}

@end

#endif