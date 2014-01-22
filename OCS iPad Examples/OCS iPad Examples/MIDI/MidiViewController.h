//
//  MidiViewController.h
//  AK iPad Examples
//
//  Created by Aurelius Prochazka on 8/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MidiViewController : UIViewController {
    __weak IBOutlet UILabel *channelLabel;
    __weak IBOutlet UILabel *noteLabel;
    __weak IBOutlet UISlider *modulationSlider;
    __weak IBOutlet UILabel  *modulationLabel;
    __weak IBOutlet UISlider *pitchBendSlider;
    __weak IBOutlet UILabel  *pitchBendLabel;
    __weak IBOutlet UILabel *controllerNumberLabel;
    __weak IBOutlet UILabel *controllerValueLabel;
    __weak IBOutlet UISlider *controllerSlider;

}
@end
