//
//  Constants.swift
//  MIDIFileEditAndSync
//
//  Created by Jeff Holtzkener on 2018/04/11.
//  Copyright © 2018 Jeff Holtzkener. All rights reserved.
//

import Foundation

struct Constants {

    static let pitchClassSpellings = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    enum Identifiers: String {
        case trackCell = "TrackCell"
        case toFilterSettings = "toFilterSettings"
        case filterSettingsVC = "filterSettingsVC"
        case filterCell = "FilterCell"
        case toFileLoadVC = "toFileLoadVC"
        case fileLoadVC = "fileLoadVC"
        case fileLoadCell = "fileLoadCell"
        case toMIDINoteDataVC = "toMIDINoteDataVC"
        case midiNoteDataCell = "MIDINoteDataCellTableViewCell"
        case toSequencerSettingsVC = "toSequencerSettingsVC"
    }

    static let localMIDIFiles = [
        "D_mixolydian_01",
        "D_mixolydian_02",
        "D_mixolydian_03",
        "D_mixolydian_04",
        "D_mixolydian_05",
        "D_Loop_01",
        "D_Loop_02",
        "D_Loop_03",
        "D_Loop_04",
        "D_Loop_05",
        "D_mixolydian_tripletFeel_01",
        "D_mixolydian_tripletFeel_02",
        "D_mixolydian_tripletFeel_03",
        "frere-jacques",
        "JPM072-Iyo-Bushi",
        "cellularAutomatonComp"
    ]
}
