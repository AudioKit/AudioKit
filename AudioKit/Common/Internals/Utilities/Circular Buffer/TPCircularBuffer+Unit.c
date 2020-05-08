// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "TPCircularBuffer+Unit.h"

typedef struct {
    int length;
    uint32_t type;
    char payload[1];
}GenericStruct;

void *TPCircularBufferUnitHead(TPCircularBuffer *buffer, uint32_t *type, int length) {
    int32_t availableBytes = 0;
    GenericStruct *head = TPCircularBufferHead(buffer, &availableBytes);
    if (offsetof(GenericStruct, payload) + length > availableBytes) {
        return NULL;
    }
    head->type = type ? *type : 0;
    head->length = length;
    return head->payload;
}

void TPCircularBufferUnitProduce(TPCircularBuffer *buffer) {
    int32_t availableBytes = 0;
    GenericStruct *head = TPCircularBufferHead(buffer, &availableBytes);
    if (head) {
        TPCircularBufferProduce(buffer, offsetof(GenericStruct, payload) + head->length);
    }
}
void *TPCircularBufferUnitTail(TPCircularBuffer *buffer, uint32_t *type, int *length) {
    int32_t availableBytes = 0;
    GenericStruct *tail = TPCircularBufferTail(buffer, &availableBytes);
    if (!tail) return NULL;
    if (type) *type = tail->type;
    if (length) *length = tail->length;
    return tail->payload;
}
void TPCircularBufferUnitConsume(TPCircularBuffer *buffer) {
    int32_t availableBytes;
    GenericStruct *tail = TPCircularBufferTail(buffer, &availableBytes);
    if (tail) {
        TPCircularBufferConsume(buffer, offsetof(GenericStruct, payload) + tail->length);
    }
}
