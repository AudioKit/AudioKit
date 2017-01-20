//
//  AKView.swift
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#if os(OSX)
    public typealias AKView = NSView
    public typealias AKColor = NSColor
#else
    public typealias AKView = UIView
    public typealias AKColor = UIColor
#endif
