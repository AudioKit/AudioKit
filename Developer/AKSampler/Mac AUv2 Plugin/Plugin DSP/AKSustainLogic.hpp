//
//  AKSustainLogic.hpp
//  AKSampler
//
//  Created by Shane Dunne on 2018-03-03.
//

#pragma once

#define MIDI_NOTENUMBERS 128    // MIDI offers 128 distinct note numbers

class AKSustainLogic
{
    bool keyDown[MIDI_NOTENUMBERS];
    bool isPlaying[MIDI_NOTENUMBERS];
    bool pedalIsDown;
    
public:
    AKSustainLogic();
    
    enum Action { kDoNothing, kPlayNote, kStopNote, kStopNoteThenPlay };
    
    Action keyDownAction(unsigned noteNumber);
    Action keyUpAction(unsigned noteNumber);

    void pedalDown();
    bool isNoteSustaining(unsigned noteNumber);
    void pedalUp();
};
