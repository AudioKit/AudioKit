#pragma once
#define WIN32_LEAN_AND_MEAN 1

#include <iostream>
#include "public.sdk/source/vst2.x/aeffeditor.h"
#include <windows.h>

extern void* hInstance;
inline HINSTANCE GetInstance() { return (HINSTANCE)hInstance; }

class AKFlangerGUI : public AEffEditor
{
public:
    AKFlangerGUI (AudioEffect* effect);
	virtual ~AKFlangerGUI ();

    AudioEffect* getEffect () { return effect;}
    bool getRect (ERect** rect) { *rect = &myRect; return true;}
   
    void idle () {}

    bool isOpen () { return systemWindow != 0; }
    bool open (void* ptr);
    void close ();

    // update GUI in response to parameters changed via automation
    virtual void setParameter (VstInt32 index, float value);

protected:
    INT_PTR CALLBACK instanceCallback(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam);
    static INT_PTR CALLBACK dp(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam);

    ERect myRect;
    HWND hwnd;
    int WIDTH, HEIGHT;

    void updateAllParameters();
};
