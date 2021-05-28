// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Common name of MIDI Control number from MIDIByte
///
/// - ModulationWheel: Modulation Control
/// - BreathControl: Breath Control (in MIDI Saxophones for example)
/// - FootControl: Foot Control
/// - Portamento: Portamento effect
/// - DataEntry: Data Entry
/// - MainVolume: Volume (Overall)
/// - Balance
/// - Pan: Stereo Panning
/// - Expression: Expression Pedal
/// - LSB: Least Significant Byte
/// - DamperOnOff: Damper Pedal, also known as Hold or Sustain
/// - PortamentoOnOff: Portamento Toggle
/// - SustenutoOnOff: Sustenuto Toggle
/// - SoftPedalOnOff: Soft Pedal Toggle
/// - DataEntryPlus: Data Entry Addition
/// - DataEntryMinus: Data Entry Subtraction
/// - LocalControlOnOff: Enable local control
/// - AllNotesOff: MIDI Panic
/// - CC# (0, 3, 9, 12-31) Unnamed Continuous Controllers
///
public enum MIDIControl: MIDIByte {

    /// Modulation Control
    case modulationWheel = 1
    /// Breath Control (in MIDI Saxophones for example)
    case breathControl = 2
    // ?? 3 ??
    /// Foot Control
    case footControl = 4
    /// Portamento effect
    case portamento = 5
    /// Data Entry
    case dataEntry = 6
    /// Volume (Overall)
    case mainVolume = 7
    /// Balance
    case balance = 8
    // ?? 9 ??
    /// Stereo Panning
    case pan = 10
    /// Expression Pedal
    case expression = 11

    /// Damper Pedal, also known as Hold or Sustain
    case damperOnOff = 64
    /// Portamento Toggle
    case portamentoOnOff = 65
    /// Sustenuto Toggle
    case sustenutoOnOff = 66
    /// Soft Pedal Toggle
    case softPedalOnOff = 67

    /// Sound Variation
    case soundVariation = 70

    /// Resonance
    case resonance = 71
    /// Release Time
    case releaseTime = 72
    /// Attack Time
    case attackTime = 73
    /// Cutoff
    case cutoff = 74
    /// Sound Control 6
    case soundControl6 = 75
    /// Sound Control 7
    case soundControl7 = 76
    /// Sound Control 8
    case soundControl8 = 77
    /// Sound Control 9
    case soundControl9 = 78
    /// Sound Control 10
    case soundControl10 = 79
    /// GP Button 1
    /// Decay, or Roland Tone Level 1
    case gpButton1 = 80
    /// Hi Pass Filter Frequency
    /// Roland Tone Level 1
    /// GP Button 2
    case gpButton2 = 81
    /// Roland Tone Level 3
    /// GP Button 3
    case gpButton3 = 82
    /// Roland Tone Level 4
    /// GP Button 4
    case gpButton4 = 83
    /// Reverb Level
    case reverbLevel = 91
    /// Tremolo Level
    case tremoloLevel = 92
    /// chorus Level
    case chorusLevel = 93
    /// celeste Level
    /// or Detune
    case celesteLevel = 94
    /// phaser Level
    case phaserLevel = 95
    /// Data Entry Addition
    case dataEntryPlus = 96

    /// Data Entry Subtraction
    case dataEntryMinus = 97

    /// Non Registered Parameter Number LSB
    case NrpnLsb = 98
    /// Non Registered Parameter Number MSB
    case NrpnMsb = 99

    /// Registered Parameter Number LSB
    case RpnLsb = 100
    /// Registered Parameter Number MSB
    case RpnMsb = 101

    /// All sounds off
    case allSoundsOff = 120

    /// All controllers off
    case allControllersOff = 121

    /// Enable local control
    case localControlOnOff = 122
    /// MIDI Panic
    case allNotesOff = 123

    /// Omni Mode Off
    case omniModeOff = 124
    /// Omni Mode On
    case omniModeOn = 125

    /// Mono Operation
    case monoOperation = 126
    /// Poly Operation
    case polyOperation = 127

    // Unnamed CC values: (Must be a better way)

    /// Bank Select Most Significant Byte
    /// Continuous Controller Number 0
    case cc0 = 0
    /// Continuous Controller Number 3
    case cc3 = 3
    /// Continuous Controller Number 9
    case cc9 = 9
    /// Effect Control 1
    /// Continuous Controller Number 12
    case cc12 = 12
    /// Effect Control 2
    /// Continuous Controller Number 13
    case cc13 = 13
    /// Continuous Controller Number 14
    case cc14 = 14
    /// Continuous Controller Number 15
    case cc15 = 15
    /// Continuous Controller Number 16
    case cc16 = 16
    /// Continuous Controller Number 17
    case cc17 = 17
    /// Continuous Controller Number 18
    case cc18 = 18
    /// Continuous Controller Number 19
    case cc19 = 19
    /// Continuous Controller Number 20
    case cc20 = 20
    /// Continuous Controller Number 21
    case cc21 = 21
    /// Continuous Controller Number 22
    case cc22 = 22
    /// Continuous Controller Number 23
    case cc23 = 23
    /// Continuous Controller Number 24
    case cc24 = 24
    /// Continuous Controller Number 25
    case cc25 = 25
    /// Continuous Controller Number 26
    case cc26 = 26
    /// Continuous Controller Number 27
    case cc27 = 27
    /// Continuous Controller Number 28
    case cc28 = 28
    /// Continuous Controller Number 29
    case cc29 = 29
    /// Continuous Controller Number 30
    case cc30 = 30
    /// Continuous Controller Number 31
    case cc31 = 31

    /// Bank Select Least Significant Byte
    /// MSB is CC 0
    /// Continuous Controller Number 31
    case cc32 = 32

    /// Modulation Wheel Least Significant Byte
    /// MSB is CC 1
    /// Continuous Controller Number 33
    case modulationWheelLsb = 33

    /// Breath Controller Least Significant Byte
    /// MSB is CC 2
    /// Continuous Controller Number 34
    case breathControllerLsb = 34

    /// MSB is CC 3
    /// ?? 35 ??

    /// Foot Control Least Significant Byte
    /// MSB is CC 4
    /// Continuous Controller Number 35
    case footControlLsb = 35

    /// Portamento Time Least Significant Byte
    /// MSB is CC 5
    /// Continuous Controller Number 37
    case portamentoLsb = 37

    /// Data Entry Least Significant Byte
    /// MSB is CC 6
    /// Continuous Controller Number 38
    case dataEntryLsb = 38

    /// Main Volume Least Significant Byte
    /// MSB is CC 7
    /// Continuous Controller Number 39
    case mainVolumeLsb = 39

    /// Balance Least Significant Byte
    /// MSB is CC 8
    /// Continuous Controller Number 40
    case balanceLsb = 40

    /// Pan Position Least Significant Byte
    /// MSB is CC 10
    /// Continuous Controller Number 42
    case panLsb = 42

    /// Expression Least Significant Byte
    /// MSB is CC 11
    /// Continuous Controller Number 43
    case expressionLsb = 43

    /// Effect Control 1 Least Significant Byte
    /// MSB is CC 12
    /// Roland Protamento on and rate
    /// Continuous Controller Number 44
    case effectControl1Lsb = 44

    /// Effect Control 2 Least Significant Byte
    /// MSB is CC 13
    /// Continuous Controller Number 45
    case effectControl2Lsb = 45

    /// Other Controller Descriptions
    var controllerDescription: String {

        switch self {
        case 0:     return "Bank MSB"
        case 1:     return "Modulation"
        case 2:     return "Breath"
        case 3:     return "Ctrl 3"
        case 4:     return "Foot Control"
        case 5:     return "Portamento Time"
        case 6:     return "Data MSB"
        case 7:     return "Volume"
        case 8:     return "Balance"
        case 9:     return "Ctrl 9"
        case 10:    return "Pan"
        case 11:    return "Expression"
        case 12:    return "Effect #1 MSB"
        case 13:    return "Effect #2 MSB"
        case 14:    return "Ctrl 14"
        case 15:    return "Ctrl 15"
        case 16:    return "General #1"
        case 17:    return "General #2"
        case 18:    return "General #3"
        case 19:    return "General #4"
        case 20:    return "Ctrl 20"
        case 21:    return "Ctrl 21"
        case 22:    return "Ctrl 22"
        case 23:    return "Ctrl 23"
        case 24:    return "Ctrl 24"
        case 25:    return "Ctrl 25"
        case 26:    return "Ctrl 26"
        case 27:    return "Ctrl 27"
        case 28:    return "Ctrl 28"
        case 29:    return "Ctrl 29"
        case 30:    return "Ctrl 30"
        case 31:    return "Ctrl 31"
        case 32:    return "Bank LSB"
        case 33:    return "(#01 LSB)"
        case 34:    return "(#02 LSB)"
        case 35:    return "(#03 LSB)"
        case 36:    return "(#04 LSB)"
        case 37:    return "(#05 LSB)"
        case 38:    return "Data LSB"
        case 39:    return "(#07 LSB)"
        case 40:    return "(#08 LSB)"
        case 41:    return "(#09 LSB)"
        case 42:    return "(#10 LSB)"
        case 43:    return "(#11 LSB)"
        case 44:    return "Effect #1 LSB"
        case 45:    return "Effect #2 LSB"
        case 46:    return "(#14 LSB)"
        case 47:    return "(#15 LSB)"
        case 48:    return "(#16 LSB)"
        case 49:    return "(#17 LSB)"
        case 50:    return "(#18 LSB)"
        case 51:    return "(#19 LSB)"
        case 52:    return "(#20 LSB)"
        case 53:    return "(#21 LSB)"
        case 54:    return "(#22 LSB)"
        case 55:    return "(#23 LSB)"
        case 56:    return "(#24 LSB)"
        case 57:    return "(#25 LSB)"
        case 58:    return "(#26 LSB)"
        case 59:    return "(#27 LSB)"
        case 60:    return "(#28 LSB)"
        case 61:    return "(#29 LSB)"
        case 62:    return "(#30 LSB)"
        case 63:    return "(#31 LSB)"
        case 64:    return "Sustain"
        case 65:    return "Portamento"
        case 66:    return "Sostenuto"
        case 67:    return "Soft Pedal "
        case 68:    return "Legato"
        case 69:    return "Hold 2"
        case 70:    return "Sound Variation"
        case 71:    return "Timbre"
        case 72:    return "Release Time"
        case 73:    return "Attack Time"
        case 74:    return "Brightness"
        case 75:    return "Decay Time"
        case 76:    return "Vibrato Rate"
        case 77:    return "Vibrato Depth"
        case 78:    return "Vibrato Delay"
        case 79:    return "Ctrl 79"
        case 80:    return "Decay"
        case 81:    return "HPF Frequency"
        case 82:    return "General #7"
        case 83:    return "General #8"
        case 84:    return "Portamento Control"
        case 85:    return "Ctrl 85"
        case 86:    return "Ctrl 86"
        case 87:    return "Ctrl 87"
        case 88:    return "High Res Velocity Prefix"
        case 89:    return "Ctrl 89"
        case 90:    return "Ctrl 90"
        case 91:    return "Reverb"
        case 92:    return "Tremolo Depth"
        case 93:    return "Chorus Send Level"
        case 94:    return "Celeste (Detune) Depth"
        case 95:    return "Phaser Depth"
        case 96:    return "Data Increment"
        case 97:    return "Data Entry Decrement"
        case 98:    return "Non-Reg. LSB"
        case 99:    return "Non-Reg. MSB"
        case 100:   return "Reg.Par. LSB"
        case 101:   return "Reg.Par. MSB"
        case 102:   return "Ctrl 102"
        case 103:   return "Ctrl 103"
        case 104:   return "Ctrl 104"
        case 105:   return "Ctrl 105"
        case 106:   return "Ctrl 106"
        case 107:   return "Ctrl 107"
        case 108:   return "Ctrl 108"
        case 109:   return "Ctrl 109"
        case 110:   return "Ctrl 110"
        case 111:   return "Ctrl 111"
        case 112:   return "Ctrl 112"
        case 113:   return "Ctrl 113"
        case 114:   return "Ctrl 114"
        case 115:   return "Ctrl 115"
        case 116:   return "Ctrl 116"
        case 117:   return "Ctrl 117"
        case 118:   return "Ctrl 118"
        case 119:   return "Ctrl 119"
        case 120:   return "All Sounds Off"
        case 121:   return "Reset All Controllers"
        case 122:   return "Local Control"
        case 123:   return "All Notes Off"
        case 124:   return "Omni Mode Off"
        case 125:   return "Omni Mode On"
        case 126:   return "Mono Mode On"
        case 127:   return "Poly Mode On"

        default:
            return "-"
        }
    }
}
