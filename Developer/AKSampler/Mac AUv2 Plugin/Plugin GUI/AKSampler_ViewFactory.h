//
//  AKSampler_ViewFactory.h
//  AKSamplerUI
//
//  Created by Shane Dunne on 2018-03-02.
//

#import <Cocoa/Cocoa.h>
#import <AudioUnit/AUCocoaUIView.h>

@class AKSampler_UIView;

@interface AKSampler_ViewFactory : NSObject <AUCocoaUIBase>
{
    IBOutlet AKSampler_UIView *uiFreshlyLoadedView;     // This class is the File's Owner of the CocoaView nib
                                                        // This data member needs to be the same class as the view
                                                        // will return
}

- (NSString *) description;    // string description of the view

@end
