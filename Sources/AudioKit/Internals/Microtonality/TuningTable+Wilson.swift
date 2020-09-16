// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension TuningTable {
    /// From Erv Wilson.  See http://anaphoria.com/genus.pdf
    public func presetHighlandBagPipes() -> Int {
        let npo = tuningTable(fromFrequencies: [32, 36, 39, 171, 48, 52, 57])
        return npo
    }

    /// From Erv Wilson.  See http://anaphoria.com/genus.pdf
    public func presetDiaphonicTetrachord() -> Int {
        let npo = tuningTable(fromFrequencies: [1, 27 / 26.0, 9 / 8.0, 4 / 3.0, 18 / 13.0, 3 / 2.0, 27 / 16.0])
        return npo
    }
}
