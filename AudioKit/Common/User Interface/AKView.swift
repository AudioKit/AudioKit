//
//  AKView.swift
//  AudioKit
//
//  Created by Stéphane Peter on 1/31/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#if os(OSX)
    public typealias AKView = NSView
    typealias AKColor = NSColor
#else
    public typealias AKView = UIView
    typealias AKColor = UIColor
#endif
