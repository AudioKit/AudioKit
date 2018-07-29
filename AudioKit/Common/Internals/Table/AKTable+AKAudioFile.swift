//
//  AKTable+AKAudioFile.swift
//  MOS10
//
//  Created by Marcus W. Hobbs on 4/8/17.
//
//

import Foundation

public extension AKTable {
    
    // intended for oscillator waveforms, not for huge samples
    public static func fromAudioFile(_ url:URL) -> AKTable? {
        var retVal:AKTable? = nil
        do {
            let sample = try AKAudioFile(forReading: url)
            if let d = sample.floatChannelData?[0] {
                retVal = AKTable(count:AKTable.IndexDistance(sample.samplesCount))
                for i in 0..<sample.samplesCount {
                    let f = d[Int(i)]
                    retVal?[Int(i)] = f
                }
                //AKLog("sample name: \(url), count: \(sample.samplesCount)")
            }
        }
        catch {
            AKLog("\(error)")
            return nil
        }
        
        return retVal
    }
}
