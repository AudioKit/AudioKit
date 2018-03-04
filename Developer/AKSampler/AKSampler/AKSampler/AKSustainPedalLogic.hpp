//
//  AKSustainPedalLogic.hpp
//  AKSampler
//
//  Created by Shane Dunne on 2018-03-03.
//

#pragma once

#define MIDI_NOTENUMBERS 128    // MIDI offers 128 distinct note numbers

class AKSustainPedalLogic
{
    bool keyDown[MIDI_NOTENUMBERS];
    bool isPlaying[MIDI_NOTENUMBERS];
    bool pedalIsDown;
    
public:
    AKSustainPedalLogic();
    
    enum Action { kDoNothing, kPlayNote, kStopNote, kStopNoteThenPlay };
    
    Action keyDownAction(unsigned noteNumber);
    Action keyUpAction(unsigned noteNumber);

    void pedalDown();
    bool isNoteSustaining(unsigned noteNumber);
    void pedalUp();
};
