//
//  AKSequencer+AbletonLink.swift
//  AbletonLinkDemo
//
//  Created by Joshua Thompson on 7/15/17.
//  Copyright © 2017 Joshua Thompson. All rights reserved.
//

import AudioKit

extension AKSequencer {
    
    //TODO: Provide access to audioengine
    convenience init(en_ablink: Bool = false){
        self.init()
        if(en_ablink){
            /*TODO:
             setup ABLink using AbletonLinkWrapper.swift
            */
        }
    }
}

