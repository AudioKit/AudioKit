//
//  CSDWindowsTable.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDWindowsTable.h"

@implementation CSDWindowsTable
//normalized to one version
-(id) initWithTableSize:(int)tableSize 
             WindowType:(WindowTypes)window 
               MaxValue:(int)max
{
    return [self initWithTableSize:tableSize 
                        GenRoutine:(kGenRoutineWindows * -1) 
                        Parameters:[NSString stringWithFormat:@"%d %d", window, max]];
}

-(id) initWithTableSize:(int)tableSize WindowType:(WindowTypes)window
{
    return [self initWithTableSize:tableSize 
                        GenRoutine:kGenRoutineWindows
                        Parameters:[NSString stringWithFormat:@"%d", window]];
}

@end
