//
//  OCSWindowsTable.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFunctionTable.h"

typedef enum
{
    kWindowHamming=1,
    kWindowHanning=2,
    kWindowBartlettTriangle=3,
    kWindowBlackmanThreeTerm=4,
    kWindowBlackmanHarrisFourTerm=5,
    kWindowGaussian=6,
    kWindowKaiser=7,
    KWindowRectangle=8,
    kWindowSync=9
} WindowType;

@interface OCSWindowsTable : OCSFunctionTable
-(id) initWithSize:(int)tableSize 
        WindowType:(WindowType)window 
          MaxValue:(int)max;
-(id) initWithSize:(int)size 
        WindowType:(WindowType)window;

@end
