//
//  AKADSREnvelopeGenerator.hpp
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-02-20.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

#pragma once
#include "AKLinearRamper.hpp"
#include "AKFunctionTable.hpp"

// many AKADSREnvelopeGenerators can share a common set of parameters
struct AKADSREnvelopeGeneratorParams
{
    float sampleRateHz;
    float attackSamples, decaySamples, releaseSamples;
    float sustainFraction;    // [0.0, 1.0]

    AKADSREnvelopeGeneratorParams();
    void init(float newSampleRateHz, float attackSeconds, float decaySeconds, float susFraction, float releaseSeconds);
    void init(float attackSeconds, float decaySeconds, float susFraction, float releaseSeconds);
    void updateSampleRate(float newSampleRateHz);
    
    void setAttackTimeSeconds(float attackSeconds) { attackSamples = attackSeconds * sampleRateHz; }
    float getAttackTimeSeconds() { return attackSamples / sampleRateHz; }
    void setDecayTimeSeconds(float decaySeconds) { decaySamples = decaySeconds * sampleRateHz; }
    float getDecayTimeSeconds() { return decaySamples / sampleRateHz; }
    void setReleaseTimeSeconds(float releaseSeconds) { releaseSamples = releaseSeconds * sampleRateHz; }
    float getReleaseTimeSeconds() { return releaseSamples / sampleRateHz; }
};

struct AKADSREnvelopeGenerator
{
    AKADSREnvelopeGeneratorParams* pParams; // many AKADSREnvelopeGenerators can share a common set of parameters

    AKLinearRamper ramper;
    
    enum EG_Segment
    {
        kIdle,
        kAttack,
        kDecay,
        kSustain,
        kRelease
    } segment;
    
    void init();

    void start(bool reset=false);   // called for note-on
    void release();                 // called for note-off
    void reset();                   // reset to idle state
    bool isIdle() { return segment == kIdle; }

    inline float getSample()
    {
        if (segment == kIdle) return 0.0f;
        
        if (segment == kSustain) return pParams->sustainFraction;
        
        if (ramper.isRamping()) return float(ramper.getNextValue());
        
        if (segment == kAttack)      // end of attack segment
        {
            segment = kDecay;
            ramper.init(1.0f,pParams->sustainFraction, pParams->decaySamples);
            return 1.0;
        }
        
        if (segment == kDecay)  // end of decay segment
        {
            segment = kSustain;
            ramper.init(pParams->sustainFraction);
            return pParams->sustainFraction;
        }
        
        // end of release
        segment = kIdle;
        ramper.init(0.0f);
        return 0.0f;
    }
};

struct AKUnityMappingWaveTable: public AKFunctionTable
{
    float tbl[2];
    
    AKUnityMappingWaveTable()
    {
        tbl[0] = 0.0f;
        tbl[1] = 1.0f;
        pWaveTable = tbl;
    }
    ~AKUnityMappingWaveTable() { deinit(); }
    void deinit() { pWaveTable = 0; }
};

struct AKShapedEnvelopeGenerator: public AKADSREnvelopeGenerator
{
    // Pointers to shape tables
    AKFunctionTable *pAttTbl, *pDecTbl, *pRelTbl;
    
    // For safety, all 3 pointers are initialized to point to this do-nothing table at first
    AKUnityMappingWaveTable nullTable;
    
    AKShapedEnvelopeGenerator()
    {
        // This ensures no null-pointer crashes in case user forgets to call initTables()
        pAttTbl = pDecTbl = pRelTbl = &nullTable;
    }
    
    void initTables(AKFunctionTable* pAttackTable, AKFunctionTable* pDecayTable, AKFunctionTable* pReleaseTable)
    {
        pAttTbl = pAttackTable; pDecTbl = pDecayTable; pRelTbl = pReleaseTable;
    }
    
    inline float getSample()
    {
        float x = AKADSREnvelopeGenerator::getSample();
        switch (segment) {
            case kAttack:
                return pAttTbl->interp_bounded(x);
            case kDecay:
                return pDecTbl->interp_bounded(x);
            case kRelease:
                return pRelTbl->interp_bounded(x);
            default:
                break;
        }
        return x;
    }
};
