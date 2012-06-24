//
//  UDOViewController.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDOInstrument.h"

@interface UDOViewController : UIViewController {
    UDOInstrument * udoInstrument;
}
- (IBAction)hit1:(id)sender;
- (IBAction)hit2:(id)sender;


@end
