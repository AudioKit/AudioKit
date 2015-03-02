//
//  AKTable.m
//  OscillatorPlayground
//
//  Created by Aurelius Prochazka on 3/1/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTable.h"
#import "AKManager.h"

@implementation AKTable {
    MYFLT *table;
    CsoundObj *csoundObj;
    CSOUND *cs;
}

static int currentID = 1000;
+ (void)resetID { currentID = 1000; }

- (instancetype)initWithSize:(int)tableSize
{
    self = [super init];
    if (self) {
        _number = currentID++;
        _size = tableSize;
        table = malloc(_size *sizeof(MYFLT));
        csoundObj = [[AKManager sharedManager] engine];
        cs = [csoundObj getCsound];
        NSLog(@"ftable %@", [self orchestraString]);
        [csoundObj updateOrchestra:[self orchestraString]];
    }
    return self;
}

- (instancetype)init {
    return [self initWithSize:4096];
}

+ (instancetype)table {
    return [[AKTable alloc] init];
}

- (void)populateTableWithIndexFunction:(float (^)(int))function
{
    while (csoundTableLength(cs, _number) != _size) {
        // do nothing
    }
    csoundGetTable(cs, &table, _number);
    for (int i = 0; i < _size; i++) {
        table[i] = function(i);
    }
}

- (void)populateTableWithFractionalWidthFunction:(float (^)(float))function
{
    while (csoundTableLength(cs, _number) != _size) {
        // do nothing
    }
    csoundGetTable(cs, &table, _number);
    for (int i = 0; i < _size; i++) {
        float x = (float) i / _size;
        table[i] = function(x);
    }
}

- (NSString *)orchestraString
{
    return [NSString stringWithFormat:@"giTable ftgen %d, 0, %d, 9, 0, 0", _number, _size];
}

@end
