//
//  AKTuningTable+Brun.swift
//  AudioKit For iOS
//
//  Created by Marcus W. Hobbs on 5/2/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

extension AKTuningTable {
    
    static func brunLevel_0_1_1_0(level l:Int, generator g:Double) -> (Int, Int) {
        var zn = 0, zd = 0, infn = 1, infd = 0, fn = 0, fd = 0
        
        for _ in 0..<l {
            // zig zag pattern
            fn = zn + infn
            fd = zd + infd
            if g > Double(fn)/Double(fd) {
                zn = fn
                zd = fd
            }    else {
                infn = fn
                infd = fd
            }
        }
        return (numerator:fn, denominator:fd)
    }
    
    
    static func brunArrayLevel(level l:Int, generator g:Double) -> [(numerator:Int,denominator:Int)]
    {
        var mosA:Double = 1
        var mosB:Double = g
        var mosX1:Int = 1
        var mosX2:Int = 0
        var mosY1:Int = 0
        var mosY2:Int = 1
        var num:Int = 1
        var den:Int = 1
        var tmpf:Double = 0
        var tmpui:Int = 0
        var retVal = [(numerator:Int,denominator:Int)]()
        
        for _ in 0..<(l + 1) {
            retVal.append((num, den))
            num = 2 * mosY1 + mosY2;
            den = 2 * mosX1 + mosX2;
            mosA = mosA - mosB;
            mosX2 = mosX1 + mosX2;
            mosY2 = mosY1 + mosY2;
            if mosB > mosA {
                tmpf = mosA;   mosA = mosB;   mosB = tmpf;
                tmpui = mosX1; mosX1 = mosX2; mosX2 = tmpui;
                tmpui = mosY1; mosY1 = mosY2; mosY2 = tmpui;
            }
        }
        
        return retVal;
    }

/*
 - (instancetype)initWithGenerator:(CGFloat)g desiredNotesPerOctave:(NSUInteger)npo
    {
    const NSUInteger defaultLevel = 4;
    self = [self initWithMaxLevel:ABSOLUTE_MAX_BRUN_LEVEL level:defaultLevel generator:g murchana:0];
    if (self)
    {
    [self update];
    
    // LABEL ARRAY
    NSUInteger level = defaultLevel; // good default
    for (NSUInteger index = 0; index < _brunArray.count; index++)
    {
    Microtone* t = [_brunArray microtoneAtIndex:index];
    const NSInteger den = [t denominator];
    if (den > npo)
    {
    if (index > 2)
    level = index-1;
    
    break;
    }
    }
    self.level = level;
    [self update];
    }
    return self;
    }
*/
}
