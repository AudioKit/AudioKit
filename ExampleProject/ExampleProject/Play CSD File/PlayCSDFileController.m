#import "PlayCSDFileController.h"

@implementation PlayCSDFileController

- (IBAction)touchButton:(id)sender {
    UIButton * button = sender;
    if ([[CSDManager sharedCSDManager] isRunning]) {
        [[CSDManager sharedCSDManager] stop];
        [button setTitle: @"Run" forState: UIControlStateNormal];
    } else {
        [[CSDManager sharedCSDManager] runCSDFile:@"example"];
        [button setTitle: @"Stop" forState: UIControlStateNormal];
    }
}

@end
