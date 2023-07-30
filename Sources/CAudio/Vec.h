#include <vector>
#include <functional>

namespace AudioKit {

template <typename T>

class Vec {
private:
    std::vector<T> storage;
    
public:
    Vec(int count, std::function<T(int)> f) {
        storage.reserve(count);
        for(int i = 0; i < count; ++i)
            storage.push_back(f(i));
    }
    
    Vec(const std::vector<T>& array) {
        storage = array;
    }
    
    size_t count() const {
        return storage.size();
    }
    
    T& operator[](int index) {
        return storage[index];
    }
    
    const T& operator[](int index) const {
        return storage[index];
    }
    
    typename std::vector<T>::iterator begin() {
        return storage.begin();
    }
    
    typename std::vector<T>::iterator end() {
        return storage.end();
    }
};
} // namespace audiokit

