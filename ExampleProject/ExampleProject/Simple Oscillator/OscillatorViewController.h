//
//  OscillatorViewController.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SoundGenerator.h"

@interface OscillatorViewController : UIViewController {
    SoundGenerator *mySoundGenerator;
}
- (IBAction)hit1:(id)sender;
- (IBAction)hit2:(id)sender;

@end
