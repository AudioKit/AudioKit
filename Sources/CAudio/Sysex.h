// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include <vector>
#include <cstdint>
#include <cassert>
#include <type_traits>
#include <AudioUnit/AudioUnit.h>



/// Encode a value in a MIDI sysex message. Value must be plain-old-data.
template<typename T>
std::vector<uint8_t> encodeSysex(T value) {
    // static_assert to check if T is POD at compile time.
    static_assert(std::is_pod<T>::value, "T must be plain-old-data");

    // Start with a sysex header.
    std::vector<uint8_t> result {0xF0, 0x00};

    // Encode the value as a sequence of nibbles.
    // There might be some more efficient way to do this,
    // but we can't clash with the 0xF7 end-of-message.
    // We may not actually need to encode a valid MIDI sysex
    // message, but that could be implementation dependent
    // and change over time. Best to be safe.
    uint8_t* value_ptr = reinterpret_cast<uint8_t*>(&value);
    for(size_t i = 0; i < sizeof(T); i++) {
        uint8_t byte = value_ptr[i];
        result.push_back(byte >> 4);
        result.push_back(byte & 0xF);
    }

    result.push_back(0xF7);
    return result;
}

/// Decode a sysex message into a value. Value must be plain-old-data.
///
/// We can't return a value because we can't assume the value can be
/// default constructed.
///
/// - Parameters:
///   - bytes: the sysex message
///   - count: number of bytes in message
///   - value: the value we're writing to
///
template<typename T>
void decodeSysex(const uint8_t* bytes, size_t count, T& value) {
    // static_assert to check if T is POD at compile time.
    static_assert(std::is_pod<T>::value, "T must be plain-old-data");

    assert(count == 2 * sizeof(T) + 3);

    uint8_t* value_ptr = reinterpret_cast<uint8_t*>(&value);
    for(size_t i = 0; i < sizeof(T); i++) {
        value_ptr[i] = (bytes[2 * i + 2] << 4) | bytes[2 * i + 3];
    }
}

/// Call a function with a pointer to the midi data in the AURenderEvent.
///
/// We need this function because event.pointee.MIDI.data is just a tuple of three midi bytes. This is
/// fine for simple midi messages like note on/off, but some messages are longer, so we need
/// access to the full array, which extends off the end of the structure (one of those variable-length C structs).
///
/// - Parameters:
///   - event: pointer to the AURenderEvent
///   - f: function to call

void withMidiData(const AUMIDIEvent* event, void (*f)(const uint8_t*)) {
    assert(event->eventType == AURenderEventMIDISysEx || event->eventType == AURenderEventMIDI);

    intptr_t offset = reinterpret_cast<intptr_t>(&(event->data)) - reinterpret_cast<intptr_t>(event);
    const uint8_t* raw = reinterpret_cast<const uint8_t*>(event) + offset;

    f(raw);
}


/// Decode a value from a sysex AURenderEvent.
///
/// We can't return a value because we can't assume the value can be
/// default constructed.
///
/// - Parameters:
///   - event: pointer to the AURenderEvent
///   - value: where we will store the value
template<typename T>
void decodeSysex(const AUMIDIEvent* event, T& value) {
    static_assert(std::is_trivial<T>::value && std::is_standard_layout<T>::value, "Type T must be POD");

    assert(event->eventType == AURenderEventMIDISysEx);

    uint16_t length = event->length;

    withMidiData(event, [&](const uint8_t* ptr) {
        decodeSysex(ptr, static_cast<int>(length), value);
    });
}


