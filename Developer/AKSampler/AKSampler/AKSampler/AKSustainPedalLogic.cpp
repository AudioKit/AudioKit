//
//  AKSustainPedalLogic.cpp
//  AKSampler
//
//  Created by Shane Dunne on 2018-03-03.
//

#include "AKSustainPedalLogic.hpp"

AKSustainPedalLogic::AKSustainPedalLogic()
{
    for (int i=0; i < MIDI_NOTENUMBERS; i++) keyDown[i] = isPlaying[i] = false;
    pedalIsDown = false;
}

AKSustainPedalLogic::Action AKSustainPedalLogic::keyDownAction(unsigned noteNumber)
{
    Action action = kPlayNote;
    
    if (pedalIsDown && keyDown[noteNumber])
        action = kStopNoteThenPlay;
    else
        keyDown[noteNumber] = true;
    
    isPlaying[noteNumber] = true;
    return action;
}

AKSustainPedalLogic::Action AKSustainPedalLogic::keyUpAction(unsigned noteNumber)
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

void AKSustainPedalLogic::pedalDown() { pedalIsDown = true; }

void AKSustainPedalLogic::pedalUp() { pedalIsDown = false; }

bool AKSustainPedalLogic::isNoteSustaining(unsigned noteNumber)
{
    return isPlaying[noteNumber] && !keyDown[noteNumber];
}
