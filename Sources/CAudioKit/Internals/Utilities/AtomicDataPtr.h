// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#ifndef AtomicData_hpp
#define AtomicData_hpp

#include <atomic>
#include <memory>
#include <vector>

/// This allows passing of large data to the audio thread atomically.
///
/// It takes ownership of the object.
template<class T>
class AtomicDataPtr {

public:

    /// Set to a new value. Takes ownership.
    ///
    /// This should ONLY be called on the main thread.
    /// Data no longer used by the audio thread is deallocated.
    void set(T* ptr) {
        auto holder = new _Holder;
        holder->data = std::unique_ptr<T>(ptr);
        _next = holder;
        _old.emplace_back(holder);
        _collect();
    }

    /// Update to new incoming data.
    ///
    /// Old data is marked as finished and cleaned up on the main thread.
    /// Call this once per render cycle on the audio thread.
    ///
    /// This should ONLY be called on the audio thread.
    void update() {
        _Holder* newData = _next;
        if(newData != _data) {
            if(_data) {
                _data->done = true;
            }

            _data = newData;
        }
    }

    /// Get the current pointer.
    ///
    /// This should ONLY be called on the audio thread.
    T* operator->() const {
        return _data->data.get();
    }

private:

    /// Use this so we don't require intrusiveness on T.
    struct _Holder {
        /// Is the audio thread done using this data?
        std::atomic<bool> done{false};

        /// Pointer to the data.
        std::unique_ptr<T> data;
    };

    std::atomic<_Holder*> _next{nullptr};
    std::vector< std::unique_ptr<_Holder> > _old;
    _Holder* _data{nullptr};

    void _collect() {
        // Start from the end. Once we find a finished
        // data, delete all data before and including.
        for (auto it = _old.end(); it > _old.begin();
             --it) {
            if ((*(it - 1))->done) {
                // Remove the data from the vector.
                _old.erase(_old.begin(), it);
                break;
            }
        }
    }
};

#endif /* AtomicData_hpp */
