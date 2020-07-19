// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#ifndef DebugDSP_h
#define DebugDSP_h

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

void AKDebugDSPSetActive(bool active);
void AKDebugDSP(int slot, float value);
bool AKDebugDSPCheck(int slot, const char* expected);

#ifdef __cplusplus
}
#endif

#endif /* DebugDSP_h */
