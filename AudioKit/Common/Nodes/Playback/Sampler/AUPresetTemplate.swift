//
//  AUPresetTemplate.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/7/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

class AUPresetTemplate{
    
    static internal func openInstrument()->String{
        var templateStr:String = ""
        templateStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        templateStr.appendContentsOf("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n")
        templateStr.appendContentsOf("<plist version=\"1.0\">\n")
        templateStr.appendContentsOf("    <dict>\n")
        templateStr.appendContentsOf("        <key>AU version</key>\n")
        templateStr.appendContentsOf("        <real>1</real>\n")
        templateStr.appendContentsOf("        <key>Instrument</key>\n")
        templateStr.appendContentsOf("        <dict>\n")
        return templateStr
    }
    static internal func openLayers()->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("            <key>Layers</key>\n")
        templateStr.appendContentsOf("            <array>\n")
        return templateStr
    }
    static internal func openLayer()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                <dict>\n")
        templateStr.appendContentsOf("                    <key>Amplifier</key>\n")
        templateStr.appendContentsOf("                    <dict>\n")
        templateStr.appendContentsOf("                        <key>ID</key>\n")
        templateStr.appendContentsOf("                        <integer>0</integer>\n")
        templateStr.appendContentsOf("                        <key>enabled</key>\n")
        templateStr.appendContentsOf("                        <true/>\n")
        templateStr.appendContentsOf("                    </dict>\n")
        return templateStr
    }
    static internal func openConnections()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    <key>Connections</key>\n")
        templateStr.appendContentsOf("                    <array>\n")
        return templateStr
    }
    static internal func generateConnectionDict(id:Int,
                                                source:Int,
                                                destination:Int,
                                                scale:Int,
                                                transform:Int = 1,
                                                invert:Bool = false)->String{
        var templateStr = ""
        templateStr.appendContentsOf("                        <dict>\n")
        templateStr.appendContentsOf("                            <key>ID</key>\n")
        templateStr.appendContentsOf("                            <integer>\(id)</integer>\n")
        templateStr.appendContentsOf("                            <key>control</key>\n")
        templateStr.appendContentsOf("                            <integer>0</integer>\n")
        templateStr.appendContentsOf("                            <key>destination</key>\n")
        templateStr.appendContentsOf("                            <integer>\(destination)</integer>\n")
        templateStr.appendContentsOf("                            <key>enabled</key>\n")
        templateStr.appendContentsOf("                            <true/>\n")
        templateStr.appendContentsOf("                            <key>inverse</key>\n")
        templateStr.appendContentsOf("                            <\((invert ? "true" : "false"))/>\n")
        templateStr.appendContentsOf("                            <key>scale</key>\n")
        templateStr.appendContentsOf("                            <real>\(scale)</real>\n")
        templateStr.appendContentsOf("                            <key>source</key>\n")
        templateStr.appendContentsOf("                            <integer>\(source)</integer>\n")
        templateStr.appendContentsOf("                            <key>transform</key>\n")
        templateStr.appendContentsOf("                            <integer>1</integer>\n")
        templateStr.appendContentsOf("                        </dict>\n")
        return templateStr
    }
    static internal func closeConnections()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                    </array>\n")
        return templateStr
    }
    static internal func generateAUPresetCloseLayer()->String{
        var templateStr = ""
        templateStr.appendContentsOf("                </dict>\n")
        return templateStr
    }
    static internal func generateAUPresetCloseLayers()->String{
        var templateStr:String = ""
        templateStr.appendContentsOf("            </array>\n")
        return templateStr
    }
}