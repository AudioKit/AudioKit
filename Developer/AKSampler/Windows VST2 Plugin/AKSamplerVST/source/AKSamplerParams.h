#pragma once

enum
{
    // ramped parameters
    kMasterVolume, kPitchBend, kVibratoDepth,
    kFilterCutoff, kKeyTracking, kFilterEgStrength, kFilterResonance,
    kGlideRate,

    // simple parameters
    kAmpAttackTime, kAmpDecayTime, kAmpSustainLevel, kAmpReleaseTime,
    kFilterAttackTime, kFilterDecayTime, kFilterSustainLevel, kFilterReleaseTime,
    kFilterEnable, kLoopThruRelease, kMonophonic, kLegato,

    kNumParams
};

// This path is appended to the full path for the user's Desktop folder
#define PRESETS_DIR_PATH "ROMPlayer Instruments"

// Download http://audiokit.io/downloads/ROMPlayerInstruments.zip, unzip and put the
// "ROMPlayer Instruments" folder on your desktop.
