// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Accessing SWIFTPM_MODULE_BUNDLE from ObjC++ doesn't work for some reason.
/// See https://forums.swift.org/t/undefined-symbol-package-module-swiftpm-module-bundle/45773
@interface StkBundleHelper : NSObject

+ (NSBundle*) moduleBundle;

@end

NS_ASSUME_NONNULL_END
