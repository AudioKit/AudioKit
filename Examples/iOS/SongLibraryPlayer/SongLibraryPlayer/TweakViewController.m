//
//  TweakViewController.m
//  SongLibraryPlayer
//
//  Created by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "TweakViewController.h"
#import "SharedStore.h"

@interface TweakViewController ()

@end

@implementation TweakViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)changeReverbAmount:(id)sender {
    SharedStore *global = [SharedStore globals];
    global.audioFilePlayer.reverbAmount.value = [(UISlider *)sender value];
}
- (IBAction)changeMix:(id)sender {
    SharedStore *global = [SharedStore globals];
    global.audioFilePlayer.mix.value = [(UISlider *)sender value];
}

@end
