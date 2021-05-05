// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "StkBundleHelper.h"

@implementation StkBundleHelper

+ (NSBundle*) moduleBundle {

    // XXX: We would like to just use SWIFTPM_MODULE_BUNDLE but it breaks CI.
    //      Instead copy the code from the SPM-generated resource_bundle_accessor.m

    NSString *bundleName = @"AudioKit_Stk";

    NSArray<NSURL*> *candidates = @[
        NSBundle.mainBundle.resourceURL,
        [NSBundle bundleForClass:[StkBundleHelper class]].resourceURL,
        NSBundle.mainBundle.bundleURL
    ];

    for (NSURL* candiate in candidates) {
        NSURL *bundlePath = [candiate URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle", bundleName]];

        NSBundle *bundle = [NSBundle bundleWithURL:bundlePath];
        if (bundle != nil) {
            return bundle;
        }
    }

    @throw [[NSException alloc] initWithName:@"SwiftPMResourcesAccessor" reason:[NSString stringWithFormat:@"unable to find bundle named %@", bundleName] userInfo:nil];

}

@end
