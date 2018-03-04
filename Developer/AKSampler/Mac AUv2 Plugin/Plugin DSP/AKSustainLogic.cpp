//
//  AKSustainLogic.cpp
//  AKSampler
//
//  Created by Shane Dunne on 2018-03-03.
//

#include "AKSustainLogic.hpp"

AKSustainLogic::AKSustainLogic()
{
    for (int i=0; i < MIDI_NOTENUMBERS; i++) keyDown[i] = isPlaying[i] = false;
    pedalIsDown = false;
}

AKSustainLogic::Action AKSustainLogic::keyDownAction(unsigned noteNumber)
{
    Action action = kPlayNote;
    
    if (pedalIsDown && keyDown[noteNumber])
        action = kStopNoteThenPlay;
    else
        keyDown[noteNumber] = true;
    
    isPlaying[noteNumber] = true;
    return action;
}

AKSustainLogic::Action AKSustainLogic::keyUpAction(unsigned noteNumber)
{
    Action action = kDoNothing;
    
    if (!pedalIsDown)
    {
        action = kStopNote;
        isPlaying[noteNumber] = false;
    }
    keyDown[noteNumber] = false;
    return action;
}

void AKSustainLogic::pedalDown() { pedalIsDown = true; }

void AKSustainLogic::pedalUp() { pedalIsDown = false; }

bool AKSustainLogic::isNoteSustaining(unsigned noteNumber)
{
    return isPlaying[noteNumber] && !keyDown[noteNumber];
}
