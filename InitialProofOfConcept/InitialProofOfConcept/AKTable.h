//
//  AKTable.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter.h"
#import "AKManager.h"

@interface AKTable : AKParameter

@property (nonatomic) sp_ftbl *table;

@end
