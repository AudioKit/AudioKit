//
//  ADSREnvelope.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#include "LinearRamper.hpp"
#include "FunctionTable.hpp"

namespace AudioKitCore
{

    // many ADSREnvelopes can share a common set of parameters
    struct ADSREnvelopeParams
    {
        float sampleRateHz;
        float attackSamples, decaySamples, releaseSamples;
        float sustainFraction;    // [0.0, 1.0]
        
        ADSREnvelopeParams();
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
    
    struct ADSREnvelope
    {
        ADSREnvelopeParams* pParams; // many ADSREnvelopes can share a common set of parameters
        
        LinearRamper ramper;
        
        enum EG_Segment
        {
            kIdle,
            kSilence,
            kAttack,
            kDecay,
            kSustain,
            kRelease
        } segment;
        
        void init();

        void start();       // called for note-on
        void restart();     // quickly dampen note then start again
        void release();     // called for note-off
        void reset();       // reset to idle state
        bool isIdle() { return segment == kIdle; }
        bool isPreStarting() { return segment == kSilence; }
        bool isReleasing() { return segment == kRelease; }

        inline float getSample()
        {
            if (segment == kIdle) { return 0.0f; }
            
            if (segment == kSustain) return pParams->sustainFraction;
            
            if (ramper.isRamping()) return float(ramper.getNextValue());

            if (segment == kSilence)    // end of quick-damp prior to restart
            {
                segment = kAttack;
                ramper.init(0.0f, 1.0, pParams->attackSamples);
                return 0.0f;
            }
            
            if (segment == kAttack)      // end of attack segment
            {
                segment = kDecay;
                ramper.init(1.0f, pParams->sustainFraction, pParams->decaySamples);
                return 1.0f;
            }
            
            if (segment == kDecay)  // end of decay segment
            {
                segment = kSustain;
                ramper.init(pParams->sustainFraction);
                return pParams->sustainFraction;
            }
            
            // end of release or silence segment
            segment = kIdle;
            ramper.init(0.0f);
            return 0.0f;
        }
    };
    
    struct UnityMappingWaveTable: public FunctionTable
    {
        float tbl[2];
        
        UnityMappingWaveTable()
        {
            tbl[0] = 0.0f;
            tbl[1] = 1.0f;
            pWaveTable = tbl;
        }
        ~UnityMappingWaveTable() { deinit(); }
        void deinit() { pWaveTable = 0; }
    };
    
    struct ShapedEnvelope: public ADSREnvelope
    {
        // Pointers to shape tables
        FunctionTable *pAttTbl, *pDecTbl, *pRelTbl;
        
        // For safety, all 3 pointers are initialized to point to this do-nothing table at first
        UnityMappingWaveTable nullTable;
        
        ShapedEnvelope()
        {
            // This ensures no null-pointer crashes in case user forgets to call initTables()
            pAttTbl = pDecTbl = pRelTbl = &nullTable;
        }
        
        void initTables(FunctionTable* pAttackTable, FunctionTable* pDecayTable, FunctionTable* pReleaseTable)
        {
            pAttTbl = pAttackTable; pDecTbl = pDecayTable; pRelTbl = pReleaseTable;
        }
        
        inline float getSample()
        {
            float x = ADSREnvelope::getSample();
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

}
