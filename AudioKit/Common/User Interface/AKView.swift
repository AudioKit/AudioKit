//
//  AKView.swift
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#if os(OSX)
    public typealias AKView = NSView
    typealias AKColor = NSColor
#else
    public typealias AKView = UIView
    typealias AKColor = UIColor
#endif
