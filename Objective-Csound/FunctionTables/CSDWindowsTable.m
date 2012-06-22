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
-(id) initWithSize:(int)tableSize 
        WindowType:(WindowTypes)window 
          MaxValue:(int)max
{
    return [self initWithSize:tableSize 
                   GenRoutine:(kGenRoutineWindows * -1) 
                   Parameters:[NSString stringWithFormat:@"%d %d", window, max]];
}

-(id) initWithSize:(int)tableSize WindowType:(WindowTypes)window
{
    return [self initWithSize:tableSize 
                   GenRoutine:kGenRoutineWindows
                   Parameters:[NSString stringWithFormat:@"%d", window]];
}

@end
