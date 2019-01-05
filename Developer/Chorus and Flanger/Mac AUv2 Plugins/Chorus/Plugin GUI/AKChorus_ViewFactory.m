//
//  AKChorus_ViewFactory.m
//  AKChorusUI
//
//  Created by Shane Dunne, revision history on Githbub.
//

#import "AKChorus_ViewFactory.h"

@implementation AKChorus_ViewFactory

// version 0
- (unsigned) interfaceVersion {
    return 0;
}

// string description of the Cocoa UI
- (NSString *) description {
    return @"AudioKit: AKChorus";
}

// N.B.: this class is simply a view-factory,
// returning a new autoreleased view each time it's called.
- (NSView *)uiViewForAudioUnit:(AudioUnit)inAU withSize:(NSSize)inPreferredSize {
    if (! [NSBundle loadNibNamed: @"AKChorus_UIView" owner:self]) {
        NSLog (@"Unable to load nib for view.");
        return nil;
    }

    // This particular nib has a fixed size, so we don't do anything with the inPreferredSize argument.
    // It's up to the host application to handle.
    [uiFreshlyLoadedView setAU:inAU];

    NSView *returnView = (NSView*)uiFreshlyLoadedView;
    uiFreshlyLoadedView = nil;    // zero out pointer.  This is a view factory.  Once a view's been created
    // and handed off, the factory keeps no record of it.

    return [returnView autorelease];
}

@end
