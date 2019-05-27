#include "AKSamplerGUI.h"
#include "AKSamplerDSP.h"
#include "AKSamplerParams.h"
#include "resource.h"
#include <CommCtrl.h>
#include "TRACE.h"
#include <ShlObj.h>

// APPROXIMATE initial dialog size
#define EDITOR_WIDTH 400
#define EDITOR_HEIGHT 400

#define WINDOW_CLASS "NetVSTEd"

AKSamplerGUI::AKSamplerGUI (AudioEffect* effect)
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

AKSamplerGUI::~AKSamplerGUI()
{
}

bool AKSamplerGUI::open (void* ptr)
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

    populatePresetsComboBox();

    return true;
}

void AKSamplerGUI::close ()
{
    DestroyWindow(hwnd);
    hwnd = 0;
    systemWindow = 0;
}

INT_PTR CALLBACK AKSamplerGUI::dp(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    AKSamplerGUI* instancePtr = (AKSamplerGUI*)GetWindowLongPtr(hDlg, GWLP_USERDATA);
    if (instancePtr != NULL)
    {
        return instancePtr->instanceCallback(hDlg, message, wParam, lParam);
    }
    return (INT_PTR)FALSE;
}

INT_PTR CALLBACK AKSamplerGUI::instanceCallback(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	UNREFERENCED_PARAMETER(lParam);

    AKSamplerDSP *pVst = (AKSamplerDSP*)getEffect();
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
            case IDC_MASTER_VOLUME_SLIDER:
                pVst->setParamFraction(kMasterVolume, fv);
                pVst->getParamString(kMasterVolume, text);
                SetDlgItemText(hwnd, IDC_MASTER_VOLUME_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_PITCH_OFFSET_SLIDER:
                pVst->setParamFraction(kPitchBend, fv);
                pVst->getParamString(kPitchBend, text);
                SetDlgItemText(hwnd, IDC_PITCH_OFFSET_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_VIBRATO_DEPTH_SLIDER:
                pVst->setParamFraction(kVibratoDepth, fv);
                pVst->getParamString(kVibratoDepth, text);
                SetDlgItemText(hwnd, IDC_VIBRATO_DEPTH_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_FILTER_CUTOFF_SLIDER:
                pVst->setParamFraction(kFilterCutoff, fv);
                pVst->getParamString(kFilterCutoff, text);
                SetDlgItemText(hwnd, IDC_FILTER_CUTOFF_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_FILTER_KEYTRACK_SLIDER:
                pVst->setParamFraction(kKeyTracking, fv);
                pVst->getParamString(kKeyTracking, text);
                SetDlgItemText(hwnd, IDC_FILTER_KEYTRACK_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_FILTER_RESONANCE_SLIDER:
                pVst->setParamFraction(kFilterResonance, fv);
                pVst->getParamString(kFilterResonance, text);
                SetDlgItemText(hwnd, IDC_FILTER_RESONANCE_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_FILTER_EGSTRENGTH_SLIDER:
                pVst->setParamFraction(kFilterEgStrength, fv);
                pVst->getParamString(kFilterEgStrength, text);
                SetDlgItemText(hwnd, IDC_FILTER_EGSTRENGTH_READOUT, text);
                return (INT_PTR)TRUE;

            case IDC_GLIDE_RATE_SLIDER:
                pVst->setParamFraction(kGlideRate, fv);
                pVst->getParamString(kGlideRate, text);
                SetDlgItemText(hwnd, IDC_GLIDE_RATE_READOUT, text);
                return (INT_PTR)TRUE;

            case IDC_AMP_ATTACK_SLIDER:
                pVst->setParamFraction(kAmpAttackTime, fv);
                pVst->getParamString(kAmpAttackTime, text);
                SetDlgItemText(hwnd, IDC_AMP_ATTACK_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_AMP_DECAY_SLIDER:
                pVst->setParamFraction(kAmpDecayTime, fv);
                pVst->getParamString(kAmpDecayTime, text);
                SetDlgItemText(hwnd, IDC_AMP_DECAY_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_AMP_SUSTAIN_SLIDER:
                pVst->setParamFraction(kAmpSustainLevel, fv);
                pVst->getParamString(kAmpSustainLevel, text);
                SetDlgItemText(hwnd, IDC_AMP_SUSTAIN_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_AMP_RELEASE_SLIDER:
                pVst->setParamFraction(kAmpReleaseTime, fv);
                pVst->getParamString(kAmpReleaseTime, text);
                SetDlgItemText(hwnd, IDC_AMP_RELEASE_READOUT, text);
                return (INT_PTR)TRUE;

            case IDC_FILTER_ATTACK_SLIDER:
                pVst->setParamFraction(kFilterAttackTime, fv);
                pVst->getParamString(kFilterAttackTime, text);
                SetDlgItemText(hwnd, IDC_FILTER_ATTACK_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_FILTER_DECAY_SLIDER:
                pVst->setParamFraction(kFilterDecayTime, fv);
                pVst->getParamString(kFilterDecayTime, text);
                SetDlgItemText(hwnd, IDC_FILTER_DECAY_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_FILTER_SUSTAIN_SLIDER:
                pVst->setParamFraction(kFilterSustainLevel, fv);
                pVst->getParamString(kFilterSustainLevel, text);
                SetDlgItemText(hwnd, IDC_FILTER_SUSTAIN_READOUT, text);
                return (INT_PTR)TRUE;
            case IDC_FILTER_RELEASE_SLIDER:
                pVst->setParamFraction(kFilterReleaseTime, fv);
                pVst->getParamString(kFilterReleaseTime, text);
                SetDlgItemText(hwnd, IDC_FILTER_RELEASE_READOUT, text);
                return (INT_PTR)TRUE;
            }
        }

	case WM_COMMAND:
        switch (LOWORD(wParam))
        {
        case IDC_LOOPTHRU_CHECK:
            if (HIWORD(wParam) == BN_CLICKED)
            {
                float v = 0.0f;
                if (SendDlgItemMessage(hDlg, IDC_LOOPTHRU_CHECK, BM_GETCHECK, 0, 0)) v = 1.0f;
                pVst->setParamFraction(kLoopThruRelease, v);
                return (INT_PTR)TRUE;
            }
            break;

        case IDC_MONO_CHECK:
            if (HIWORD(wParam) == BN_CLICKED)
            {
                float v = 0.0f;
                if (SendDlgItemMessage(hDlg, IDC_MONO_CHECK, BM_GETCHECK, 0, 0)) v = 1.0f;
                pVst->setParamFraction(kMonophonic, v);
                return (INT_PTR)TRUE;
            }
            break;

        case IDC_LEGATO_CHECK:
            if (HIWORD(wParam) == BN_CLICKED)
            {
                float v = 0.0f;
                if (SendDlgItemMessage(hDlg, IDC_LEGATO_CHECK, BM_GETCHECK, 0, 0)) v = 1.0f;
                pVst->setParamFraction(kLegato, v);
                return (INT_PTR)TRUE;
            }
            break;

        case IDC_FILTER_ENABLE_CHECK:
            if (HIWORD(wParam) == BN_CLICKED)
            {
                float v = 0.0f;
                if (SendDlgItemMessage(hDlg, IDC_FILTER_ENABLE_CHECK, BM_GETCHECK, 0, 0)) v = 1.0f;
                pVst->setParamFraction(kFilterEnable, v);
                enableFilterControls(v > 0.0f);
                return (INT_PTR)TRUE;
            }
            break;

        case IDC_PRESETCB:
            if (HIWORD(wParam) == CBN_SELCHANGE)
            {
                int sel = (int)SendDlgItemMessage(hwnd, IDC_PRESETCB, CB_GETCURSEL, 0, 0);
                if (sel != CB_ERR)
                {
                    SendDlgItemMessage(hwnd, IDC_PRESETCB, CB_GETLBTEXT, (WPARAM)sel, (LPARAM)(pVst->presetName));
                    pVst->loadPreset();
                }
            }
            break;

        case IDC_PRESETDIRBTN:
            choosePresetDirectory();
            break;
        }

		break;
	}
	return (INT_PTR)FALSE;
}

void AKSamplerGUI::enableFilterControls(bool show)
{
    EnableWindow(GetDlgItem(hwnd, IDC_FILTER_CUTOFF_SLIDER), show ? TRUE : FALSE);
    EnableWindow(GetDlgItem(hwnd, IDC_FILTER_KEYTRACK_SLIDER), show ? TRUE : FALSE);
    EnableWindow(GetDlgItem(hwnd, IDC_FILTER_EGSTRENGTH_SLIDER), show ? TRUE : FALSE);
    EnableWindow(GetDlgItem(hwnd, IDC_FILTER_RESONANCE_SLIDER), show ? TRUE : FALSE);
    EnableWindow(GetDlgItem(hwnd, IDC_FILTER_ATTACK_SLIDER), show ? TRUE : FALSE);
    EnableWindow(GetDlgItem(hwnd, IDC_FILTER_DECAY_SLIDER), show ? TRUE : FALSE);
    EnableWindow(GetDlgItem(hwnd, IDC_FILTER_SUSTAIN_SLIDER), show ? TRUE : FALSE);
    EnableWindow(GetDlgItem(hwnd, IDC_FILTER_RELEASE_SLIDER), show ? TRUE : FALSE);
}

void AKSamplerGUI::setParameter(VstInt32 index, float value)
{
    int sliderPos = (int)(100.0f * value + 0.5f);
    AKSamplerDSP *pVst = (AKSamplerDSP*)getEffect();
    char text[50];
    pVst->getParamString(index, text);

    switch (index)
    {
    case kMasterVolume:
        SendDlgItemMessage(hwnd, IDC_MASTER_VOLUME_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_MASTER_VOLUME_READOUT, text);
        break;
    case kPitchBend:
        SendDlgItemMessage(hwnd, IDC_PITCH_OFFSET_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_PITCH_OFFSET_READOUT, text);
        break;
    case kVibratoDepth:
        SendDlgItemMessage(hwnd, IDC_VIBRATO_DEPTH_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_VIBRATO_DEPTH_READOUT, text);
        break;
    case kGlideRate:
        SendDlgItemMessage(hwnd, IDC_GLIDE_RATE_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_GLIDE_RATE_READOUT, text);
        break;
    case kFilterEnable:
        SendDlgItemMessage(hwnd, IDC_FILTER_ENABLE_CHECK, BM_SETCHECK,
            pVst->getParamFraction(kFilterEnable) > 0.5f ? BST_CHECKED : BST_UNCHECKED, 0);
        break;
    case kFilterCutoff:
        SendDlgItemMessage(hwnd, IDC_FILTER_CUTOFF_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_FILTER_CUTOFF_READOUT, text);
        break;
    case kKeyTracking:
        SendDlgItemMessage(hwnd, IDC_FILTER_KEYTRACK_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_FILTER_KEYTRACK_READOUT, text);
        break;
    case kFilterEgStrength:
        SendDlgItemMessage(hwnd, IDC_FILTER_EGSTRENGTH_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_FILTER_EGSTRENGTH_READOUT, text);
        break;
    case kFilterResonance:
        SendDlgItemMessage(hwnd, IDC_FILTER_RESONANCE_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_FILTER_RESONANCE_READOUT, text);
        break;
    case kAmpAttackTime:
        SendDlgItemMessage(hwnd, IDC_AMP_ATTACK_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_AMP_ATTACK_READOUT, text);
        break;
    case kAmpDecayTime:
        SendDlgItemMessage(hwnd, IDC_AMP_DECAY_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_AMP_DECAY_READOUT, text);
        break;
    case kAmpSustainLevel:
        SendDlgItemMessage(hwnd, IDC_AMP_SUSTAIN_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_AMP_SUSTAIN_READOUT, text);
        break;
    case kAmpReleaseTime:
        SendDlgItemMessage(hwnd, IDC_AMP_RELEASE_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_AMP_RELEASE_READOUT, text);
        break;
    case kFilterAttackTime:
        SendDlgItemMessage(hwnd, IDC_FILTER_ATTACK_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_FILTER_ATTACK_READOUT, text);
        break;
    case kFilterDecayTime:
        SendDlgItemMessage(hwnd, IDC_FILTER_DECAY_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_FILTER_DECAY_READOUT, text);
        break;
    case kFilterSustainLevel:
        SendDlgItemMessage(hwnd, IDC_FILTER_SUSTAIN_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_FILTER_SUSTAIN_READOUT, text);
        break;
    case kFilterReleaseTime:
        SendDlgItemMessage(hwnd, IDC_FILTER_RELEASE_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
        SetDlgItemText(hwnd, IDC_FILTER_RELEASE_READOUT, text);
        break;
    case kLoopThruRelease:
        SendDlgItemMessage(hwnd, IDC_LOOPTHRU_CHECK, BM_SETCHECK,
            pVst->getParamFraction(kLoopThruRelease) > 0.5f ? BST_CHECKED : BST_UNCHECKED, 0);
        break;
    case kMonophonic:
        SendDlgItemMessage(hwnd, IDC_MONO_CHECK, BM_SETCHECK,
            pVst->getParamFraction(kMonophonic) > 0.5f ? BST_CHECKED : BST_UNCHECKED, 0);
        break;
    case kLegato:
        SendDlgItemMessage(hwnd, IDC_LEGATO_CHECK, BM_SETCHECK,
            pVst->getParamFraction(kLegato) > 0.5f ? BST_CHECKED : BST_UNCHECKED, 0);
        break;
    }
}

void AKSamplerGUI::updateAllParameters()
{
    int sliderPos;
    char text[50];
    AKSamplerDSP *pVst = (AKSamplerDSP*)getEffect();

    sliderPos = (int)(100.0f * pVst->getParamFraction(kMasterVolume) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_MASTER_VOLUME_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kMasterVolume, text);
    SetDlgItemText(hwnd, IDC_MASTER_VOLUME_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kPitchBend) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_PITCH_OFFSET_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kPitchBend, text);
    SetDlgItemText(hwnd, IDC_PITCH_OFFSET_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kVibratoDepth) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_VIBRATO_DEPTH_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kVibratoDepth, text);
    SetDlgItemText(hwnd, IDC_VIBRATO_DEPTH_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kGlideRate) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_GLIDE_RATE_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kGlideRate, text);
    SetDlgItemText(hwnd, IDC_GLIDE_RATE_READOUT, text);

    bool filterEnabled = pVst->getParameter(kFilterEnable) > 0.5;
    SendDlgItemMessage(hwnd, IDC_FILTER_ENABLE_CHECK, BM_SETCHECK,
        filterEnabled ? BST_CHECKED : BST_UNCHECKED, 0);
    enableFilterControls(filterEnabled);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kFilterCutoff) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_FILTER_CUTOFF_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kFilterCutoff, text);
    SetDlgItemText(hwnd, IDC_FILTER_CUTOFF_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kKeyTracking) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_FILTER_KEYTRACK_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kKeyTracking, text);
    SetDlgItemText(hwnd, IDC_FILTER_KEYTRACK_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kFilterEgStrength) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_FILTER_EGSTRENGTH_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kFilterEgStrength, text);
    SetDlgItemText(hwnd, IDC_FILTER_EGSTRENGTH_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kFilterResonance) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_FILTER_RESONANCE_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kFilterResonance, text);
    SetDlgItemText(hwnd, IDC_FILTER_RESONANCE_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kAmpAttackTime) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_AMP_ATTACK_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kAmpAttackTime, text);
    SetDlgItemText(hwnd, IDC_AMP_ATTACK_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kAmpDecayTime) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_AMP_DECAY_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kAmpDecayTime, text);
    SetDlgItemText(hwnd, IDC_AMP_DECAY_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kAmpSustainLevel) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_AMP_SUSTAIN_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kAmpSustainLevel, text);
    SetDlgItemText(hwnd, IDC_AMP_SUSTAIN_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kAmpReleaseTime) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_AMP_RELEASE_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kAmpReleaseTime, text);
    SetDlgItemText(hwnd, IDC_AMP_RELEASE_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kFilterAttackTime) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_FILTER_ATTACK_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kFilterAttackTime, text);
    SetDlgItemText(hwnd, IDC_FILTER_ATTACK_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kFilterDecayTime) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_FILTER_DECAY_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kFilterDecayTime, text);
    SetDlgItemText(hwnd, IDC_FILTER_DECAY_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kFilterSustainLevel) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_FILTER_SUSTAIN_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kFilterSustainLevel, text);
    SetDlgItemText(hwnd, IDC_FILTER_SUSTAIN_READOUT, text);

    sliderPos = (int)(100.0f * pVst->getParamFraction(kFilterReleaseTime) + 0.5f);
    SendDlgItemMessage(hwnd, IDC_FILTER_RELEASE_SLIDER, TBM_SETPOS, (WPARAM)TRUE, (LPARAM)sliderPos);
    pVst->getParamString(kFilterSustainLevel, text);
    SetDlgItemText(hwnd, IDC_FILTER_RELEASE_READOUT, text);

    bool loopThruRel = pVst->getParameter(kLoopThruRelease) > 0.5;
    SendDlgItemMessage(hwnd, IDC_LOOPTHRU_CHECK, BM_SETCHECK,
        loopThruRel ? BST_CHECKED : BST_UNCHECKED, 0);

    bool monophonic = pVst->getParameter(kMonophonic) > 0.5;
    SendDlgItemMessage(hwnd, IDC_MONO_CHECK, BM_SETCHECK,
        monophonic ? BST_CHECKED : BST_UNCHECKED, 0);

    bool legato = pVst->getParameter(kLegato) > 0.5;
    SendDlgItemMessage(hwnd, IDC_LEGATO_CHECK, BM_SETCHECK,
        legato ? BST_CHECKED : BST_UNCHECKED, 0);
}

void AKSamplerGUI::populatePresetsComboBox()
{
    SendDlgItemMessage(hwnd, IDC_PRESETCB, CB_RESETCONTENT, 0, 0);

    AKSamplerDSP *pVst = (AKSamplerDSP*)getEffect();
    char wildcardPath[250];
    sprintf(wildcardPath, "%s\\*.sfz", pVst->presetFolderPath);

    WIN32_FIND_DATA FindFileData;
    HANDLE hFind;
    int count = 0;

    hFind = FindFirstFile(wildcardPath, &FindFileData);
    if (hFind == INVALID_HANDLE_VALUE)
    {
        TRACE("populatePresetsComboBox: FindFirstFile failed (%d)\n", GetLastError());
        return;
    }

    //TRACE("preset %s\n", FindFileData.cFileName);
    SendDlgItemMessage(hwnd, IDC_PRESETCB, CB_ADDSTRING, 0, (LPARAM)FindFileData.cFileName);
    count++;
    while (FindNextFile(hFind, &FindFileData))
    {
        //TRACE("preset %s\n", FindFileData.cFileName);
        SendDlgItemMessage(hwnd, IDC_PRESETCB, CB_ADDSTRING, 0, (LPARAM)FindFileData.cFileName);
        count++;
    }

    FindClose(hFind);

    if (count)
    {
        // select first preset and load it
        SendDlgItemMessage(hwnd, IDC_PRESETCB, CB_SETCURSEL, 0, 0);
        SendDlgItemMessage(hwnd, IDC_PRESETCB, CB_GETLBTEXT, 0, (LPARAM)(pVst->presetName));
        pVst->loadPreset();
    }
}

static int CALLBACK BrowseCallbackProc(HWND hwnd, UINT uMsg, LPARAM lParam, LPARAM lpData)
{
    if (uMsg == BFFM_INITIALIZED)
    {
        AKSamplerDSP* pDSP = (AKSamplerDSP*)lpData;
        SendMessage(hwnd, BFFM_SETSELECTION, TRUE, lpData);
    }
    return 0;
}

void AKSamplerGUI::choosePresetDirectory()
{
    AKSamplerDSP* pDSP = (AKSamplerDSP*)getEffect();

    BROWSEINFO bi = { 0 };
    bi.lpszTitle = ("Choose a folder containing .sfz files");
    bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE;
    bi.lpfn = BrowseCallbackProc;
    bi.lParam = (LPARAM)pDSP->presetFolderPath;

    LPITEMIDLIST pidl = SHBrowseForFolder(&bi);
    if (pidl != 0)
    {
        // get the name of the folder and put it in path
        SHGetPathFromIDList(pidl, pDSP->presetFolderPath);

        // free memory used
        IMalloc * imalloc = 0;
        if (SUCCEEDED(SHGetMalloc(&imalloc)))
        {
            imalloc->Free(pidl);
            imalloc->Release();
        }

        populatePresetsComboBox();
    }
}
