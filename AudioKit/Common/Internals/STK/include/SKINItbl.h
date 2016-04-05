
#include "SKINImsg.h"

namespace stk {

#define __SK_MaxMsgTypes_ 80

struct SkiniSpec { char messageString[32];
                   long  type;
                   long data2;
                   long data3;
                 };

/* SEE COMMENT BLOCK AT BOTTOM FOR FIELDS AND USES   */
/* MessageString     , type,     data2,     data3    */ 

struct SkiniSpec skini_msgs[__SK_MaxMsgTypes_] = 
{
 {"NoteOff"          ,        __SK_NoteOff_,                   SK_DBL,  SK_DBL},
 {"NoteOn"           ,         __SK_NoteOn_,                   SK_DBL,  SK_DBL},
 {"PolyPressure"     ,   __SK_PolyPressure_,                   SK_DBL,  SK_DBL},
 {"ControlChange"    ,  __SK_ControlChange_,                   SK_INT,  SK_DBL},
 {"ProgramChange"    ,  __SK_ProgramChange_,                   SK_DBL,    NOPE},
 {"AfterTouch"       ,     __SK_AfterTouch_,                   SK_DBL,    NOPE},
 {"ChannelPressure"  ,__SK_ChannelPressure_,                   SK_DBL,    NOPE},
 {"PitchWheel"       ,     __SK_PitchWheel_,                   SK_DBL,    NOPE},
 {"PitchBend"        ,      __SK_PitchBend_,                   SK_DBL,    NOPE},
 {"PitchChange"      ,    __SK_PitchChange_,                   SK_DBL,    NOPE},

 {"Clock"            ,          __SK_Clock_,                     NOPE,    NOPE},
 {"Undefined"        ,                  249,                     NOPE,    NOPE},
 {"SongStart"        ,      __SK_SongStart_,                     NOPE,    NOPE},
 {"Continue"         ,       __SK_Continue_,                     NOPE,    NOPE},
 {"SongStop"         ,       __SK_SongStop_,                     NOPE,    NOPE},
 {"Undefined"        ,                  253,                     NOPE,    NOPE},
 {"ActiveSensing"    ,  __SK_ActiveSensing_,                     NOPE,    NOPE},
 {"SystemReset"      ,    __SK_SystemReset_,                     NOPE,    NOPE},

 {"Volume"           ,  __SK_ControlChange_, __SK_Volume_            ,  SK_DBL},
 {"ModWheel"         ,  __SK_ControlChange_, __SK_ModWheel_          ,  SK_DBL},
 {"Modulation"       ,  __SK_ControlChange_, __SK_Modulation_        ,  SK_DBL},
 {"Breath"           ,  __SK_ControlChange_, __SK_Breath_            ,  SK_DBL},
 {"FootControl"      ,  __SK_ControlChange_, __SK_FootControl_       ,  SK_DBL},
 {"Portamento"       ,  __SK_ControlChange_, __SK_Portamento_        ,  SK_DBL},
 {"Balance"          ,  __SK_ControlChange_, __SK_Balance_           ,  SK_DBL},
 {"Pan"              ,  __SK_ControlChange_, __SK_Pan_               ,  SK_DBL},
 {"Sustain"          ,  __SK_ControlChange_, __SK_Sustain_           ,  SK_DBL},
 {"Damper"           ,  __SK_ControlChange_, __SK_Damper_            ,  SK_DBL},
 {"Expression"       ,  __SK_ControlChange_, __SK_Expression_        ,  SK_DBL},

 {"NoiseLevel"       ,  __SK_ControlChange_, __SK_NoiseLevel_        ,  SK_DBL},
 {"PickPosition"     ,  __SK_ControlChange_, __SK_PickPosition_      ,  SK_DBL},
 {"StringDamping"    ,  __SK_ControlChange_, __SK_StringDamping_     ,  SK_DBL},
 {"StringDetune"     ,  __SK_ControlChange_, __SK_StringDetune_      ,  SK_DBL},
 {"BodySize"         ,  __SK_ControlChange_, __SK_BodySize_          ,  SK_DBL},
 {"BowPressure"      ,  __SK_ControlChange_, __SK_BowPressure_       ,  SK_DBL},
 {"BowPosition"      ,  __SK_ControlChange_, __SK_BowPosition_       ,  SK_DBL},
 {"BowBeta"          ,  __SK_ControlChange_, __SK_BowBeta_           ,  SK_DBL},
 
 {"ReedStiffness"    ,  __SK_ControlChange_, __SK_ReedStiffness_     ,  SK_DBL},
 {"ReedRestPos"      ,  __SK_ControlChange_, __SK_ReedRestPos_       ,  SK_DBL},
 {"FluteEmbouchure"  ,  __SK_ControlChange_, __SK_FluteEmbouchure_   ,  SK_DBL},
 {"LipTension"       ,  __SK_ControlChange_, __SK_LipTension_        ,  SK_DBL},
 {"StrikePosition"   ,  __SK_ControlChange_, __SK_StrikePosition_    ,  SK_DBL},
 {"StickHardness"    ,  __SK_ControlChange_, __SK_StickHardness_     ,  SK_DBL},

 {"TrillDepth"       ,  __SK_ControlChange_, __SK_TrillDepth_        ,  SK_DBL}, 
 {"TrillSpeed"       ,  __SK_ControlChange_, __SK_TrillSpeed_        ,  SK_DBL},
                                             
 {"Strumming"        ,  __SK_ControlChange_, __SK_Strumming_         ,  127   }, 
 {"NotStrumming"     ,  __SK_ControlChange_, __SK_Strumming_         ,  0     },
                                             
 {"PlayerSkill"      ,  __SK_ControlChange_, __SK_PlayerSkill_       ,  SK_DBL}, 

 {"Chord"            ,  __SK_Chord_	       ,                   SK_DBL,  SK_STR}, 
 {"ChordOff"         ,  __SK_ChordOff_     ,                   SK_DBL,    NOPE}, 

 {"ShakerInst"       ,  __SK_ControlChange_, __SK_ShakerInst_        ,  SK_DBL},
 {"Maraca"           ,  __SK_ControlChange_, __SK_ShakerInst_	       ,   0    },
 {"Sekere"           ,  __SK_ControlChange_, __SK_ShakerInst_	       ,   1    },
 {"Cabasa"           ,  __SK_ControlChange_, __SK_ShakerInst_        ,   2    },
 {"Bamboo"           ,  __SK_ControlChange_, __SK_ShakerInst_        ,   3    },
 {"Waterdrp"         ,  __SK_ControlChange_, __SK_ShakerInst_        ,   4    },
 {"Tambourn"         ,  __SK_ControlChange_, __SK_ShakerInst_        ,   5    },
 {"Sleighbl"         ,  __SK_ControlChange_, __SK_ShakerInst_        ,   6    },
 {"Guiro"            ,  __SK_ControlChange_, __SK_ShakerInst_        ,   7    },	

 {"OpenFile"         ,                  256,                   SK_STR,    NOPE},
 {"SetPath"          ,                  257,                   SK_STR,    NOPE},

 {"FilePath"         ,  __SK_SINGER_FilePath_      ,           SK_STR,    NOPE},
 {"Frequency"        ,  __SK_SINGER_Frequency_     ,           SK_STR,    NOPE},
 {"NoteName"         ,  __SK_SINGER_NoteName_      ,           SK_STR,    NOPE},
 {"VocalShape"       ,  __SK_SINGER_Shape_         ,           SK_STR,    NOPE},
 {"Glottis"          ,  __SK_SINGER_Glot_          ,           SK_STR,    NOPE},
 {"VoicedUnVoiced"   ,  __SK_SINGER_VoicedUnVoiced_,           SK_DBL,  SK_STR},
 {"Synthesize"       ,  __SK_SINGER_Synthesize_    ,           SK_STR,    NOPE},
 {"Silence"          ,  __SK_SINGER_Silence_       ,           SK_STR,    NOPE},
 {"RndVibAmt"        ,  __SK_SINGER_RndVibAmt_     ,           SK_STR,    NOPE},
 {"VibratoAmt"       ,  __SK_ControlChange_        ,__SK_SINGER_VibratoAmt_,SK_DBL},
 {"VibFreq"          ,  __SK_ControlChange_        ,__SK_SINGER_VibFreq_   ,SK_DBL}
};


/**  FORMAT: *************************************************************/
/*                                                                       */
/* MessageStr$      , type, data2, data3,                                */
/*                                                                       */
/*     type is the message type sent back from the SKINI line parser.    */
/*     data<n> is either                                                 */
/*          NOPE    : field not used, specifically, there aren't going   */                                           
/*                    to be any more fields on this line.  So if there   */
/*                    is NOPE in data2, data3 won't even be checked      */
/*          SK_INT  : byte (actually scanned as 32 bit signed integer)   */
/*                    If it's a MIDI data field which is required to     */
/*                    be an integer, like a controller number, it's      */
/*                    0-127.  Otherwise, get creative with SK_INTs.      */
/*          SK_DBL  : double precision floating point.  SKINI uses these */
/*                    in the MIDI context for note numbers with micro    */
/*                    tuning, velocities, controller values, etc.        */
/*          SK_STR  : only valid in final field.  This allows (nearly)   */
/*                    arbitrary message types to be supported by simply  */
/*                    scanning the string to EndOfLine and then passing  */
/*                    it to a more intelligent handler.  For example,    */
/*                    MIDI SYSEX (system exclusive) messages of up to    */
/*                    256 bytes can be read as space-delimited integers  */
/*                    into the SK_STR buffer.  Longer bulk dumps,        */
/*                    soundfiles, etc. should be handled as a new        */
/*                    message type pointing to a FileName stored in the  */
/*                    SK_STR field, or as a new type of multi-line       */                                      
/*                    message.                                           */
/*                                                                       */
/*************************************************************************/

} // stk namespace
