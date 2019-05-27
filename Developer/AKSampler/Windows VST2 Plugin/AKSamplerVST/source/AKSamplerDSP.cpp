#include "AKSamplerDSP.h"
#include "AKSamplerGUI.h"
#include "AKSamplerParams.h"
#include "TRACE.h"
#include "sndfile.hh"
#include <ShlObj.h>
#include <stdlib.h>
#include "wavpack.h"
#define _USE_MATH_DEFINES
#include <math.h>

#define NOTE_HZ(midiNoteNumber) ( 440.0f * pow(2.0f, ((midiNoteNumber) - 69.0f)/12.0f) )

static bool GetDesktopFolderPath(char* pBuffer)
{
    PWSTR pwDir;
    HRESULT hr = SHGetKnownFolderPath(FOLDERID_Desktop, 0, NULL, &pwDir);
    wcstombs(pBuffer, pwDir, 100);

    return hr == S_OK;
}

static bool GetDownloadsFolderPath(char* pBuffer)
{
    PWSTR pwDir;
    HRESULT hr = SHGetKnownFolderPath(FOLDERID_Downloads, 0, NULL, &pwDir);
    wcstombs(pBuffer, pwDir, 100);

    return hr == S_OK;
}


AudioEffect* createEffectInstance (audioMasterCallback audioMaster)
{
	return new AKSamplerDSP (audioMaster, 1);
}

AKSamplerDSP::AKSamplerDSP (audioMasterCallback audioMaster, VstInt32 numPrograms)
    : AudioEffectX (audioMaster, numPrograms, kNumParams)
{
	if (audioMaster)
	{
		setNumInputs(0);
		setNumOutputs(2);
		canProcessReplacing();
		isSynth();
		setUniqueID('AKss');
	}
	suspend();

    editor = new AKSamplerGUI(this);

    double sampleRateHz = (double)getSampleRate();
    init(sampleRateHz);

    // load one sinewave or sawtooth sample
    float wave[1024];
#if 0
    for (int i = 0; i < 1024; i++) wave[i] = (float)sin(2 * M_PI * i / 1024.0);   // sine
#else
    for (int i = 0; i < 1024; i++) wave[i] = 2.0f * i / 1024.0f - 1.0f; // saw
#endif
    AKSampleDataDescriptor sdd = {
        { 29, 44100.0f / 1024, 0, 127, 0, 127, true, 0.0f, 1.0f, 0.0f, 0.0f },
        44100.0f, false, 1, 1024, wave };
    loadSampleData(sdd);
    buildSimpleKeyMap();
    loopThruRelease = true;

    setADSRAttackDurationSeconds(0.01f);
    setADSRDecayDurationSeconds(0.1f);
    setADSRSustainFraction(0.8f);
    setADSRReleaseDurationSeconds(0.5f);

    isFilterEnabled = false;
    cutoffMultiple = 0.0f;
    keyTracking = 1.0f;
    linearResonance = 0.5f;
    setFilterAttackDurationSeconds(2.0f);
    setFilterDecayDurationSeconds(2.0f);
    setFilterSustainFraction(0.1f);
    setFilterReleaseDurationSeconds(10.0f);

    // Set up preset folder path
    char baseDir[100];
    GetDesktopFolderPath(baseDir);
    sprintf(presetFolderPath, "%s\\%s", baseDir, PRESETS_DIR_PATH);

    // If you don't intend to use presets, uncomment one of these two (not both)
    //loadAifDemoSamples();
    //loadWvDemoSamples();
}

AKSamplerDSP::~AKSamplerDSP ()
{
}

bool AKSamplerDSP::loadSoundFile(AKSampleFileDescriptor &sfd)
{
    // save the path we were given
    char filePath[250];
    strcpy(filePath, sfd.path);

    // try changing file extension to ".wv" to see if there's already a compressed file
    char* pExt = (char*)strrchr(sfd.path, '.');
    strcpy(pExt, ".wv");
    if (loadCompressedSampleFile(sfd)) return true;

    // Load standard sound file
    AKSampleDataDescriptor sdd;
    sdd.sampleDescriptor = sfd.sampleDescriptor;

    SndfileHandle sfh(filePath);
    TRACE("loadSoundFile %s, response \"%s\"\n", filePath, sfh.strError());

    sdd.sampleRate = (float)sfh.samplerate();
    sdd.channelCount = sfh.channels();
    sdd.sampleCount = (int)sfh.frames();
    sdd.isInterleaved = sdd.channelCount > 1;

    sdd.data = new float[sdd.channelCount * sdd.sampleCount];
    sfh.readf(sdd.data, sdd.sampleCount);
    loadSampleData(sdd);
    delete[] sdd.data;

    return true;
}

bool AKSamplerDSP::loadCompressedSampleFile(AKSampleFileDescriptor& sfd)
{
    char errMsg[100];
    WavpackContext* wpc = WavpackOpenFileInput(sfd.path, errMsg, OPEN_2CH_MAX, 0);
    if (wpc == 0)
    {
        TRACE("Wavpack error loading %s: %s\n", sfd.path, errMsg);
        //char msg[1000];
        //sprintf(msg, "Wavpack error loading %s: %s\n", sfd.path, errMsg);
        //MessageBox(0, msg, "Wavpack error", MB_OK);
        return false;
    }

    AKSampleDataDescriptor sdd;
    sdd.sampleDescriptor = sfd.sampleDescriptor;
    sdd.sampleRate = (float)WavpackGetSampleRate(wpc);
    sdd.channelCount = WavpackGetReducedChannels(wpc);
    sdd.sampleCount = WavpackGetNumSamples(wpc);
    sdd.isInterleaved = sdd.channelCount > 1;
    sdd.data = new float[sdd.channelCount * sdd.sampleCount];

    int mode = WavpackGetMode(wpc);
    WavpackUnpackSamples(wpc, (int32_t*)sdd.data, sdd.sampleCount);
    if ((mode & MODE_FLOAT) == 0)
    {
        // convert samples to floating-point
        int bps = WavpackGetBitsPerSample(wpc);
        float scale = 1.0f / (1 << (bps - 1));
        float* pf = sdd.data;
        int32_t* pi = (int32_t*)pf;
        for (int i = 0; i < (sdd.sampleCount * sdd.channelCount); i++)
            *pf++ = scale * *pi++;
    }

    loadSampleData(sdd);
    delete[] sdd.data;
    return true;
}

void AKSamplerDSP::loadAifDemoSamples()
{
    char baseDir[100];
    GetDesktopFolderPath(baseDir);
    char pathBuffer[200];
    const char* samplePrefix = "Sounds\\ROMPlayer AKCoreSampler Instruments\\samples\\TX LoTine81z_ms";

    AKSampleFileDescriptor sfd;
    sfd.path = pathBuffer;
    sfd.sampleDescriptor.isLooping = false;    // set true to test looping with fractional endpoints
    sfd.sampleDescriptor.startPoint = 0.0;
    sfd.sampleDescriptor.loopStartPoint = 0.2f;
    sfd.sampleDescriptor.loopEndPoint = 0.3f;
    sfd.sampleDescriptor.endPoint = 0.0f;

    sfd.sampleDescriptor.noteNumber = 48;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 0; sfd.sampleDescriptor.maximumNoteNumber = 51;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "c2");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "c2");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "c2");
    loadSoundFile(sfd);

    sfd.sampleDescriptor.noteNumber = 54;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 52; sfd.sampleDescriptor.maximumNoteNumber = 57;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "f#2");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "f#2");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "f#2");
    loadSoundFile(sfd);

    sfd.sampleDescriptor.noteNumber = 60;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 58; sfd.sampleDescriptor.maximumNoteNumber = 63;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "c3");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "c3");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "c3");
    loadSoundFile(sfd);

    sfd.sampleDescriptor.noteNumber = 66;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 64; sfd.sampleDescriptor.maximumNoteNumber = 69;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "f#3");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "f#3");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "f#3");
    loadSoundFile(sfd);

    sfd.sampleDescriptor.noteNumber = 72;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 70; sfd.sampleDescriptor.maximumNoteNumber = 75;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "c4");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "c4");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "c4");
    loadSoundFile(sfd);

    sfd.sampleDescriptor.noteNumber = 78;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 76; sfd.sampleDescriptor.maximumNoteNumber = 81;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "f#4");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "f#4");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "f#4");
    loadSoundFile(sfd);

    sfd.sampleDescriptor.noteNumber = 84;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 82; sfd.sampleDescriptor.maximumNoteNumber = 127;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "c5");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "c5");
    loadSoundFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.aif", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "c5");
    loadSoundFile(sfd);

    buildKeyMap();
}

void AKSamplerDSP::loadWvDemoSamples()
{
    // Example showing how to load a group of samples when you don't have a .sfz metadata file.

    // Download http://audiokit.io/downloads/TX_LoTine81z.zip
    // These are Wavpack-compressed versions of the similarly-named samples in ROMPlayer.
    // Put folder wherever you wish (e.g. inside a "Compressed Sounds" folder on your Mac desktop
    // and edit paths below accordingly

    char baseDir[100];
    GetDownloadsFolderPath(baseDir);
    char pathBuffer[200];
    const char* samplePrefix = "TX LoTine81z\\TX LoTine81z_ms";

    AKSampleFileDescriptor sfd;
    sfd.path = pathBuffer;
    sfd.sampleDescriptor.isLooping = false;    // set true to test looping with fractional endpoints
    sfd.sampleDescriptor.startPoint = 0.0;
    sfd.sampleDescriptor.loopStartPoint = 0.2f;
    sfd.sampleDescriptor.loopEndPoint = 0.3f;
    sfd.sampleDescriptor.endPoint = 0.0f;

    sfd.sampleDescriptor.noteNumber = 48;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 0; sfd.sampleDescriptor.maximumNoteNumber = 51;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "c2");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "c2");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "c2");
    loadCompressedSampleFile(sfd);

    sfd.sampleDescriptor.noteNumber = 54;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 52; sfd.sampleDescriptor.maximumNoteNumber = 57;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "f#2");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "f#2");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "f#2");
    loadCompressedSampleFile(sfd);

    sfd.sampleDescriptor.noteNumber = 60;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 58; sfd.sampleDescriptor.maximumNoteNumber = 63;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "c3");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "c3");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "c3");
    loadCompressedSampleFile(sfd);

    sfd.sampleDescriptor.noteNumber = 66;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 64; sfd.sampleDescriptor.maximumNoteNumber = 69;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "f#3");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "f#3");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "f#3");
    loadCompressedSampleFile(sfd);

    sfd.sampleDescriptor.noteNumber = 72;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 70; sfd.sampleDescriptor.maximumNoteNumber = 75;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "c4");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "c4");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "c4");
    loadCompressedSampleFile(sfd);

    sfd.sampleDescriptor.noteNumber = 78;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 76; sfd.sampleDescriptor.maximumNoteNumber = 81;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "f#4");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "f#4");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "f#4");
    loadCompressedSampleFile(sfd);

    sfd.sampleDescriptor.noteNumber = 84;
    sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber);
    sfd.sampleDescriptor.minimumNoteNumber = 82; sfd.sampleDescriptor.maximumNoteNumber = 127;
    sfd.sampleDescriptor.minimumVelocity = 0; sfd.sampleDescriptor.maximumVelocity = 43;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 2, sfd.sampleDescriptor.noteNumber, "c5");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 44; sfd.sampleDescriptor.maximumVelocity = 86;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 1, sfd.sampleDescriptor.noteNumber, "c5");
    loadCompressedSampleFile(sfd);
    sfd.sampleDescriptor.minimumVelocity = 87; sfd.sampleDescriptor.maximumVelocity = 127;
    sprintf(pathBuffer, "%s\\%s%d_%03d_%s.wv", baseDir, samplePrefix, 0, sfd.sampleDescriptor.noteNumber, "c5");
    loadCompressedSampleFile(sfd);

    buildKeyMap();
}

static bool hasPrefix(char* string, const char* prefix)
{
    return strncmp(string, prefix, strlen(prefix)) == 0;
}

bool AKSamplerDSP::loadPreset()
{
    // Nicer way to load presets using .sfz metadata files. See bottom of AKSampler_Params.h
    // for instructions to download and set up these presets.
    TRACE("loadPreset: %s...", presetName);

    this->deinit();     // unload any samples already present

    char buf[1000];
    sprintf(buf, "%s\\%s", presetFolderPath, presetName);

    FILE* pfile = fopen(buf, "r");
    if (!pfile) return false;

    int lokey, hikey, pitch, lovel, hivel;
    float lorand, hirand;
    float fStart, fEnd;
    bool bLoop;
    float fLoopStart, fLoopEnd;
    float fTuneOffsetCents;
    char sampleFileName[100];
    char *p, *pp;

    while (fgets(buf, sizeof(buf), pfile))
    {
        p = buf;
        while (*p != 0 && isspace(*p)) p++;

        pp = strrchr(p, '\n');
        if (pp) *pp = 0;

        if (hasPrefix(p, "<group>"))
        {
            p += 7;
            lokey = 0;
            hikey = 127;
            pitch = 60;

            pp = strstr(p, "key");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) lokey = hikey = atoi(pp);
            }

            pp = strstr(p, "lokey");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) lokey = atoi(pp);
            }

            pp = strstr(p, "hikey");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) hikey = atoi(pp);
            }

            pp = strstr(p, "pitch_keycenter");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) pitch = atoi(pp);
            }
        }
        else if (hasPrefix(p, "<region>"))
        {
            p += 8;
            lovel = 0;
            hivel = 127;
            lorand = 0.0f;
            hirand = 1.0f;
            sampleFileName[0] = 0;
            bLoop = false;
            fLoopStart = 0.0f;
            fLoopEnd = 0.0f;
            fStart = 0.0f;
            fEnd = 0.0f;
            fTuneOffsetCents = 0.0f;

            pp = strstr(p, "lorand");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) lorand = float(atof(pp));
            }

            pp = strstr(p, "hirand");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) hirand = float(atof(pp));
            }

            pp = strstr(p, "lovel");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) lovel = atoi(pp);
            }

            pp = strstr(p, "hivel");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) hivel = atoi(pp);
            }

            pp = strstr(p, "offset");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) fStart = (float)atof(pp);
            }

            pp = strstr(p, "end");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) fEnd = (float)atof(pp);
            }

            pp = strstr(p, "loop_mode");
            if (pp)
            {
                bLoop = true;
            }

            pp = strstr(p, "loop_start");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) fLoopStart = (float)atof(pp);
            }

            pp = strstr(p, "loop_end");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) fLoopEnd = (float)atof(pp);
            }

            pp = strstr(p, "tune");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                if (pp) fTuneOffsetCents = (float)atof(pp);
            }

            pp = strstr(p, "sample");
            if (pp)
            {
                pp = strchr(pp, '=');
                if (pp) pp++;
                while (*pp != 0 && isspace(*pp)) pp++;
                //char* pq = sampleFileName;
                //while (*pp != '.') *pq++ = *pp++;
                //strcpy(pq, ".wv");
                strcpy(sampleFileName, pp);
            }

            // If there's anything after '.wav' or '.wv', truncate it
            pp = strstr(sampleFileName, ".wav ");
            if (pp) pp[4] = 0;
            pp = strstr(sampleFileName, ".wv ");
            if (pp) pp[3] = 0;

            sprintf(buf, "%s\\%s", presetFolderPath, sampleFileName);

            AKSampleFileDescriptor sfd;
            sfd.path = buf;
            sfd.sampleDescriptor.isLooping = bLoop;
            sfd.sampleDescriptor.startPoint = fStart;
            sfd.sampleDescriptor.loopStartPoint = fLoopStart;
            sfd.sampleDescriptor.loopEndPoint = fLoopEnd;
            sfd.sampleDescriptor.endPoint = fEnd;
            sfd.sampleDescriptor.noteNumber = pitch;
            sfd.sampleDescriptor.noteFrequency = NOTE_HZ(sfd.sampleDescriptor.noteNumber - fTuneOffsetCents/100.0f);
            sfd.sampleDescriptor.minimumNoteNumber = lokey;
            sfd.sampleDescriptor.maximumNoteNumber = hikey;
            sfd.sampleDescriptor.minimumVelocity = lovel;
            sfd.sampleDescriptor.maximumVelocity = hivel;

            if (lorand == 0.0f) loadSoundFile(sfd);
        }
    }
    fclose(pfile);

    buildKeyMap();
    TRACE("done\n");
    return true;
}

bool AKSamplerDSP::getOutputProperties (VstInt32 index, VstPinProperties* properties)
{
	if (index < 2)
	{
		vst_strncpy (properties->label, "Vstx ", 63);
		char temp[11] = {0};
		int2string (index + 1, temp, 10);
		vst_strncat (properties->label, temp, 63);

		properties->flags = kVstPinIsActive;
		if (index < 2)
			properties->flags |= kVstPinIsStereo;	// make channel 1+2 stereo
		return true;
	}
	return false;
}

bool AKSamplerDSP::getEffectName (char* name)
{
	vst_strncpy (name, "AKSampler", kVstMaxEffectNameLen);
	return true;
}

bool AKSamplerDSP::getVendorString (char* text)
{
	vst_strncpy (text, "AudioKit", kVstMaxVendorStrLen);
	return true;
}

bool AKSamplerDSP::getProductString (char* text)
{
	vst_strncpy (text, "AKSampler", kVstMaxProductStrLen);
	return true;
}

VstInt32 AKSamplerDSP::getVendorVersion ()
{ 
	return 1000; 
}

VstInt32 AKSamplerDSP::canDo (char* text)
{
    if (!strcmp (text, "hasEditor"))
        return 1;
	if (!strcmp (text, "receiveVstEvents"))
		return 1;
	if (!strcmp (text, "receiveVstMidiEvent"))
		return 1;
	return -1;	// explicitly can't do; 0 => don't know
}

VstInt32 AKSamplerDSP::getNumMidiInputChannels ()
{
	return 1; // we are monotimbral
}

VstInt32 AKSamplerDSP::getNumMidiOutputChannels ()
{
	return 0; // no MIDI output back to Host app
}

void AKSamplerDSP::getParameterName (VstInt32 index, char* label)
{
	switch (index)
	{
        // note kVstMaxParamStrLen is only 8 chars
		case kMasterVolume:
            vst_strncpy (label, "Volume", kVstMaxParamStrLen); 
            break;
        case kPitchBend:
            vst_strncpy(label, "P.Bend", kVstMaxParamStrLen);
            break;
        case kVibratoDepth:
            vst_strncpy(label, "VibDepth", kVstMaxParamStrLen);
            break;
        case kFilterCutoff:
            vst_strncpy(label, "F.Cutoff", kVstMaxParamStrLen);
            break;
        case kKeyTracking:
            vst_strncpy(label, "F.KeyTrk", kVstMaxParamStrLen);
            break;
        case kFilterEgStrength:
            vst_strncpy(label, "F.EnvAmt", kVstMaxParamStrLen);
            break;
        case kFilterResonance:
            vst_strncpy(label, "F.Reso", kVstMaxParamStrLen);
            break;
        case kFilterEnable:
            vst_strncpy(label, "F.Enable", kVstMaxParamStrLen);
            break;
        case kAmpAttackTime:
            vst_strncpy(label, "Amp.Atk", kVstMaxParamStrLen);
            break;
        case kAmpDecayTime:
            vst_strncpy(label, "Amp.Dcy", kVstMaxParamStrLen);
            break;
        case kAmpSustainLevel:
            vst_strncpy(label, "Amp.Sus", kVstMaxParamStrLen);
            break;
        case kAmpReleaseTime:
            vst_strncpy(label, "Amp.Rel", kVstMaxParamStrLen);
            break;
        case kFilterAttackTime:
            vst_strncpy(label, "Flt.Atk", kVstMaxParamStrLen);
            break;
        case kFilterDecayTime:
            vst_strncpy(label, "Flt.Dcy", kVstMaxParamStrLen);
            break;
        case kFilterSustainLevel:
            vst_strncpy(label, "Flt.Sus", kVstMaxParamStrLen);
            break;
        case kFilterReleaseTime:
            vst_strncpy(label, "Flt.Rel", kVstMaxParamStrLen);
            break;
        case kLoopThruRelease:
            vst_strncpy(label, "Loop.Rel", kVstMaxParamStrLen);
            break;
        case kMonophonic:
            vst_strncpy(label, "Mono", kVstMaxParamStrLen);
            break;
        case kLegato:
            vst_strncpy(label, "Legato", kVstMaxParamStrLen);
            break;
        case kGlideRate:
            vst_strncpy(label, "Glide", kVstMaxParamStrLen);
            break;
    }
}

void AKSamplerDSP::getParameterDisplay (VstInt32 index, char* text)
{
	text[0] = 0;
	switch (index)
	{
		case kMasterVolume:
            float2string(masterVolume, text, kVstMaxParamStrLen);
            break;
        case kPitchBend:
            float2string(pitchOffset, text, kVstMaxParamStrLen);
            break;
        case kVibratoDepth:
            float2string(vibratoDepth, text, kVstMaxParamStrLen);
            break;
        case kFilterCutoff:
            float2string(cutoffMultiple, text, kVstMaxParamStrLen);
            break;
        case kKeyTracking:
            float2string(keyTracking, text, kVstMaxParamStrLen);
            break;
        case kFilterEgStrength:
            float2string(cutoffEnvelopeStrength, text, kVstMaxParamStrLen);
            break;
        case kFilterResonance:
            float2string(-20.0f * log10(linearResonance), text, kVstMaxParamStrLen);
            break;
        case kFilterEnable:
            if (isFilterEnabled)
                vst_strncpy(text, "ON", kVstMaxParamStrLen);
            else
                vst_strncpy(text, "OFF", kVstMaxParamStrLen);
            break;
        case kAmpAttackTime:
            float2string(getADSRAttackDurationSeconds(), text, kVstMaxParamStrLen);
            break;
        case kAmpDecayTime:
            float2string(getADSRDecayDurationSeconds(), text, kVstMaxParamStrLen);
            break;
        case kAmpSustainLevel:
            float2string(getADSRSustainFraction(), text, kVstMaxParamStrLen);
            break;
        case kAmpReleaseTime:
            float2string(getADSRReleaseDurationSeconds(), text, kVstMaxParamStrLen);
            break;
        case kFilterAttackTime:
            float2string(getFilterAttackDurationSeconds(), text, kVstMaxParamStrLen);
            break;
        case kFilterDecayTime:
            float2string(getFilterDecayDurationSeconds(), text, kVstMaxParamStrLen);
            break;
        case kFilterSustainLevel:
            float2string(getFilterSustainFraction(), text, kVstMaxParamStrLen);
            break;
        case kFilterReleaseTime:
            float2string(getFilterReleaseDurationSeconds(), text, kVstMaxParamStrLen);
            break;
        case kLoopThruRelease:
            if (loopThruRelease)
                vst_strncpy(text, "YES", kVstMaxParamStrLen);
            else
                vst_strncpy(text, "NO", kVstMaxParamStrLen);
            break;
        case kMonophonic:
            if (isMonophonic)
                vst_strncpy(text, "YES", kVstMaxParamStrLen);
            else
                vst_strncpy(text, "NO", kVstMaxParamStrLen);
            break;
        case kLegato:
            if (isLegato)
                vst_strncpy(text, "YES", kVstMaxParamStrLen);
            else
                vst_strncpy(text, "NO", kVstMaxParamStrLen);
            break;
        case kGlideRate:
            float2string(glideRate, text, kVstMaxParamStrLen);
            break;
    }
}

void AKSamplerDSP::getParamString(VstInt32 index, char* text)
{
    text[0] = 0;
    switch (index)
    {
    case kMasterVolume:
        sprintf(text, "%.1f %%", 100.0f * masterVolume);
        break;
    case kPitchBend:
        sprintf(text, "%.2f semi", pitchOffset);
        break;
    case kVibratoDepth:
        sprintf(text, "%.2f semi", vibratoDepth);
        break;
    case kFilterCutoff:
        sprintf(text, "%.1f", cutoffMultiple);
        break;
    case kKeyTracking:
        sprintf(text, "%.1f %%", 100.0f * keyTracking);
        break;
    case kFilterEgStrength:
        sprintf(text, "%.1f", cutoffEnvelopeStrength);
        break;
    case kFilterResonance:
        sprintf(text, "%.1f dB", -20.0f * log10(linearResonance));
        break;
    case kFilterEnable:
        sprintf(text, "%s", isFilterEnabled ? "enabled" : "disabled");
        break;
    case kAmpAttackTime:
        sprintf(text, "%.2f sec", getADSRAttackDurationSeconds());
        break;
    case kAmpDecayTime:
        sprintf(text, "%.2f sec", getADSRDecayDurationSeconds());
        break;
    case kAmpSustainLevel:
        sprintf(text, "%.1f %%", 100.0f * getADSRSustainFraction());
        break;
    case kAmpReleaseTime:
        sprintf(text, "%.2f sec", getADSRReleaseDurationSeconds());
        break;
    case kFilterAttackTime:
        sprintf(text, "%.2f sec", getFilterAttackDurationSeconds());
        break;
    case kFilterDecayTime:
        sprintf(text, "%.2f sec", getFilterDecayDurationSeconds());
        break;
    case kFilterSustainLevel:
        sprintf(text, "%.1f %%", 100.0f * getFilterSustainFraction());
        break;
    case kFilterReleaseTime:
        sprintf(text, "%.2f sec", getFilterReleaseDurationSeconds());
        break;
    case kLoopThruRelease:
        sprintf(text, "%s", loopThruRelease ? "yes" : "no");
        break;
    case kMonophonic:
        sprintf(text, "%s", isMonophonic ? "mono" : "poly");
        break;
    case kLegato:
        sprintf(text, "%s", isLegato ? "legato" : "normal");
        break;
    case kGlideRate:
        sprintf(text, "%.2f sec/octave", glideRate);
        break;
    }
}

void AKSamplerDSP::setParamFraction(VstInt32 index, float value)
{
    switch (index)
    {
        // value is a fraction which may require conversion to actual parameter range
    case kMasterVolume:
        masterVolume = value;
        break;
    case kPitchBend:
        pitchOffset = -2.0f + value * 4.0f;
        break;
    case kVibratoDepth:
        vibratoDepth = -2.0f + value * 4.0f;
        break;
    case kFilterCutoff:
        cutoffMultiple = value * 100.0f;
        break;
    case kKeyTracking:
        keyTracking = 4.0f * (value - 0.5f);
        break;
    case kFilterEgStrength:
        cutoffEnvelopeStrength = value * 100.0f;
        break;
    case kFilterResonance:
        linearResonance = pow(10.0f, -0.5f * value);
        break;
    case kFilterEnable:
        isFilterEnabled = value > 0.5f;
        break;
    case kAmpAttackTime:
        setADSRAttackDurationSeconds(value * 10.0f);
        break;
    case kAmpDecayTime:
        setADSRDecayDurationSeconds(value * 10.0f);
        break;
    case kAmpSustainLevel:
        setADSRSustainFraction(value);
        break;
    case kAmpReleaseTime:
        setADSRReleaseDurationSeconds(value * 10.0f);
        break;
    case kFilterAttackTime:
        setFilterAttackDurationSeconds(value * 10.0f);
        break;
    case kFilterDecayTime:
        setFilterDecayDurationSeconds(value * 10.0f);
        break;
    case kFilterSustainLevel:
        setFilterSustainFraction(value);
        break;
    case kFilterReleaseTime:
        setFilterReleaseDurationSeconds(value * 10.0f);
        break;
    case kLoopThruRelease:
        loopThruRelease = value > 0.5f;
        break;
    case kMonophonic:
        isMonophonic = value > 0.5f;
        break;
    case kLegato:
        isLegato = value > 0.5f;
        break;
    case kGlideRate:
        glideRate = value * 10.0f;
        break;
    }
}

void AKSamplerDSP::setParameter (VstInt32 index, float value)
{
    setParamFraction(index, value);
    if (editor) ((AKSamplerGUI*)editor)->setParameter (index, value);
}

float AKSamplerDSP::getParameter (VstInt32 index)
{
	float value = 0;    // converted output value must be a fraction, range 0.0 - 1.0
	switch (index)
	{
		case kMasterVolume:
            value = masterVolume;
            break;
        case kPitchBend:
            value = (pitchOffset + 2.0f) / 4.0f;
            break;
        case kVibratoDepth:
            value = (vibratoDepth + 2.0f) / 4.0f;
            break;
        case kFilterCutoff:
            value = cutoffMultiple / 100.0f;
            break;
        case kKeyTracking:
            value = 0.5f + keyTracking / 4.0f;
            break;
        case kFilterEgStrength:
            value = cutoffEnvelopeStrength / 100.0f;
            break;
        case kFilterResonance:
            value = -20.0f * log10(linearResonance);
            break;
        case kFilterEnable:
            value = isFilterEnabled ? 1.0f : 0.0f;
            break;
        case kAmpAttackTime:
            value = getADSRAttackDurationSeconds() / 10.0f;
            break;
        case kAmpDecayTime:
            value = getADSRDecayDurationSeconds() / 10.0f;
            break;
        case kAmpSustainLevel:
            value = getADSRSustainFraction();
            break;
        case kAmpReleaseTime:
            value = getADSRReleaseDurationSeconds() / 10.0f;
            break;
        case kFilterAttackTime:
            value = getFilterAttackDurationSeconds() / 10.0f;
            break;
        case kFilterDecayTime:
            value = getFilterDecayDurationSeconds() / 10.0f;
            break;
        case kFilterSustainLevel:
            value = getFilterSustainFraction();
            break;
        case kFilterReleaseTime:
            value = getFilterReleaseDurationSeconds() / 10.0f;
            break;
        case kLoopThruRelease:
            value = loopThruRelease ? 1.0f : 0.0f;
            break;
        case kMonophonic:
            value = isMonophonic ? 1.0f : 0.0f;
            break;
        case kLegato:
            value = isLegato ? 1.0f : 0.0f;
            break;
        case kGlideRate:
            value = glideRate / 10.0f;
            break;
    }
	return value;
}

float AKSamplerDSP::getParamValue(VstInt32 index)
{
    switch (index)
    {
    case kMasterVolume:
        return masterVolume;
    case kPitchBend:
        return pitchOffset;
    case kVibratoDepth:
        return vibratoDepth;
    case kFilterCutoff:
        return cutoffMultiple;
    case kKeyTracking:
        return keyTracking;
    case kFilterEgStrength:
        return cutoffEnvelopeStrength;
    case kFilterResonance:
        return -20.0f * log10(linearResonance);
    case kFilterEnable:
        return isFilterEnabled ? 1.0f : 0.0f;
    case kAmpAttackTime:
        return getADSRAttackDurationSeconds();
    case kAmpDecayTime:
        return getADSRDecayDurationSeconds();
    case kAmpSustainLevel:
        return getADSRSustainFraction();
    case kAmpReleaseTime:
        return getADSRReleaseDurationSeconds();
    case kFilterAttackTime:
        return getFilterAttackDurationSeconds();
    case kFilterDecayTime:
        return getFilterDecayDurationSeconds();
    case kFilterSustainLevel:
        return getFilterSustainFraction();
    case kFilterReleaseTime:
        return getFilterReleaseDurationSeconds();
    case kLoopThruRelease:
        return loopThruRelease ? 1.0f : 0.0f;
    case kMonophonic:
        return isMonophonic ? 1.0f : 0.0f;
    case kLegato:
        return isLegato ? 1.0f : 0.0f;
    case kGlideRate:
        return glideRate / 10.0f;
    }
    return 0.0f;
}

enum {
    kMidiNoteOff            = 0x80,
    kMidiNoteOn             = 0x90,
    kMidiPolyKeyPressure    = 0xA0,
    kMidiControlChange      = 0xB0,
    kMidiProgramChange      = 0xC0,
    kMidiChannelPressure    = 0xD0,
    kMidiPitchBend          = 0xE0
};

enum {
    kMidiCCModWheel         = 1,
    // lots more to add here...
    kMidiCCDamperPedal      = 64,
    // lots more to add here...
    kMidiCCAllSoundOff      = 120   // this or anything higher means all notes off
};

#define MIDI_NOTENUMBERS 128

VstInt32 AKSamplerDSP::processEvents (VstEvents* ev)
{
	for (VstInt32 i = 0; i < ev->numEvents; i++)
	{
		if ((ev->events[i])->type != kVstMidiType) continue;

		VstMidiEvent* event = (VstMidiEvent*)ev->events[i];
        char* md = event->midiData;
        unsigned channel = md[0] & 0x0F;     // this implementation ignores MIDI channel
        unsigned status = md[0] & 0xF0;
        unsigned data1 = md[1];
        unsigned data2 = md[2];
        //TRACE("MIDI ch%d st%02x %02x %02x\n", channel, status, data1, data2);

        switch (status)
        {
        case kMidiNoteOff:
            stopNote(data1, false);
            break;

        case kMidiNoteOn:
            if (data2 == 0) stopNote(data1, false);
            else
            {
                //TRACE("Play note %d vel %d\n", data1, data2);
                playNote(data1, data2, NOTE_HZ(data1));
            }
            break;

        case kMidiPolyKeyPressure:
            break;

        case kMidiControlChange:
            if (data1 == kMidiCCModWheel)
            {
                if (isFilterEnabled)
                    cutoffMultiple = 100.0f * data2 / 127.0f;
                else
                    vibratoDepth = 2.0f * data2 / 127.0f;
            }
            else if (data1 == kMidiCCDamperPedal)
            {
                bool pedalDown = data2 >= 64;
                sustainPedal(pedalDown);
            }
            else if (data1 >= kMidiCCAllSoundOff)
                for (unsigned nn = 0; nn < MIDI_NOTENUMBERS; nn++) stop(nn, true);
            break;

        case kMidiProgramChange:
            break;

        case kMidiChannelPressure:
            break;

        case kMidiPitchBend:
            pitchOffset = 2.0f * ((int)((data2 << 7) | data1) - 8192) / 8192.0f;
            break;
        }
	}
	return 1;
}

#define CHUNKSIZE 32

void AKSamplerDSP::processReplacing (float** inputs, float** outputs, VstInt32 nFrames)
{
    float *outBuffers[2];
    outBuffers[0] = outputs[0];
    outBuffers[1] = outputs[1];

    // Clear output buffers before adding anything (some hosts pass in dirty buffers)
    memset(outputs[0], 0, nFrames * sizeof(float));
    if (outputs[1]) memset(outputs[1], 0, nFrames * sizeof(float));

    for (int frameIndex = 0; frameIndex < nFrames; frameIndex += CHUNKSIZE)
    {
        int chunkSize = nFrames - frameIndex;
        if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;

        // Any ramping parameters would be updated here...

        AKCoreSampler::render(2, chunkSize, outBuffers);

        outBuffers[0] += CHUNKSIZE;
        outBuffers[1] += CHUNKSIZE;
    }
}
