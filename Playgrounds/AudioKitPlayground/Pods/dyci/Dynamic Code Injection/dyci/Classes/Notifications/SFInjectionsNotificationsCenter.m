//
//  SFInjectionsNotificationsCenter.m
//  dyci-framework
//
//  Created by Paul Taykalo on 6/1/13.
//  Copyright (c) 2013 Stanfy. All rights reserved.
//

#import "SFInjectionsNotificationsCenter.h"

#if TARGET_IPHONE_SIMULATOR

@implementation SFInjectionsNotificationsCenter {
    NSMutableDictionary * _observers;
}


+ (instancetype)sharedInstance {
    static SFInjectionsNotificationsCenter * _instance = nil;
    if (!_instance) {
        _instance = [[self alloc] init];
        _instance->_observers = [NSMutableDictionary dictionary];
    }
    return _instance;
}


- (void)addObserver:(id<SFInjectionObserver>)observer {
    [self addObserver:observer forClass:[observer class]];
}


- (void)removeObserver:(id<SFInjectionObserver>)observer {
    [self removeObserver:observer ofClass:[observer class]];
}


- (void)removeObserver:(id<SFInjectionObserver>)observer ofClass:(Class)class {
    @synchronized (_observers) {
        NSMutableSet * observersPerClass = [_observers objectForKey:class];
        if (observersPerClass) {
            @synchronized (observersPerClass) {
                [observersPerClass removeObject:observer];
            }
        }
    }
}


- (void)addObserver:(id<SFInjectionObserver>)observer forClass:(Class)class {
    if (!class) {
        return;
    }
    @synchronized (_observers) {
        NSMutableSet * observersPerClass = [_observers objectForKey:class];
        if (!observersPerClass) {
            observersPerClass = (__bridge_transfer NSMutableSet *) CFSetCreateMutable(nil, 0, nil);
            [_observers setObject:observersPerClass forKey:(id <NSCopying>)class];
        }
        @synchronized (observersPerClass) {
            [observersPerClass addObject:observer];
        }
    }
}


/*
This will notify about class injection
 */
- (void)notifyOnClassInjection:(Class)injectedClass {
    int idx = 0;
    @synchronized (_observers) {
        for (NSMutableSet * observersPerClass in [_observers allValues]) {
            @synchronized (observersPerClass) {
                id anyObject = [observersPerClass anyObject];
                int localIdx = 0;
                if ([anyObject isKindOfClass:injectedClass]) {
                    for (id<SFInjectionObserver> observer in observersPerClass) {
                        [observer updateOnClassInjection];
                        idx++;
                        localIdx++;
                    }
                    NSLog(@"%d (%@) class instanses were notified on Class Injection : ", localIdx, NSStringFromClass([anyObject class]));
                }
            }
        }
    }

    NSLog(@"%d instanses were notified on Class Injection by injecting class: (%@)", idx, NSStringFromClass(injectedClass));
}


/*
This will notiy all registered classes about that some resource was injected
 */
- (void)notifyOnResourceInjection:(NSString *)resourceInjection {
    int idx = 0;
    @synchronized (_observers) {
        for (NSMutableSet * observersPerClass in [_observers allValues]) {
            @synchronized (observersPerClass) {
                for (id<SFInjectionObserver> observer in observersPerClass) {
                    [observer updateOnResourceInjection:resourceInjection];
                    idx++;
                }
            }
        }
    }
    NSLog(@"%d classes instanses were notified on REsource Injection", idx);
}


@end


#endif