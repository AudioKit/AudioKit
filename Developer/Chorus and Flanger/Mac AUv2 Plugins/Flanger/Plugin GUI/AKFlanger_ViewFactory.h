//
//  AKFlanger_ViewFactory.h
//  AKFlangerUI
//
//  Created by Shane Dunne, revision history on Githbub.
//

#import <Cocoa/Cocoa.h>
#import <AudioUnit/AUCocoaUIView.h>

@class AKFlanger_UIView;

@interface AKFlanger_ViewFactory : NSObject <AUCocoaUIBase>
{
    IBOutlet AKFlanger_UIView *uiFreshlyLoadedView;     // This class is the File's Owner of the CocoaView nib
                                                        // This data member needs to be the same class as the view
                                                        // will return
}

- (NSString *) description;    // string description of the view

@end
