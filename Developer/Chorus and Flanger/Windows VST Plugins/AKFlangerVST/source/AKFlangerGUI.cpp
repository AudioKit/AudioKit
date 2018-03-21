#include "AKFlangerGUI.h"
#include "AKFlangerDSP.h"
#include "AKFlangerParams.h"
#include "resource.h"
#include <CommCtrl.h>
#include "TRACE.h"
#include <ShlObj.h>

// APPROXIMATE initial dialog size
#define EDITOR_WIDTH 400
#define EDITOR_HEIGHT 200

#define WINDOW_CLASS "AKFlangerEd"

AKFlangerGUI::AKFlangerGUI (AudioEffect* effect)
    : AEffEditor(effect)
{
      WIDTH = EDITOR_WIDTH;
      HEIGHT = EDITOR_HEIGHT;

      myRect.top    = 0;
      myRect.left   = 0;
      myRect.bottom = HEIGHT;
      myRect.right  = WIDTH;

      effect->setEditor(this);
}

AKFlangerGUI::~AKFlangerGUI()
{
}

bool AKFlangerGUI::open (void* ptr)
{ 
    systemWindow = ptr;
    hwnd = CreateDialog(GetInstance(), MAKEINTRESOURCE(IDD_DIALOG1), (HWND)ptr, dp);

    SetWindowLongPtr(hwnd, GWLP_USERDATA, (LONG_PTR)this);
    ShowWindow(hwnd, SW_SHOW);

    RECT rc;
    GetClientRect(hwnd, &rc);
    myRect.left = (VstInt16)rc.left;
    myRect.top = (VstInt16)rc.top;
    myRect.right = (VstInt16)rc.right;
    myRect.bottom = (VstInt16)rc.bottom;

    updateAllParameters();

    return true;
}

void AKFlangerGUI::close ()
{
    DestroyWindow(hwnd);
    hwnd = 0;
    systemWindow = 0;
}

INT_PTR CALLBACK AKFlangerGUI::dp(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    AKFlangerGUI* instancePtr = (AKFlangerGUI*)GetWindowLongPtr(hDlg, GWLP_USERDATA);
    if (instancePtr != NULL)
    {
        return instancePtr->instanceCallback(hDlg, message, wParam, lParam);
    }
    return (INT_PTR)FALSE;
}

INT_PTR CALLBACK AKFlangerGUI::instanceCallback(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	UNREFERENCED_PARAMETER(lParam);

    AKFlangerDSP *pVst = (AKFlangerDSP*)getEffect();
    float fv;
    int whichSlider;
    char text[50];

	switch (message)
	{
	case WM_INITDIALOG:
		return (INT_PTR)TRUE;

    case WM_HSCROLL:
        if (LOWORD(wParam) == TB_THUMBTRACK)
        {
            fv = HIWORD(wParam) / 100.0f;
            whichSlider = GetDlgCtrlID((HWND)lParam);
            switch (whichSlider)
            {
            case IDC_MODFREQ_SLIDER:
                pVst->setParamFraction(kModFreq, fv);
                pVst->getParamString(kModFreq, text);
                SetDlgItemText(hwnd, IDC_MODFREQ_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_MODDEPTH_SLIDER:
                pVst->setParamFraction(kModDepth, fv);
                pVst->getParamString(kModDepth, text);
                SetDlgItemText(hwnd, IDC_MODDEPTH_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_FEEDBACK_SLIDER:
                pVst->setParamFraction(kFeedback, fv);
                pVst->getParamString(kFeedback, text);
                SetDlgItemText(hwnd, IDC_FEEDBACK_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_DRYWETMIX_SLIDER:
                pVst->setParamFraction(kDryWetMix, fv);
                pVst->getParamString(kDryWetMix, text);
                SetDlgItemText(hwnd, IDC_DRYWETMIX_READOUT, text);
                return (INT_PTR)TRUE;
            }
        }

		break;
	}
	return (INT_PTR)FALSE;
}

void AKFlangerGUI::setParameter(VstInt32 index, float value)
{
    int sliderPos = (int)(100.0f * value + 0.5f);
    AKFlangerDSP *pVst = (AKFlangerDSP*)getEffect();
    char text[50];
    pVst->getParamString(index, text);

    switch (index)
    {
    case kModFreq:
        SendDlgItemMessage(hwnd, IDC_MODFREQ_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_MODFREQ_READOUT, text);
        break;
    case kModDepth:
        SendDlgItemMessage(hwnd, IDC_MODDEPTH_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_MODDEPTH_READOUT, text);
        break;
    case kFeedback:
        SendDlgItemMessage(hwnd, IDC_FEEDBACK_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_FEEDBACK_READOUT, text);
        break;
    case kDryWetMix:
        SendDlgItemMessage(hwnd, IDC_DRYWETMIX_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_DRYWETMIX_READOUT, text);
        break;
    }
}

void AKFlangerGUI::updateAllParameters()
{
    int sliderPos;
    char text[50];
    AKFlangerDSP *pVst = (AKFlangerDSP*)getEffect();

    sliderPos = (int)(100.0f * pVst->getParamFraction(kModFreq) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_MODFREQ_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kModFreq, text);
    SetDlgItemText(hwnd, IDC_MODFREQ_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kModDepth) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_MODDEPTH_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kModDepth, text);
    SetDlgItemText(hwnd, IDC_MODDEPTH_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kFeedback) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_FEEDBACK_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kFeedback, text);
    SetDlgItemText(hwnd, IDC_FEEDBACK_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kDryWetMix) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_DRYWETMIX_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kDryWetMix, text);
    SetDlgItemText(hwnd, IDC_DRYWETMIX_READOUT, text);
}
