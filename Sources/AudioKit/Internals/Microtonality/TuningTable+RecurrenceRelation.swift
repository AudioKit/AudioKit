// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension TuningTable {
    /// From Erv Wilson.  See http://anaphoria.com/genus.pdf
    @discardableResult public func presetRecurrenceRelation01() -> Int {
        return tuningTable(fromFrequencies: [1, 34, 5, 21, 3, 13, 55])
    }
}
