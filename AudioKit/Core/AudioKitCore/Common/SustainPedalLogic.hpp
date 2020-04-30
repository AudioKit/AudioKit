// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

namespace AudioKitCore
{
    static const int kMidiNoteNumbers = 128;
    
    class SustainPedalLogic
    {
        bool keyDown[kMidiNoteNumbers];
        bool isPlaying[kMidiNoteNumbers];
        bool pedalIsDown;
        
    public:
        SustainPedalLogic();
        
        // return true if given note should stop playing
        bool keyDownAction(unsigned noteNumber);
        bool keyUpAction(unsigned noteNumber);
        
        void pedalDown();
        bool isNoteSustaining(unsigned noteNumber);
        bool isAnyKeyDown();
        int firstKeyDown();
        void pedalUp();
    };

}
