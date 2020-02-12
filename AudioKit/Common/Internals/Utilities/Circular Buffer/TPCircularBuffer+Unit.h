//
//  TPCircularBuffer+Unit.h
//
//  Created by David O'Neill, revision history on Github.
//  Copyright © 2017 O'Neill. All rights reserved.
//

#pragma once

#ifdef __cplusplus
extern "C++" {
#endif

#import "TPCircularBuffer.h"

/**
 * @brief Utilitiy functions for writing arbitrary sized values to a TPCircularBuffer.
 *
 * @discussion
 * TPCircularBufferUnitHead prepares the internal buffer using a header struct that store the
 * length and type, then returns a pointer to write to. TPCircularBufferUnitProduce
 * will advance the head by the length provided in the call to TPCircularBufferUnitHead plus
 * the length of the internal header struct.  TPCircularBufferUnitTail will return the first
 * pointer that was produced, and TPCircularBufferUnitConsume will consume it.  The type
 * arguments can be used to determine what kind of value is being written so that it can be
 * cast to the correct type when retrieved.  It is important to use TPCircularBufferUnitProduce
 * only after a call to TPCircularBufferUnitHead, and to use TPCircularBufferUnitTail to retrieve
 * values that were written using TPCircularBufferUnitHead/TPCircularBufferUnitProduce.
 * TPCircularBufferUnitConsume can be called without calling TPCircularBufferUnitTail.
*/

/**
 * @brief Returns a pointer for writing.
 *
 * @discussion Should be followed by a call to TPCircularBufferUnitProduce.
 *
 * @param buffer The circular buffer.
 * @param type A pointer to a flag that can be retrieved using TPCircularBufferUnitTail.  Can be NULL.
 * @param length the byteSize of the value that will be written to head.
 */
void *TPCircularBufferUnitHead(TPCircularBuffer *buffer, uint32_t *type, int length);

/**
 * @brief Moves buffer head forward by length specified in TPCircularBufferUnitHead.
 *
 * @discussion Must be proceeded by a call to TPCircularBufferUnitHead.
 *
 * @param buffer The circular buffer.
 */
void TPCircularBufferUnitProduce(TPCircularBuffer *buffer);

/**
 * @brief Returns a pointer for reading.
 *
 * @discussion Follow with TPCircularBufferUnitConsume to consume value read.
 *
 * @param buffer The circular buffer.
 * @param type On output, a flag that was set with TPCircularBufferUnitHead.  Can be NULL.
 * @param length On output, the byteSize of the value that was read. Can be NULL.
 */
void *TPCircularBufferUnitTail(TPCircularBuffer *buffer, uint32_t *type, int *length);

/**
 * @brief Consumes the next value in buffer.
 *
 * @discussion Does not have to be proceeded by TPCircularBufferUnitTail.
 *
 * @param buffer The circular buffer.
 */
void TPCircularBufferUnitConsume(TPCircularBuffer *buffer);

/**
 @code

    typedef struct {
        float x;
        float y;
    }PointStruct;

    typedef struct {
        char name[20];
        int age;
    }Person;

    TPCircularBuffer tpCircularBuffer;

    UInt32 pointType = 0;
    UInt32 personType = 1;
    UInt32 intsType = 2;

    TPCircularBufferInit(&tpCircularBuffer, 4096);


    Person jim = {
        .name = "Jimmy",
        .age = 123
    };

    void *head = TPCircularBufferUnitHead(&tpCircularBuffer, &personType, sizeof(jim));
    memcpy(head, &jim, sizeof(jim));
    TPCircularBufferUnitProduce(&tpCircularBuffer);

    PointStruct *pointHead = TPCircularBufferUnitHead(&tpCircularBuffer, &pointType, sizeof(PointStruct));
    pointHead->x = 12.34;
    pointHead->y = 56.789;
    TPCircularBufferUnitProduce(&tpCircularBuffer);

    int ints[7] = {8,6,7,5,3,0,9};
    head = TPCircularBufferUnitHead(&tpCircularBuffer, &intsType, sizeof(ints));
    memcpy(head, ints, sizeof(ints));
    TPCircularBufferUnitProduce(&tpCircularBuffer);

    PointStruct point = {.x = 543, .y = 0.321 };
    pointHead = TPCircularBufferUnitHead(&tpCircularBuffer, &pointType, sizeof(point));
    *pointHead = point;
    TPCircularBufferUnitProduce(&tpCircularBuffer);

    UInt32 type;
    int length;
    void *tail = TPCircularBufferUnitTail(&tpCircularBuffer, &type, &length);

    while (tail != NULL) {
        if (type == pointType) {
            PointStruct *point = tail;
            printf("point - { x: %.3f, y: %.3f }\n", point->x, point->y);
        }
        else if (type == personType ) {
            Person *person = tail;
            printf("person - { name: %s, age: %i }\n", person->name, person->age);
        }
        else if (type == intsType) {
            int *ints = tail;
            int count = length / sizeof(int);
            printf("ints - [");
            for (int i = 0; i < count; i++) {
                printf("%i",ints[i]);
                if (i != count - 1) printf(",");
                    }
            printf("]\n");
        }
        TPCircularBufferUnitConsume(&tpCircularBuffer);
        tail = TPCircularBufferUnitTail(&tpCircularBuffer, &type, &length);
    }
    TPCircularBufferCleanup(&tpCircularBuffer);

 @endCode
 */

#ifdef __cplusplus
}
#endif


