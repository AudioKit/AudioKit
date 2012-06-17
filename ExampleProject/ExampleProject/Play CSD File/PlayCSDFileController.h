// PlayCSDFileController.h

#import <UIKit/UIKit.h>
#import "CSDManager.h"

@interface PlayCSDFileController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;


- (IBAction)touchButton:(id)sender;

@end
