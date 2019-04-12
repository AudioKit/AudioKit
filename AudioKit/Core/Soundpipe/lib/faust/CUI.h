#include <stdlib.h>

#ifndef FAUSTFLOAT
#define FAUSTFLOAT SPFLOAT
#endif

typedef void (* addHorizontalSliderFun) (void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step);
typedef void (* addVerticalSliderFun) (void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step);
typedef void (* addCheckButtonFun) (void* ui_interface, const char* label, FAUSTFLOAT* zone);

typedef struct {
    void* uiInterface;
    addHorizontalSliderFun addHorizontalSlider;
    addVerticalSliderFun addVerticalSlider;
    addCheckButtonFun addCheckButton;
} UIGlue;

