// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SustainPedalLogic.hpp"

namespace AudioKitCore
{

    SustainPedalLogic::SustainPedalLogic()
    {
        for (int i=0; i < kMidiNoteNumbers; i++) keyDown[i] = isPlaying[i] = false;
        pedalIsDown = false;
    }
    
    bool SustainPedalLogic::keyDownAction(unsigned noteNumber)
    {
        bool noteShouldStopBeforePlayingAgain = false;
        
        if (pedalIsDown && keyDown[noteNumber])
            noteShouldStopBeforePlayingAgain = true;
        else
            keyDown[noteNumber] = true;
        
        isPlaying[noteNumber] = true;
        return noteShouldStopBeforePlayingAgain;
    }
    
    bool SustainPedalLogic::keyUpAction(unsigned noteNumber)
    {
        bool noteShouldStop = false;
        
        if (!pedalIsDown)
        {
            noteShouldStop = true;
            isPlaying[noteNumber] = false;
        }
        keyDown[noteNumber] = false;
        return noteShouldStop;
    }
    
    void SustainPedalLogic::pedalDown() { pedalIsDown = true; }
    
    void SustainPedalLogic::pedalUp() { pedalIsDown = false; }
    
    bool SustainPedalLogic::isNoteSustaining(unsigned noteNumber)
    {
        return isPlaying[noteNumber] && !keyDown[noteNumber];
    }

    bool SustainPedalLogic::isAnyKeyDown()
    {
        for (int i = 0; i < kMidiNoteNumbers; i++) if (keyDown[i]) return true;
        return false;
    }

    int SustainPedalLogic::firstKeyDown()
    {
        for (int i = 0; i < kMidiNoteNumbers; i++) if (keyDown[i]) return i;
        return -1;
    }
}
