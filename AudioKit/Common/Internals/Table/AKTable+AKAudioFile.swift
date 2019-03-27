//
//  AKTable+AKAudioFile.swift
//
//  Created by Marcus W. Hobbs on 4/8/17.
//

import Foundation

public extension AKTable {

    /// Create an AKTable with the contents of a pcmFormatFloat32 file.
    /// This method is intended for wavetables (i.e., 2048 or 4096 samples), not large audio files.
    /// Parameters:
    ///   - url: URL to the file
    static func fromAudioFile(_ url: URL) -> AKTable? {
        var retVal: AKTable?
        do {
            let sample = try AKAudioFile(forReading: url)
            if let d = sample.floatChannelData?[0] {
                retVal = AKTable(count: AKTable.IndexDistance(sample.samplesCount))
                for i in 0..<sample.samplesCount {
                    let f = d[Int(i)]
                    retVal?[Int(i)] = f
                }
                //AKLog("sample name: \(url), count: \(sample.samplesCount)")
            }
        } catch {
            AKLog("\(error)")
            return nil
        }

        return retVal
    }

    /// Will write to CAF in temporary directory
    /// Parameters:
    ///   - fileName: String name of file
    func writeToAudioFile(_ fileName: String) throws {
        do {
            // We initialize AKAudioFile for writing (and check that we can write to)
            _ = try AKAudioFile(createFileFromFloats: [content], baseDir: .temp, name: fileName)
        } catch let error as NSError {
            AKLog("cannot write to \(fileName)")
            throw error
        }
    }
}
