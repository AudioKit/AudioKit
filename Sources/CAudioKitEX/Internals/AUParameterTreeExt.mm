// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AUParameterTreeExt.h"

@implementation AUParameter(Ext)

+(instancetype)parameterWithIdentifier:(NSString *)identifier
                                  name:(NSString *)name
                               address:(AUParameterAddress)address
                                   min:(AUValue)min
                                   max:(AUValue)max
                                  unit:(AudioUnitParameterUnit)unit
                                 flags:(AudioUnitParameterOptions)flags {
    return [AUParameterTree createParameterWithIdentifier:identifier
                                                     name:name
                                                  address:address
                                                      min:min
                                                      max:max
                                                     unit:unit
                                                 unitName:nil
                                                    flags:flags
                                             valueStrings:nil
                                      dependentParameters:nil];
}

+(instancetype)parameterWithIdentifier:(NSString *)identifier
                                  name:(NSString *)name
                               address:(AUParameterAddress)address
                                   min:(AUValue)min
                                   max:(AUValue)max
                                  unit:(AudioUnitParameterUnit)unit {
    return [AUParameterTree createParameterWithIdentifier:identifier
                                                     name:name
                                                  address:address
                                                      min:min
                                                      max:max
                                                     unit:unit
                                                 unitName:nil
                                                    flags:0
                                             valueStrings:nil
                                      dependentParameters:nil];
}
@end

@implementation AUParameterTree(Ext)

+(instancetype)treeWithChildren:(NSArray<AUParameter *> *)children {
    AUParameterTree *tree = [AUParameterTree createTreeWithChildren:children];
    if (tree == nil) {
        return nil;
    }

    tree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
      AUValue value = valuePtr == nil ? param.value : *valuePtr;
      return [NSString stringWithFormat:@"%.3f", value];

    };
    return tree;

}

@end
