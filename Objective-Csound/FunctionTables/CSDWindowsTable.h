//
//  CSDWindowsTable.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDFunctionTable.h"
#import "CSDConstants.h"

@interface CSDWindowsTable : CSDFunctionTable
-(id) initWithSize:(int)tableSize 
        WindowType:(WindowTypes)window 
          MaxValue:(int)max;
-(id) initWithSize:(int)size 
        WindowType:(WindowTypes)window;

@end
