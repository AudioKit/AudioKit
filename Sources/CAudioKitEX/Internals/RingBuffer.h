// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#ifndef RingBuffer_hpp
#define RingBuffer_hpp

#include <atomic>
#include <cstddef> // size_t
#include <utility> // std::move

namespace AudioKit {

template <typename T> class RingBuffer {

  public:
    RingBuffer(size_t n = 1024)
        : ring_(new T[n]), head_(0), tail_(0), _size(n) {}

    ~RingBuffer() { delete[] ring_; }

    bool push(const T &value) {
        size_t head = head_.load(std::memory_order_relaxed);
        size_t next_head = next(head);
        if (next_head == tail_.load(std::memory_order_acquire))
            return false;
        ring_[head] = value;
        head_.store(next_head, std::memory_order_release);
        return true;
    }

    bool push(const T *array, size_t n) {
        const size_t head = head_.load(std::memory_order_relaxed);
        const size_t tail = tail_.load(std::memory_order_acquire);

        const size_t avail = write_available(head, tail);
        if (avail < n) {
            return false;
        }

        for (int i = 0; i < n; ++i) {
            ring_[(head + i) % _size] = array[i];
        }

        const size_t next_head = (head + n) % _size;
        head_.store(next_head, std::memory_order_release);
        return true;
    }

    bool pop(T *value) {
        size_t tail = tail_.load(std::memory_order_relaxed);
        if (tail == head_.load(std::memory_order_acquire))
            return false;

        // Move so the existing value is destroyed.
        *value = std::move(ring_[tail]);

        tail_.store(next(tail), std::memory_order_release);
        return true;
    }

    template <class F> size_t popAll(F f) {
        const size_t head = head_.load(std::memory_order_acquire);
        const size_t tail = tail_.load(std::memory_order_relaxed);

        const size_t avail = read_available(head, tail);

        for (size_t i = 0; i < avail; ++i) {
            f(std::move(ring_[(tail + i) % _size]));
        }

        const size_t next_tail = (tail + avail) % _size;
        tail_.store(next_tail, std::memory_order_release);

        return avail;
    }

  private:
    size_t next(size_t current) { return (current + 1) % _size; }

    size_t write_available(size_t head, size_t tail) const {
        size_t ret = tail - head - 1;
        if (head >= tail)
            ret += _size;
        return ret;
    }

    size_t read_available(size_t head, size_t tail) const {
        if (head >= tail)
            return head - tail;

        return head + _size - tail;
    }

    T *ring_;
    std::atomic<size_t> head_, tail_;
    size_t _size;
};

} // namespace AudioKit

#endif // RingBuffer_hpp
