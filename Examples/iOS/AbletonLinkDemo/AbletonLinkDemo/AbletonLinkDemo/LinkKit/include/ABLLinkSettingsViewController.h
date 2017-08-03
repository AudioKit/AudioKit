/*! @file ABLSettingsViewController.h
    @copyright 2016, Ableton AG, Berlin. All rights reserved.
*/

#pragma once

#import <UIKit/UIKit.h>
#import "ABLLink.h"

/*! @brief Link settings view controller
    @discussion Settings view controller that provides users with the
    ability to view Link status and modify Link-related
    settings. Clients can integrate this view controller into their
    GUI as they see fit, but it is recommended that it be presented as
    a popover.
*/
@interface ABLLinkSettingsViewController : UIViewController

/*! @discussion Class method that provides an instance of the view
    controller given an ABLLink instance. Clients must ensure that the
    ABLLink instance is not destroyed before the view controller.
*/
+ (id)instance:(ABLLinkRef)ablLink;

@end
