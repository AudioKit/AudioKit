//
//  AKRingModulator.m
//  AudioKit
//
//  Auto-generated on 4/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's ringmod:
//  http://www.csounds.com/manual/html/ringmod.html
//

#import "AKRingModulator.h"
#import "AKManager.h"

@implementation AKRingModulator
{
    AKParameter * _input;
    AKParameter * _carrier;
}

- (instancetype)initWithInput:(AKParameter *)input
                      carrier:(AKParameter *)carrier
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _carrier = carrier;
        [self setUpConnections];
}
    return self;
}

+ (instancetype)modulationWithInput:(AKParameter *)input
                           carrier:(AKParameter *)carrier
{
    return [[AKRingModulator alloc] initWithInput:input
                           carrier:carrier];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input, _carrier];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"ringmod("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ ringmod ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    if ([_input class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _input];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_carrier class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@", _carrier];
    } else {
        [inputsString appendFormat:@"AKAudio(%@)", _carrier];
    }
    return inputsString;
}

- (NSString *)udoString {
    return @"\n"
    "opcode ringmod,a,aa\n"
    "ain, acarrier xin\n"
    "itab chnget \"ringmod.table\"\n"
    "if(itab == 0) then\n"
    "itablen = 2^16\n"
    "itab ftgen 0, 0, itablen, -2, 0\n"
    "i_vb = 0.2\n"
    "i_vl = 0.4\n"
    "i_h = .1\n"
    "i_vl_vb_denom = ((2 * i_vl) - (2 * i_vb))\n"
    "i_vl_add =  i_h * ( ((i_vl - i_vb)^2) / i_vl_vb_denom)\n"
    "i_h_vl = i_h * i_vl\n"
    "indx = 0\n"
    "chnset itab, \"ringmod.table\"\n"
    "ihalf = itablen / 2\n"
    "until (indx >= itablen) do\n"
    "    iv = (indx - ihalf) / ihalf\n"
    "    iv = abs(iv)\n"
    "if(iv <= i_vb) then\n"
    "    tableiw 0, indx, itab, 0, 0, 2\n"
    "elseif(iv <= i_vl) then\n"
    "    ival = i_h * ( ((iv - i_vb)^2) / i_vl_vb_denom)\n"
    "    tableiw ival, indx, itab, 0, 0, 2\n"
    "else\n"
    "    ival = (i_h * iv) - i_h_vl + i_vl_add\n"
    "    tableiw ival, indx, itab, 0, 0, 2\n"
    "    endif\n"
    "    indx += 1\n"
    "    od\n"
    "endif\n"
    "ain1 = (ain * .5)\n"
    "acar2 = acarrier + ain1\n"
    "ain2 = acarrier - ain1\n"
    "asig1 table3 acar2, itab, 1, 0.5\n"
    "anegcar2 = acar2 * -1\n"
    "asig2 table3 anegcar2, itab, 1, 0.5\n"
    "asig3 table3 ain2, itab, 1, 0.5\n"
    "anegin2 = ain2 * -1\n"
    "asig4 table3 anegin2, itab, 1, 0.5\n"
    "asiginv = (asig3 + asig4) * -1\n"
    "aout sum asig1, asig2, asiginv\n"
    "xout aout\n"
    "endop\n";
}

@end
