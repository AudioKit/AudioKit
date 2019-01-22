//
//  BPM+StatisticalTools.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/21/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

extension Double {
    func roundToDecimalPlaces(_ decimalPlaces: UInt8) -> Double {
        let multiplier = pow(10, Double(decimalPlaces))
        return (self * multiplier).rounded() / multiplier
//            Darwin.round(self * multiplier) / multiplier
    }
}

extension Array where Element: FloatingPoint {

    func sum() -> Element {
        return self.reduce(0, +)
    }

    func avg() -> Element {
        guard self.count > 0 else { return 0 }
        return self.sum() / Element(self.count)
    }

    func std() -> Element {
        guard self.count > 1 else { return 0 }
        let mean = self.avg()
        let v = self.reduce(0, { $0 + ($1-mean)*($1-mean) })
        return sqrt(v / (Element(self.count) - 1))
    }

    // I'd like to have variance
}

struct BpmHistoryStatistics {
    let historyCounts = [3,6,12,24,48,96,192,384]
    var bpmHistory: [[BpmType]] = [[], [], [], [], [], [], [], []]
    var stdDevs:    [BpmType] = []
    var means:      [BpmType] = []

    mutating func recordBpm(_ bpm: BpmType) {
        historyCounts.forEach { (count) in
            guard let index = historyCounts.firstIndex(of: count) else { return }

            while bpmHistory[index].count > (count - 1) {
                // remove oldest bpm from history
                bpmHistory[index].remove(at: 0)
            }
            bpmHistory[index].append(bpm)
        }

        // Peform Statistics
        var iterator = bpmHistory.makeIterator()
        var newMeans: [BpmType] = []
        var newStdDevs: [BpmType] = []
        while let bpms = iterator.next() {
            let mean = bpms.avg()
            let stdDev = bpms.std()
            newMeans.append(mean)
            newStdDevs.append(stdDev)
        }
        means = newMeans
        stdDevs = newStdDevs
    }

    /// This methods attempts to return the most accurate BPM
    /// by searching through its most recent BPM history sets for
    /// the sequence with the least deviation from that sets mean.
    ///
    /// - Returns: A tuple with Average BPM, Standard Deviation, index of the BTM history set it used, and the count of recent BPMs used to obtain the average
    func avgFromSmallestDeviatingHistory() -> (avg: BpmType, std: BpmType, index: Int, count: Int, accuracy: Double) {
        let std = stdDevs.min() ?? 0
        guard let index = stdDevs.index(of: std) else {
            return (0, 0, 0, 0, 0)
        }
        let meanAtIndex = means[index]
        let accuracy = Double(index+1) / Double(historyCounts.count)
        return (meanAtIndex, std, index, historyCounts[index], accuracy)
    }
}

struct BpmHistoryAveraging {
    var bpmHistory: [BpmType]
    var countLimit: Int
    var results: (avg: BpmType, std: BpmType)

    init(countLimit limit: Int) {
        countLimit = limit
        bpmHistory = []
        results = (0,0)
    }

    mutating func record(_ bpm: BpmType) {
        while bpmHistory.count > countLimit {
            bpmHistory.remove(at: 0)
        }
        bpmHistory.append(bpm)
        calculate()
    }

    var bpmStable: Bool {
        guard bpmHistory.count > 1 else { return true }

        let stable = bpmHistory[bpmHistory.count - 1] == bpmHistory[bpmHistory.count - 2]
        return stable
    }

    mutating private func calculate() {
        guard bpmHistory.count > 1 else { results = (bpmHistory[0], 0); return }
        results = (bpmHistory.avg(), bpmHistory.std())
    }
}

struct ValueSmoothing {
    var smoothed : Float64
    let factor : Float64
    let priorDataFactor : Float64

    init(factor fact: Float64) {
        factor = fact
        priorDataFactor = Float64(1.0) - factor
        smoothed = 0
    }

    mutating func smoothed(_ newValue: Float64) -> Float64 {
        if smoothed == 0 {
            smoothed = newValue
        } else {
            smoothed = (newValue * factor) + (smoothed * priorDataFactor)
        }
        return smoothed
    }
}



