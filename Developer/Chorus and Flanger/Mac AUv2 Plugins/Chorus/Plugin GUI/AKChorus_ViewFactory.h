//
//  AKChorus_ViewFactory.h
//  AKChorusUI
//
//  Created by Shane Dunne, revision history on Githbub.
//

#import <Cocoa/Cocoa.h>
#import <AudioUnit/AUCocoaUIView.h>

@class AKChorus_UIView;

@interface AKChorus_ViewFactory : NSObject <AUCocoaUIBase>
{
    IBOutlet AKChorus_UIView *uiFreshlyLoadedView;     // This class is the File's Owner of the CocoaView nib
                                                        // This data member needs to be the same class as the view
                                                        // will return
}

- (NSString *) description;    // string description of the view

@end
