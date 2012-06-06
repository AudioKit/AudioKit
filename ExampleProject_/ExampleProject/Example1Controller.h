// Example1Controller.h

#import <UIKit/UIKit.h>
#import "CSDManager.h"

@interface Example1Controller : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;


- (IBAction)touchButton:(id)sender;

@end
