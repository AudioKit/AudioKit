//
//  SimpleGrainInstrument.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSSoundFileTable.h"
#import "OCSWindowsTable.h"
#import "OCSExpSegment.h"
#import "OCSLine.h"
#import "OCSFileLength.h"
#import "OCSProperty.h"
#import "OCSGrain.h"
#import "OCSOutputStereo.h"

@interface SimpleGrainInstrument : OCSInstrument
{
}

-(id)initWithOrchestra:(OCSOrchestra *)newOrchestra;

@end
