//      _____ _____ _____ __
//     |   __|     |  |  |  |        Auto-generated C++
//     |__   |  |  |  |  |  |__      SOUL Version 0.9.0
//     |_____|_____|_____|_____|     https://soul.dev
//

#include <array>
#include <functional>
#include <cmath>
#include <cstddef>
#include <limits>
#include <cstring>

#ifndef SOUL_CPP_ASSERT
 #define SOUL_CPP_ASSERT(x)
#endif

// If you need to provide custom implementations of the instrinsics that soul uses,
// you can set this macro to provide your own namespace containing them.
#ifndef SOUL_INTRINSICS
 #define SOUL_INTRINSICS std
#endif

//==============================================================================
// Generated from graph 'Diode', source file: DiodeClipper.soul
//
class Diode
{
public:
    Diode() = default;
    ~Diode() = default;

    //==============================================================================
    template <typename Type, int32_t size> struct Vector;
    template <typename Type, int32_t size> struct FixedArray;
    template <typename Type> struct DynamicArray;

    static constexpr uint32_t maxBlockSize  = 1024;
    static constexpr uint32_t latency       = 0;

    template <typename Item>
    struct span
    {
        Item* start = nullptr;
        size_t numItems = 0;

        constexpr size_t size() const               { return numItems; }
        constexpr bool empty() const                { return numItems == 0; }
        constexpr Item* begin() const               { return start; }
        constexpr Item* end() const                 { return start + numItems; }
        const Item& operator[] (size_t index) const { SOUL_CPP_ASSERT (index < numItems); return start[index]; }
    };

    struct _RenderStats;
    struct _SparseStreamStatus;
    struct _Stream_in_f32_1024;
    struct _Event_in_f32_1;
    struct _Stream_out_f32_1024;
    struct DiodeClipper___SampleRateConverter_f32_4_filter;
    struct DiodeClipper___SampleRateConverter_f32_4;
    struct DiodeClipper___State;
    struct _State;
    struct DiodeClipper___IO;
    struct StringLiteral;

    //==============================================================================
    // The following methods provide basic initialisation and control for the processor

    void init (double newSampleRate, int sessionID)
    {
        memset (reinterpret_cast<void*> (std::addressof (state)), 0, sizeof (state));
        sampleRate = newSampleRate;
        _initialise (state, sessionID);
        initialisedState = state;
    }

    void reset() noexcept
    {
        state = initialisedState;
    }

    uint32_t getNumXRuns() noexcept
    {
        return static_cast<uint32_t> (_get_num_xruns (state));
    }

    //==============================================================================
    // These classes and functions provide a high-level rendering method that
    // presents the processor as a set of standard audio and MIDI channels.

    static constexpr uint32_t numAudioInputChannels  = 1;
    static constexpr uint32_t numAudioOutputChannels = 1;

    struct MIDIMessage
    {
        uint32_t frameIndex = 0;
        uint8_t byte0 = 0, byte1 = 0, byte2 = 0;
    };

    struct MIDIMessageArray
    {
        const MIDIMessage* messages = nullptr;
        uint32_t numMessages = 0;
    };

    template <typename FloatType = float>
    struct RenderContext
    {
        std::array<const FloatType*, 1> inputChannels;
        std::array<FloatType*, 1> outputChannels;
        MIDIMessageArray  incomingMIDI;
        uint32_t          numFrames = 0;
    };

    //==============================================================================
    template <typename FloatType>
    void render (RenderContext<FloatType> context)
    {
        uint32_t startFrame = 0;

        while (startFrame < context.numFrames)
        {
            auto framesRemaining = context.numFrames - startFrame;
            auto numFramesToDo = framesRemaining < maxBlockSize ? framesRemaining : maxBlockSize;
            prepare (numFramesToDo);

            copyToInterleaved (_getInputFrameArrayRef_audioIn (state).elements, &context.inputChannels[0], startFrame, numFramesToDo);

            advance();

            copyFromInterleaved (&context.outputChannels[0], startFrame, _getOutputFrameArrayRef_audioOut (state).elements, numFramesToDo);
            startFrame += numFramesToDo;
        }
    }

    //==============================================================================
    // The following methods provide low-level access for read/write to all the
    // endpoints directly, and to run the prepare/advance loop.

    void prepare (uint32_t numFramesToBeRendered)
    {
        SOUL_CPP_ASSERT (numFramesToBeRendered != 0);
        framesToAdvance = numFramesToBeRendered;
        _prepare (state, static_cast<int32_t> (numFramesToBeRendered));
    }

    void advance()
    {
        SOUL_CPP_ASSERT (framesToAdvance != 0); // you must call prepare() before advance()!
        auto framesRemaining = framesToAdvance;

        while (framesRemaining > 0)
        {
            auto framesThisCall = framesRemaining < maxBlockSize ? framesRemaining : maxBlockSize;

            run (state, static_cast<int32_t> (framesThisCall));

            totalFramesElapsed += framesThisCall;
            framesRemaining -= framesThisCall;
        }
    }

    void setNextInputStreamFrames_audioIn (const float* frames, uint32_t numFramesToUse)
    {
        auto& buffer = _getInputFrameArrayRef_audioIn (state);

        for (uint32_t i = 0; i < numFramesToUse; ++i)
            buffer[static_cast<int> (i)] = frames[i];
    }

    void setNextInputStreamSparseFrames_audioIn (float targetFrameValue, uint32_t numFramesToReachValue)
    {
        _setSparseInputTarget_audioIn (state, targetFrameValue, (int32_t) numFramesToReachValue);
    }

    void addInputEvent_cutoffFrequency (float eventValue)
    {
        _addInputEvent_cutoffFrequency_f32 (state, eventValue);
    }

    void addInputEvent_gaindB (float eventValue)
    {
        _addInputEvent_gaindB_f32 (state, eventValue);
    }

    DynamicArray<const float> getOutputStreamFrames_audioOut()
    {
        return { &(_getOutputFrameArrayRef_audioOut (state).elements[0]), static_cast<int32_t> (framesToAdvance) };
    }

    //==============================================================================
    // The following methods provide a fixed interface for finding out about
    // the input/output endpoints that this processor provides.

    using EndpointID = const char*;
    enum class EndpointType     { value, stream, event };

    struct EndpointDetails
    {
        const char* name;
        EndpointID endpointID;
        EndpointType endpointType;
        const char* frameType;
        uint32_t numAudioChannels;
        const char* annotation;
    };

    std::array<EndpointDetails, 3> getInputEndpoints() const
    {
        return
        {
            EndpointDetails { "audioIn",         "in:audioIn",         EndpointType::stream, "float32", 1, ""                                                                                     },
            EndpointDetails { "cutoffFrequency", "in:cutoffFrequency", EndpointType::event,  "float32", 0, "{ \"name\": \"Cutoff\", \"min\": 20, \"max\": 20000, \"init\": 10000, \"step\": 10 }" },
            EndpointDetails { "gaindB",          "in:gaindB",          EndpointType::event,  "float32", 0, "{ \"name\": \"Gain\", \"min\": 0, \"max\": 40, \"init\": 20, \"step\": 0.1 }"         }
        };
    }

    std::array<EndpointDetails, 1> getOutputEndpoints() const
    {
        return
        {
            EndpointDetails { "audioOut", "out:audioOut", EndpointType::stream, "float32", 1, "" }
        };
    }

    //==============================================================================
    // The following methods provide help in dealing with the processor's endpoints
    // in a format suitable for traditional audio plugin channels and parameters.

    struct ParameterProperties
    {
        const char* UID;
        const char* name;
        const char* unit;
        float minValue, maxValue, step, initialValue;
        bool isAutomatable, isBoolean, isHidden;
        const char* group;
        const char* textValues;
    };

    struct Parameter
    {
        ParameterProperties properties;
        float currentValue;
        std::function<void(float)> applyValue;

        void setValue (float f)
        {
            currentValue = snapToLegalValue (f);
            applyValue (f);
        }

        float getValue() const
        {
            return currentValue;
        }

    private:
        float snapToLegalValue (float v) const
        {
            if (properties.step > 0)
                v = properties.minValue + properties.step * SOUL_INTRINSICS::floor ((v - properties.minValue) / properties.step + 0.5f);

            return v < properties.minValue ? properties.minValue : (v > properties.maxValue ? properties.maxValue : v);
        }
    };

    struct AudioBus
    {
        const char* name;
        uint32_t numChannels;
    };

    static constexpr bool      hasMIDIInput = false;
    static constexpr uint32_t  numParameters = 2;

    static const std::array<const ParameterProperties, numParameters> parameters;

    static span<const ParameterProperties> getParameterProperties() { return { parameters.data(), numParameters }; }

    static constexpr uint32_t numInputBuses  = 1;
    static constexpr uint32_t numOutputBuses = 1;

    static constexpr std::array<const AudioBus, numInputBuses>  inputBuses = { AudioBus { "audioIn", 1 } };

    static constexpr std::array<const AudioBus, numOutputBuses> outputBuses = { AudioBus { "audioOut", 1 } };

    static span<const AudioBus> getInputBuses()  { return { inputBuses.data(), numInputBuses }; }
    static span<const AudioBus> getOutputBuses() { return { outputBuses.data(), numOutputBuses }; }

    struct ParameterList
    {
        Parameter* begin()                      { return params; }
        Parameter* end()                        { return params + numParameters; }
        size_t size() const                     { return numParameters; }
        Parameter& operator[] (size_t index)    { SOUL_CPP_ASSERT (index < numParameters); return params[index]; }

        Parameter params[numParameters == 0 ? 1 : numParameters];
    };

    ParameterList createParameterList()
    {
        return
        {
            {
                Parameter {  parameters[0],  10000.0f,  [this] (float v) { addInputEvent_cutoffFrequency (v); }  },
                Parameter {  parameters[1],  20.0f,     [this] (float v) { addInputEvent_gaindB (v); }           }
            }
        };
    }

    static constexpr bool hasTimelineEndpoints = false;

    void setTimeSignature (int32_t newNumerator, int32_t newDenominator)
    {
        (void) newNumerator; (void) newDenominator;
    }

    void setTempo (float newBPM)
    {
        (void) newBPM;
    }

    void setTransportState (int32_t newState)
    {
        (void) newState;
    }

    void setPosition (int64_t currentFrame, double currentQuarterNote, double lastBarStartQuarterNote)
    {
        (void) currentFrame; (void) currentQuarterNote; (void) lastBarStartQuarterNote;
    }

    //==============================================================================
    struct ZeroInitialiser
    {
        template <typename Type>   operator Type() const   { return {}; }
        template <typename Index>  ZeroInitialiser operator[] (Index) const { return {}; }
    };

    //==============================================================================
    template <typename Type>
    struct DynamicArray
    {
        using ElementType = Type;
        ElementType* elements = nullptr;
        int32_t numElements = 0;

        constexpr ElementType& operator[] (int i) noexcept                   { return elements[i]; }
        constexpr const ElementType& operator[] (int i) const noexcept       { return elements[i]; }
        constexpr int getElementSizeBytes() const noexcept                   { return sizeof (ElementType); }
    };

    //==============================================================================
    template <typename Type, int32_t size>
    struct FixedArray
    {
        using ElementType = Type;
        ElementType elements[size];
        static constexpr int32_t numElements = size;

        static constexpr FixedArray fromRepeatedValue (ElementType value)
        {
            FixedArray a;

            for (auto& element : a.elements)
                element = value;

            return a;
        }

        static size_t elementOffset (int i) noexcept               { return sizeof (ElementType) * i; }
        ElementType& operator[] (int i) noexcept                   { return elements[i]; }
        const ElementType& operator[] (int i) const noexcept       { return elements[i]; }
        int getElementSizeBytes() const noexcept                   { return sizeof (ElementType); }
        DynamicArray<ElementType> toDynamicArray() const noexcept  { return { const_cast<ElementType*> (&elements[0]), size }; }
        operator ElementType*() const noexcept                     { return const_cast<ElementType*> (&elements[0]); }

        FixedArray& operator= (ZeroInitialiser)
        {
            for (auto& e : elements)
                e = ElementType {};

            return *this;
        }

        template <int start, int end>
        constexpr FixedArray<Type, end - start> slice() const noexcept
        {
            FixedArray<Type, end - start> newSlice;

            for (int i = 0; i < end - start; ++i)
                newSlice.elements[i] = elements[start + i];

            return newSlice;
        }
    };

    //==============================================================================
    template <typename Type, int32_t size>
    struct Vector
    {
        using ElementType = Type;
        ElementType elements[size] = {};
        static constexpr int32_t numElements = size;

        constexpr Vector() = default;
        constexpr Vector (const Vector&) = default;
        constexpr Vector& operator= (const Vector&) = default;

        explicit constexpr Vector (Type value)
        {
            for (auto& element : elements)
                element = value;
        }

        template <typename OtherType>
        constexpr Vector (const Vector<OtherType, size>& other)
        {
            for (int32_t i = 0; i < size; ++i)
                elements[i] = static_cast<Type> (other.elements[i]);
        }

        constexpr Vector (std::initializer_list<Type> i)
        {
            int n = 0;

            for (auto e : i)
                elements[n++] = e;
        }

        static constexpr Vector fromRepeatedValue (Type value)
        {
            return Vector (value);
        }

        constexpr Vector operator+ (const Vector& rhs) const                { return apply<Vector> (rhs, [] (Type a, Type b) { return a + b; }); }
        constexpr Vector operator- (const Vector& rhs) const                { return apply<Vector> (rhs, [] (Type a, Type b) { return a - b; }); }
        constexpr Vector operator* (const Vector& rhs) const                { return apply<Vector> (rhs, [] (Type a, Type b) { return a * b; }); }
        constexpr Vector operator/ (const Vector& rhs) const                { return apply<Vector> (rhs, [] (Type a, Type b) { return a / b; }); }
        constexpr Vector operator% (const Vector& rhs) const                { return apply<Vector> (rhs, [] (Type a, Type b) { return a % b; }); }
        constexpr Vector operator-() const                                  { return apply<Vector> ([] (Type n) { return -n; }); }
        constexpr Vector operator~() const                                  { return apply<Vector> ([] (Type n) { return ~n; }); }
        constexpr Vector operator!() const                                  { return apply<Vector> ([] (Type n) { return ! n; }); }

        Vector& operator= (ZeroInitialiser)
        {
            for (auto& e : elements)
                e = {};

            return *this;
        }

        constexpr Vector<bool, size> operator== (const Vector& rhs) const   { return apply<Vector<bool, size>> (rhs, [] (Type a, Type b) { return a == b; }); }
        constexpr Vector<bool, size> operator!= (const Vector& rhs) const   { return apply<Vector<bool, size>> (rhs, [] (Type a, Type b) { return a != b; }); }

        template <typename ReturnType, typename Op>
        constexpr ReturnType apply (const Vector& rhs, Op&& op) const noexcept
        {
            ReturnType v;

            for (int i = 0; i < size; ++i)
                v.elements[i] = op (elements[i], rhs.elements[i]);

            return v;
        }

        template <typename ReturnType, typename Op>
        constexpr ReturnType apply (Op&& op) const noexcept
        {
            ReturnType v;

            for (int i = 0; i < size; ++i)
                v.elements[i] = op (elements[i]);

            return v;
        }

        template <int start, int end>
        constexpr Vector<Type, end - start> slice() const noexcept
        {
            Vector<Type, end - start> newSlice;

            for (int i = 0; i < end - start; ++i)
                newSlice.elements[i] = elements[start + i];

            return newSlice;
        }

        constexpr const Type& operator[] (int i) const noexcept  { return elements[i]; }
        constexpr Type& operator[] (int i) noexcept              { return elements[i]; }
    };

    //==============================================================================
    struct StringLiteral
    {
        constexpr StringLiteral (int32_t h) noexcept : handle (h) {}
        StringLiteral() = default;
        StringLiteral (const StringLiteral&) = default;
        StringLiteral& operator= (const StringLiteral&) = default;

        const char* toString() const       { return lookupStringLiteral (handle); }
        operator const char*() const       { return lookupStringLiteral (handle); }

        bool operator== (StringLiteral other) const noexcept    { return handle == other.handle; }
        bool operator!= (StringLiteral other) const noexcept    { return handle != other.handle; }

        int32_t handle = 0;
    };


    //==============================================================================
    //==============================================================================
    //
    //    All the code that follows this point should be considered internal.
    //    User code should rarely need to refer to anything beyond this point..
    //
    //==============================================================================
    //==============================================================================

    template <typename Vec>  static Vec _vec_sqrt  (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::sqrt (x); }); }
    template <typename Vec>  static Vec _vec_pow   (Vec a, Vec b)  { return a.template apply<Vec> ([&] (typename Vec::ElementType x) { return SOUL_INTRINSICS::pow (x, b); }); }
    template <typename Vec>  static Vec _vec_exp   (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::exp (x); }); }
    template <typename Vec>  static Vec _vec_log   (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::log (x); }); }
    template <typename Vec>  static Vec _vec_log10 (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::log10 (x); }); }
    template <typename Vec>  static Vec _vec_sin   (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::sin (x); }); }
    template <typename Vec>  static Vec _vec_cos   (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::cos (x); }); }
    template <typename Vec>  static Vec _vec_tan   (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::tan (x); }); }
    template <typename Vec>  static Vec _vec_sinh  (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::sinh (x); }); }
    template <typename Vec>  static Vec _vec_cosh  (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::cosh (x); }); }
    template <typename Vec>  static Vec _vec_tanh  (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::tanh (x); }); }
    template <typename Vec>  static Vec _vec_asinh (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::asinh (x); }); }
    template <typename Vec>  static Vec _vec_acosh (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::acosh (x); }); }
    template <typename Vec>  static Vec _vec_atanh (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::atanh (x); }); }
    template <typename Vec>  static Vec _vec_asin  (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::asin (x); }); }
    template <typename Vec>  static Vec _vec_acos  (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::acos (x); }); }
    template <typename Vec>  static Vec _vec_atan  (Vec a)         { return a.template apply<Vec> ([]  (typename Vec::ElementType x) { return SOUL_INTRINSICS::atan (x); }); }
    template <typename Vec>  static Vec _vec_atan2 (Vec a, Vec b)  { return a.template apply<Vec> ([&] (typename Vec::ElementType x) { return SOUL_INTRINSICS::atan2 (x, b); }); }

    static constexpr int32_t _intrin_clamp (int32_t n, int32_t low, int32_t high)  { return n < low ? low : (n > high ? high : n); }
    static constexpr int32_t _intrin_wrap (int32_t n, int32_t range)   { if (range == 0) return 0; auto x = n % range; return x < 0 ? x + range : x; }

    static constexpr float  _nan32 = std::numeric_limits<float>::quiet_NaN();
    static constexpr double _nan64 = std::numeric_limits<double>::quiet_NaN();

    static constexpr float  _inf32 = std::numeric_limits<float>::infinity();
    static constexpr double _inf64 = std::numeric_limits<double>::infinity();

    static constexpr float  _ninf32 = -_inf32;
    static constexpr double _ninf64 = -_inf64;

    template <typename SourceFloatType, typename DestFloatType>
    static inline void copyToInterleaved (DestFloatType* monoDest, const SourceFloatType* const* sourceChannels, uint32_t sourceStartFrame, uint32_t numFrames)
    {
        auto source = *sourceChannels + sourceStartFrame;

        for (uint32_t i = 0; i < numFrames; ++i)
            monoDest[i] = static_cast<DestFloatType> (source[i]);
    }

    template <typename SourceFloatType, typename DestFloatType, int32_t numChannels>
    static inline void copyToInterleaved (Vector<DestFloatType, numChannels>* vectorDest, const SourceFloatType* const* sourceChannels, uint32_t sourceStartFrame, uint32_t numFrames)
    {
        for (uint32_t i = 0; i < numFrames; ++i)
            for (uint32_t chan = 0; chan < static_cast<uint32_t> (numChannels); ++chan)
                vectorDest[i].elements[chan] = static_cast<DestFloatType> (sourceChannels[chan][sourceStartFrame + i]);
    }

    template <typename SourceFloatType, typename DestFloatType>
    static inline void copyFromInterleaved (DestFloatType* const* destChannels, uint32_t destStartFrame, const SourceFloatType* monoSource, uint32_t numFrames)
    {
        auto dest = *destChannels + destStartFrame;

        for (uint32_t i = 0; i < numFrames; ++i)
            dest[i] = static_cast<DestFloatType> (monoSource[i]);
    }

    template <typename SourceFloatType, typename DestFloatType, int32_t numChannels>
    static inline void copyFromInterleaved (DestFloatType* const* destChannels, uint32_t destStartFrame, const Vector<SourceFloatType, numChannels>* vectorSource, uint32_t numFrames)
    {
        for (uint32_t i = 0; i < numFrames; ++i)
            for (uint32_t chan = 0; chan < static_cast<uint32_t> (numChannels); ++chan)
                destChannels[chan][destStartFrame + i] = static_cast<DestFloatType> (vectorSource[i].elements[chan]);
    }

    //==============================================================================
    struct _RenderStats
    {
        int32_t m_underrunCount, m_underrunFrames, m_overrunCount, m_overrunFrames;
    };

    struct _SparseStreamStatus
    {
        int32_t m_activeRamps;
        FixedArray<int32_t, 3> m_rampArray;
    };

    struct _Stream_in_f32_1024
    {
        FixedArray<float, 1024> m_buffer;
        float m_currentSparseValue, m_targetSparseValue, m_perFrameIncrement;
        int32_t m_numSparseFramesToRender, m_constantFilledFrames;
        bool m_sparseStreamActive;
    };

    struct _Event_in_f32_1
    {
        int32_t m_numFrames;
    };

    struct _Stream_out_f32_1024
    {
        FixedArray<float, 1024> m_buffer;
    };

    struct DiodeClipper___SampleRateConverter_f32_4_filter
    {
        float m_in;
        FixedArray<float, 3> m_out;
    };

    struct DiodeClipper___SampleRateConverter_f32_4
    {
        FixedArray<float, 4> m_buffer;
        int32_t m_bufferPos;
        FixedArray<DiodeClipper___SampleRateConverter_f32_4_filter, 2> m_filterA, m_filterB;
    };

    struct DiodeClipper___State
    {
        int32_t m__resumePoint, m__frameCount, m__arrayEntry, m__sessionID, m__processorId;
        float m_cutoffFrequency, m_gaindB, m_G, m_gain;
        int32_t m_counter_1;
        double m_deltaLim, m_out;
        float m_s1;
        DiodeClipper___SampleRateConverter_f32_4 m__audioIn_src, m__audioOut_src;
    };

    struct _State
    {
        int32_t m__resumePoint, m__frameCount, m__arrayEntry, m__sessionID, m__processorId, m__framesToAdvance;
        _RenderStats m__renderStats;
        _SparseStreamStatus m__sparseStreamStatus;
        _Stream_in_f32_1024 m__in_audioIn;
        _Event_in_f32_1 m__in_cutoffFrequency, m__in_gaindB;
        _Stream_out_f32_1024 m__out_audioOut;
        DiodeClipper___State m_diodeClipper_state;
    };

    struct DiodeClipper___IO
    {
        float m__in_audioIn, m__out_audioOut;
    };

    //==============================================================================
    #if __clang__
     #pragma clang diagnostic push
     #pragma clang diagnostic ignored "-Wunused-label"
     #pragma clang diagnostic ignored "-Wunused-parameter"
     #pragma clang diagnostic ignored "-Wshadow"
    #elif defined(__GNUC__)
     #pragma GCC diagnostic push
     #pragma GCC diagnostic ignored "-Wunused-label"
     #pragma GCC diagnostic ignored "-Wunused-parameter"
     #pragma GCC diagnostic ignored "-Wshadow"
    #elif defined(_MSC_VER)
     #pragma warning (push)
     #pragma warning (disable: 4100 4102 4458)
    #endif

    //==============================================================================
    int32_t run (_State& _state, int32_t maxFrames) noexcept
    {
        int32_t _2 = {};
        float _3 = {};
        DiodeClipper___IO _4 = {};

        _2 = _internal___minInt32 (1024, maxFrames);
        _updateRampingStreams (_state, _2);
        _state.m__frameCount = 0;
        _main_loop_check: { if (! (_state.m__frameCount < _2)) goto _exit; }
        _main_loop_body: { _3 = _readFromStream_struct__Stream_in_f32_1024 (_state.m__in_audioIn, _state.m__frameCount);
                           _4 = ZeroInitialiser();
                           _4.m__in_audioIn = _3;
                           DiodeClipper___run_oversampled (_state.m_diodeClipper_state, _4);
                           _writeToStream_struct__Stream_out_f32_1024 (_state.m__out_audioOut, _state.m__frameCount, _4.m__out_audioOut);
                           _state.m__frameCount = _state.m__frameCount + 1;
                           goto _main_loop_check;
        }
        _exit: { _state.m__frameCount = 0;
                 return _2;
        }
    }

    void _initialise (_State& _state, int32_t sessionID) noexcept
    {
        _state.m__sessionID = sessionID;
        _state.m_diodeClipper_state.m__arrayEntry = 0;
        _state.m_diodeClipper_state.m__sessionID = _state.m__sessionID;
        _state.m_diodeClipper_state.m__processorId = 1;
        DiodeClipper___initialise (_state.m_diodeClipper_state);
    }

    void _addInputEvent_cutoffFrequency_f32 (_State& _state, const float& event) noexcept
    {
        DiodeClipper___cutoffFrequencyIn_f32 (_state.m_diodeClipper_state, event);
    }

    void _addInputEvent_gaindB_f32 (_State& _state, const float& event) noexcept
    {
        DiodeClipper___gaindBIn_f32 (_state.m_diodeClipper_state, event);
    }

    FixedArray<float, 1024>& _getInputFrameArrayRef_audioIn (_State& _state) noexcept
    {
        return _state.m__in_audioIn.m_buffer;
    }

    void _setSparseStream_struct__Stream_in_f32_1024 (_Stream_in_f32_1024& streamState, const float& targetValue, int32_t framesToReachTarget) noexcept
    {
        float rampFrames = {}, delta = {};

        if (! (framesToReachTarget == 0)) goto _ramp;
        _no_ramp: { streamState.m_currentSparseValue = targetValue;
                    streamState.m_targetSparseValue = targetValue;
                    streamState.m_perFrameIncrement = 0;
                    streamState.m_numSparseFramesToRender = 0;
                    streamState.m_constantFilledFrames = 0;
                    streamState.m_sparseStreamActive = true;
                    return;
        }
        _ramp: { rampFrames = static_cast<float> (framesToReachTarget);
                 delta = static_cast<float> (targetValue - streamState.m_currentSparseValue);
                 streamState.m_targetSparseValue = targetValue;
                 streamState.m_perFrameIncrement = delta / rampFrames;
                 streamState.m_numSparseFramesToRender = framesToReachTarget;
                 streamState.m_constantFilledFrames = 0;
                 streamState.m_sparseStreamActive = true;
        }
    }

    void _setSparseInputTarget_audioIn (_State& _state, const float& targetValue, int32_t framesToReachTarget) noexcept
    {
        if (_state.m__in_audioIn.m_sparseStreamActive) goto _block_1;
        _block_0: { _addRampingStream (_state.m__sparseStreamStatus, 0); }
        _block_1: { _setSparseStream_struct__Stream_in_f32_1024 (_state.m__in_audioIn, targetValue, framesToReachTarget); }
    }

    FixedArray<float, 1024>& _getOutputFrameArrayRef_audioOut (_State& state) noexcept
    {
        return state.m__out_audioOut.m_buffer;
    }

    void _prepare (_State& state, int32_t frames) noexcept
    {
        state.m__framesToAdvance = frames;
    }

    int32_t _get_num_xruns (_State& state) noexcept
    {
        return state.m__renderStats.m_underrunCount + state.m__renderStats.m_overrunCount;
    }

    //==============================================================================
    void _renderSparseFrames_struct__Stream_in_f32_1024 (_Stream_in_f32_1024& stream, int32_t startFrame, int32_t framesToGenerate) noexcept
    {
        int32_t writePos = {};
        float currentValue = {};

        writePos = startFrame;
        currentValue = stream.m_currentSparseValue;
        _main_loop_check: { if (! (framesToGenerate > 0)) goto _exit_after_loop; }
        _main_loop_body: { stream.m_buffer[writePos] = currentValue;
                           currentValue = currentValue + stream.m_perFrameIncrement;
                           writePos = writePos + 1;
                           framesToGenerate = framesToGenerate - 1;
                           goto _main_loop_check;
        }
        _exit_after_loop: { stream.m_currentSparseValue = currentValue; }
    }

    bool _applySparseStreamData_struct__Stream_in_f32_1024 (_Stream_in_f32_1024& stream, int32_t numFrames) noexcept
    {
        int32_t rampFrames = {};

        rampFrames = 0;
        if (! (stream.m_sparseStreamActive == true)) goto _exitTrue;
        _check_stream_state: { if (! (stream.m_numSparseFramesToRender == 0)) goto _render_ramp; }
        _no_frames_to_render: { if (stream.m_constantFilledFrames == 1024) goto _rampComplete; }
        _add_fixed_value: { stream.m_currentSparseValue = stream.m_targetSparseValue;
                            stream.m_perFrameIncrement = 0;
                            _renderSparseFrames_struct__Stream_in_f32_1024 (stream, stream.m_constantFilledFrames, _internal___minInt32 (numFrames, 1024 - stream.m_constantFilledFrames));
                            stream.m_constantFilledFrames = stream.m_constantFilledFrames + _internal___minInt32 (numFrames, 1024 - stream.m_constantFilledFrames);
                            goto _exit;
        }
        _render_ramp: { rampFrames = _internal___minInt32 (numFrames, stream.m_numSparseFramesToRender);
                        _renderSparseFrames_struct__Stream_in_f32_1024 (stream, 0, rampFrames);
                        stream.m_numSparseFramesToRender = stream.m_numSparseFramesToRender - rampFrames;
                        if (rampFrames == numFrames) goto _exit;
        }
        _fill_remainder: { stream.m_currentSparseValue = stream.m_targetSparseValue;
                           stream.m_perFrameIncrement = 0;
                           _renderSparseFrames_struct__Stream_in_f32_1024 (stream, rampFrames, numFrames - rampFrames);
        }
        _exit: { return false; }
        _exitTrue: { return true; }
        _rampComplete: { stream.m_sparseStreamActive = false;
                         return true;
        }
    }

    void _addRampingStream (_SparseStreamStatus& status, int32_t streamId) noexcept
    {
        status.m_rampArray[status.m_activeRamps] = streamId;
        status.m_activeRamps = status.m_activeRamps + 1;
    }

    bool _updateRampingStream (_State& _state, int32_t streamId, int32_t framesToRender) noexcept
    {
        bool rampComplete = {};

        rampComplete = false;
        if (! (streamId == 0)) goto _exit;
        _case_0: { rampComplete = _applySparseStreamData_struct__Stream_in_f32_1024 (_state.m__in_audioIn, framesToRender); }
        _exit: { return rampComplete; }
    }

    void _updateRampingStreams (_State& _state, int32_t framesToRender) noexcept
    {
        bool rampComplete = {};
        int32_t readPos = {}, writePos = {};

        rampComplete = false;
        readPos = 0;
        writePos = 0;
        if (_state.m__sparseStreamStatus.m_activeRamps == 0) goto _exit;
        _loop: { rampComplete = _updateRampingStream (_state, _state.m__sparseStreamStatus.m_rampArray[readPos], framesToRender);
                 if (rampComplete) goto _rampComplete;
        }
        _rampActive: { _state.m__sparseStreamStatus.m_rampArray[writePos] = _state.m__sparseStreamStatus.m_rampArray[readPos];
                       readPos = readPos + 1;
                       writePos = writePos + 1;
                       if (readPos == _state.m__sparseStreamStatus.m_activeRamps) goto _loopExit;
                       goto _loop;
        }
        _rampComplete: { readPos = readPos + 1;
                         if (! (readPos == _state.m__sparseStreamStatus.m_activeRamps)) goto _loop;
        }
        _loopExit: { _state.m__sparseStreamStatus.m_activeRamps = writePos; }
        _exit: {}
    }

    float _readFromStream_struct__Stream_in_f32_1024 (const _Stream_in_f32_1024& stream, int32_t readPos) noexcept
    {
        float _2 = {};

        _2 = stream.m_buffer[readPos];
        return _2;
    }

    void _writeToStream_struct__Stream_out_f32_1024 (_Stream_out_f32_1024& stream, int32_t writePos, float value) noexcept
    {
        stream.m_buffer[writePos] = value;
    }

    //==============================================================================
    float soul__dBtoGain (float decibels) noexcept
    {
        float _2 = {}, _3 = {}, _4 = {}, _T0 = {};

        if (! (decibels > -100.0f)) goto _ternary_false_0;
        _ternary_true_0: { _2 = SOUL_INTRINSICS::pow (10.0f, decibels * 0.05f);
                           _T0 = _2;
                           goto _ternary_end_0;
        }
        _ternary_false_0: { _3 = 0;
                            _T0 = _3;
        }
        _ternary_end_0: { _4 = _T0;
                          return _4;
        }
    }

    //==============================================================================
    float soul__intrinsics___pow_specialised (float a, float b) noexcept
    {
        return 0;
    }

    double soul__intrinsics___log_specialised_2 (double n) noexcept
    {
        return 0;
    }

    float soul__intrinsics___sin_specialised (float n) noexcept
    {
        return 0;
    }

    double soul__intrinsics___sqrt_specialised (double n) noexcept
    {
        return 0;
    }

    double soul__intrinsics___acosh_specialised (double n) noexcept
    {
        double _2 = {}, _3 = {};

        _2 = SOUL_INTRINSICS::sqrt ((n * n) - 1.0);
        _3 = SOUL_INTRINSICS::log (n + _2);
        return _3;
    }

    double soul__intrinsics___abs_specialised (double n) noexcept
    {
        double _2 = {}, _3 = {}, _4 = {}, _T0 = {};

        if (! (n < 0)) goto _ternary_false_0;
        _ternary_true_0: { _2 = -n;
                           _T0 = _2;
                           goto _ternary_end_0;
        }
        _ternary_false_0: { _3 = n;
                            _T0 = _3;
        }
        _ternary_end_0: { _4 = _T0;
                          return _4;
        }
    }

    double soul__intrinsics___sinh_specialised (double n) noexcept
    {
        double _2 = {}, _3 = {};

        _2 = SOUL_INTRINSICS::exp (n);
        _3 = SOUL_INTRINSICS::exp (-n);
        return (_2 - _3) / 2.0;
    }

    double soul__intrinsics___cosh_specialised (double n) noexcept
    {
        double _2 = {}, _3 = {};

        _2 = SOUL_INTRINSICS::exp (n);
        _3 = SOUL_INTRINSICS::exp (-n);
        return (_2 + _3) / 2.0;
    }

    float soul__intrinsics___clamp_specialised (float n, float low, float high) noexcept
    {
        float _2 = {}, _3 = {}, _4 = {}, _5 = {}, _6 = {}, _T1 = {}, _T0 = {};

        if (! (n < low)) goto _ternary_false_0;
        _ternary_true_0: { _2 = low;
                           _T0 = _2;
                           goto _ternary_end_0;
        }
        _ternary_false_0: { if (! (n > high)) goto _ternary_false_1; }
        _ternary_true_1: { _3 = high;
                           _T1 = _3;
                           goto _ternary_end_1;
        }
        _ternary_false_1: { _4 = n;
                            _T1 = _4;
        }
        _ternary_end_1: { _5 = _T1;
                          _T0 = _5;
        }
        _ternary_end_0: { _6 = _T0;
                          return _6;
        }
    }

    double soul__intrinsics___exp_specialised (double n) noexcept
    {
        return 0;
    }

    double soul__intrinsics___clamp_specialised_2 (double n, double low, double high) noexcept
    {
        double _2 = {}, _3 = {}, _4 = {}, _5 = {}, _6 = {}, _T1 = {}, _T0 = {};

        if (! (n < low)) goto _ternary_false_0;
        _ternary_true_0: { _2 = low;
                           _T0 = _2;
                           goto _ternary_end_0;
        }
        _ternary_false_0: { if (! (n > high)) goto _ternary_false_1; }
        _ternary_true_1: { _3 = high;
                           _T1 = _3;
                           goto _ternary_end_1;
        }
        _ternary_false_1: { _4 = n;
                            _T1 = _4;
        }
        _ternary_end_1: { _5 = _T1;
                          _T0 = _5;
        }
        _ternary_end_0: { _6 = _T0;
                          return _6;
        }
    }

    float soul__intrinsics___tan_specialised (float n) noexcept
    {
        float _2 = {}, _3 = {};

        _2 = SOUL_INTRINSICS::sin (n);
        _3 = SOUL_INTRINSICS::cos (n);
        return _2 / _3;
    }

    float soul__intrinsics___cos_specialised (float n) noexcept
    {
        return 0;
    }

    //==============================================================================
    void DiodeClipper___cutoffFrequencyIn_f32 (DiodeClipper___State& _state, float f) noexcept
    {
        _state.m_cutoffFrequency = f;
    }

    void DiodeClipper___gaindBIn_f32 (DiodeClipper___State& _state, float f) noexcept
    {
        _state.m_gaindB = f;
    }

    void DiodeClipper__run (DiodeClipper___State& _state, DiodeClipper___IO& _io) noexcept
    {
        float out_value_audioOut = {}, _2 = {};
        int32_t _resumePoint = {};
        double _3 = {}, delta = {}, _4 = {}, _5 = {}, _6 = {}, _7 = {};
        float in = {}, p = {}, v = {};
        int32_t counter_2 = {};
        double J = {}, dJ = {};

        out_value_audioOut = 0;
        _resumePoint = _state.m__resumePoint;
        if (_resumePoint == 1) goto _resume_point_1;
        _block_0: { _state.m_s1 = 0;
                    _state.m_out = 0;
        }
        _body_0: { DiodeClipper__updateFilterVariables (_state);
                   _3 = SOUL_INTRINSICS::acosh (static_cast<double> (0.022775999999999999 / (0.000005544 * static_cast<double> (_state.m_G))));
                   _state.m_deltaLim = static_cast<double> (0.045551999999999998 * _3);
                   _state.m_counter_1 = 8;
        }
        _loop_1: { if (! (_state.m_counter_1 > 0)) goto _body_0; }
        _body_1: { _2 = _io.m__in_audioIn;
                   in = static_cast<float> (_2 * _state.m_gain);
                   p = static_cast<float> ((_state.m_G * static_cast<float> (in - static_cast<float> (_state.m_s1))) + _state.m_s1);
                   delta = 1000000000.0;
                   counter_2 = 64;
        }
        _loop_2: { if (! (counter_2 > 0)) goto _break_2; }
        _body_2: { _4 = soul__intrinsics___abs_specialised (delta);
                   if (_4 <= 1e-12) goto _break_2;
        }
        _ifnot_0: { _5 = SOUL_INTRINSICS::sinh (_state.m_out / 0.045551999999999998);
                    J = (static_cast<double> (p) - (((static_cast<double> (2.0f * _state.m_G) * 2200.0) * 2.52e-9) * static_cast<double> (_5))) - static_cast<double> (_state.m_out);
                    _6 = SOUL_INTRINSICS::cosh (_state.m_out / 0.045551999999999998);
                    dJ = -1.0 - ((((static_cast<double> (_state.m_G * 2.0f) * 2200.0) * 2.52e-9) / 0.045551999999999998) * static_cast<double> (_6));
                    _7 = soul__intrinsics___clamp_specialised_2 (static_cast<double> ((-J) / dJ), static_cast<double> (-_state.m_deltaLim), static_cast<double> (_state.m_deltaLim));
                    delta = _7;
                    _state.m_out = _state.m_out + delta;
                    counter_2 = counter_2 - 1;
                    goto _loop_2;
        }
        _break_2: { v = static_cast<float> (static_cast<float> (_state.m_out) - _state.m_s1);
                    _state.m_s1 = static_cast<float> (_state.m_out) + static_cast<float> (v);
                    out_value_audioOut = out_value_audioOut + static_cast<float> (_state.m_out);
                    _state.m__resumePoint = 1;
                    _io.m__out_audioOut = out_value_audioOut;
                    return;
        }
        _resume_point_1: { _state.m_counter_1 = _state.m_counter_1 - 1;
                           goto _loop_1;
        }
    }

    void DiodeClipper__updateFilterVariables (DiodeClipper___State& _state) noexcept
    {
        float _2 = {}, _3 = {}, _4 = {};
        float cutoff = {}, g = {};

        _2 = soul__intrinsics___clamp_specialised (_state.m_cutoffFrequency, 10.0f, static_cast<float> ((sampleRate * 4.0)) * 0.49999f);
        cutoff = static_cast<float> (_2);
        _3 = SOUL_INTRINSICS::tan ((3.1415927f * static_cast<float> (cutoff)) / static_cast<float> ((sampleRate * 4.0)));
        g = static_cast<float> (_3);
        _state.m_G = static_cast<float> (g / (1.0f + g));
        _4 = soul__dBtoGain (_state.m_gaindB);
        _state.m_gain = _4;
    }

    void DiodeClipper___initialise (DiodeClipper___State& _state) noexcept
    {
        _state.m_cutoffFrequency = 10000.0f;
        _state.m_gaindB = 40.0f;
        _state.m_G = 0;
        _state.m_gain = 0;
    }

    void DiodeClipper___run_oversampled (DiodeClipper___State& _state, DiodeClipper___IO& _io) noexcept
    {
        DiodeClipper___upsamplerWrite (_state.m__audioIn_src, _io.m__in_audioIn);
        DiodeClipper___upsamplerRead (_state.m__audioIn_src, _io.m__in_audioIn);
        DiodeClipper__run (_state, _io);
        DiodeClipper___downsamplerWrite (_state.m__audioOut_src, _io.m__out_audioOut);
        DiodeClipper___upsamplerRead (_state.m__audioIn_src, _io.m__in_audioIn);
        DiodeClipper__run (_state, _io);
        DiodeClipper___downsamplerWrite (_state.m__audioOut_src, _io.m__out_audioOut);
        DiodeClipper___upsamplerRead (_state.m__audioIn_src, _io.m__in_audioIn);
        DiodeClipper__run (_state, _io);
        DiodeClipper___downsamplerWrite (_state.m__audioOut_src, _io.m__out_audioOut);
        DiodeClipper___upsamplerRead (_state.m__audioIn_src, _io.m__in_audioIn);
        DiodeClipper__run (_state, _io);
        DiodeClipper___downsamplerWrite (_state.m__audioOut_src, _io.m__out_audioOut);
        DiodeClipper___downsamplerRead (_state.m__audioOut_src, _io.m__out_audioOut);
    }

    void DiodeClipper___upsamplerWrite (DiodeClipper___SampleRateConverter_f32_4& src, float input) noexcept
    {
        float _2 = {}, _3 = {}, _4 = {}, _5 = {}, _6 = {}, _7 = {}, _8 = {}, _9 = {}, _10 = {}, _11 = {}, _12 = {}, _13 = {}, _14 = {}, _15 = {}, _16 = {}, _17 = {}, _18 = {}, _19 = {};

        _2 = src.m_filterA[0].m_in + ((input - src.m_filterA[0].m_out[0]) * 0.039151598f);
        _3 = src.m_filterA[0].m_out[0] + ((_2 - src.m_filterA[0].m_out[1]) * 0.30264685f);
        _4 = src.m_filterA[0].m_out[1] + ((_3 - src.m_filterA[0].m_out[2]) * 0.6746159f);
        src.m_filterA[0].m_in = input;
        src.m_filterA[0].m_out[0] = _2;
        src.m_filterA[0].m_out[1] = _3;
        src.m_filterA[0].m_out[2] = _4;
        _5 = src.m_filterB[0].m_in + ((input - src.m_filterB[0].m_out[0]) * 0.14737712f);
        _6 = src.m_filterB[0].m_out[0] + ((_5 - src.m_filterB[0].m_out[1]) * 0.48246855f);
        _7 = src.m_filterB[0].m_out[1] + ((_6 - src.m_filterB[0].m_out[2]) * 0.883005f);
        src.m_filterB[0].m_in = input;
        src.m_filterB[0].m_out[0] = _5;
        src.m_filterB[0].m_out[1] = _6;
        src.m_filterB[0].m_out[2] = _7;
        _8 = src.m_filterA[1].m_in + ((_4 - src.m_filterA[1].m_out[0]) * 0.039151598f);
        _9 = src.m_filterA[1].m_out[0] + ((_8 - src.m_filterA[1].m_out[1]) * 0.30264685f);
        _10 = src.m_filterA[1].m_out[1] + ((_9 - src.m_filterA[1].m_out[2]) * 0.6746159f);
        src.m_filterA[1].m_in = _4;
        src.m_filterA[1].m_out[0] = _8;
        src.m_filterA[1].m_out[1] = _9;
        src.m_filterA[1].m_out[2] = _10;
        src.m_buffer[0] = _10;
        _11 = src.m_filterB[1].m_in + ((_4 - src.m_filterB[1].m_out[0]) * 0.14737712f);
        _12 = src.m_filterB[1].m_out[0] + ((_11 - src.m_filterB[1].m_out[1]) * 0.48246855f);
        _13 = src.m_filterB[1].m_out[1] + ((_12 - src.m_filterB[1].m_out[2]) * 0.883005f);
        src.m_filterB[1].m_in = _4;
        src.m_filterB[1].m_out[0] = _11;
        src.m_filterB[1].m_out[1] = _12;
        src.m_filterB[1].m_out[2] = _13;
        src.m_buffer[1] = _13;
        _14 = src.m_filterA[1].m_in + ((_7 - src.m_filterA[1].m_out[0]) * 0.039151598f);
        _15 = src.m_filterA[1].m_out[0] + ((_14 - src.m_filterA[1].m_out[1]) * 0.30264685f);
        _16 = src.m_filterA[1].m_out[1] + ((_15 - src.m_filterA[1].m_out[2]) * 0.6746159f);
        src.m_filterA[1].m_in = _7;
        src.m_filterA[1].m_out[0] = _14;
        src.m_filterA[1].m_out[1] = _15;
        src.m_filterA[1].m_out[2] = _16;
        src.m_buffer[2] = _16;
        _17 = src.m_filterB[1].m_in + ((_7 - src.m_filterB[1].m_out[0]) * 0.14737712f);
        _18 = src.m_filterB[1].m_out[0] + ((_17 - src.m_filterB[1].m_out[1]) * 0.48246855f);
        _19 = src.m_filterB[1].m_out[1] + ((_18 - src.m_filterB[1].m_out[2]) * 0.883005f);
        src.m_filterB[1].m_in = _7;
        src.m_filterB[1].m_out[0] = _17;
        src.m_filterB[1].m_out[1] = _18;
        src.m_filterB[1].m_out[2] = _19;
        src.m_buffer[3] = _19;
        src.m_bufferPos = 0;
    }

    void DiodeClipper___upsamplerRead (DiodeClipper___SampleRateConverter_f32_4& state, float& value) noexcept
    {
        value = state.m_buffer[state.m_bufferPos];
        state.m_bufferPos = state.m_bufferPos + 1;
    }

    void DiodeClipper___downsamplerWrite (DiodeClipper___SampleRateConverter_f32_4& state, float value) noexcept
    {
        state.m_buffer[state.m_bufferPos] = value;
        state.m_bufferPos = state.m_bufferPos + 1;
    }

    void DiodeClipper___downsamplerRead (DiodeClipper___SampleRateConverter_f32_4& src, float& output) noexcept
    {
        float _2 = {}, _3 = {}, _4 = {}, _5 = {}, _6 = {}, _7 = {}, _8 = {}, _9 = {}, _10 = {}, _11 = {}, _12 = {}, _13 = {}, _14 = {}, _15 = {}, _16 = {}, _17 = {}, _18 = {}, _19 = {}, _20 = {}, _21 = {};

        _2 = src.m_filterA[0].m_in + ((src.m_buffer[1] - src.m_filterA[0].m_out[0]) * 0.039151598f);
        _3 = src.m_filterA[0].m_out[0] + ((_2 - src.m_filterA[0].m_out[1]) * 0.30264685f);
        _4 = src.m_filterA[0].m_out[1] + ((_3 - src.m_filterA[0].m_out[2]) * 0.6746159f);
        src.m_filterA[0].m_in = src.m_buffer[1];
        src.m_filterA[0].m_out[0] = _2;
        src.m_filterA[0].m_out[1] = _3;
        src.m_filterA[0].m_out[2] = _4;
        _5 = src.m_filterB[0].m_in + ((src.m_buffer[0] - src.m_filterB[0].m_out[0]) * 0.14737712f);
        _6 = src.m_filterB[0].m_out[0] + ((_5 - src.m_filterB[0].m_out[1]) * 0.48246855f);
        _7 = src.m_filterB[0].m_out[1] + ((_6 - src.m_filterB[0].m_out[2]) * 0.883005f);
        src.m_filterB[0].m_in = src.m_buffer[0];
        src.m_filterB[0].m_out[0] = _5;
        src.m_filterB[0].m_out[1] = _6;
        src.m_filterB[0].m_out[2] = _7;
        _8 = (_4 + _7) * 0.5f;
        _9 = src.m_filterA[0].m_in + ((src.m_buffer[3] - src.m_filterA[0].m_out[0]) * 0.039151598f);
        _10 = src.m_filterA[0].m_out[0] + ((_9 - src.m_filterA[0].m_out[1]) * 0.30264685f);
        _11 = src.m_filterA[0].m_out[1] + ((_10 - src.m_filterA[0].m_out[2]) * 0.6746159f);
        src.m_filterA[0].m_in = src.m_buffer[3];
        src.m_filterA[0].m_out[0] = _9;
        src.m_filterA[0].m_out[1] = _10;
        src.m_filterA[0].m_out[2] = _11;
        _12 = src.m_filterB[0].m_in + ((src.m_buffer[2] - src.m_filterB[0].m_out[0]) * 0.14737712f);
        _13 = src.m_filterB[0].m_out[0] + ((_12 - src.m_filterB[0].m_out[1]) * 0.48246855f);
        _14 = src.m_filterB[0].m_out[1] + ((_13 - src.m_filterB[0].m_out[2]) * 0.883005f);
        src.m_filterB[0].m_in = src.m_buffer[2];
        src.m_filterB[0].m_out[0] = _12;
        src.m_filterB[0].m_out[1] = _13;
        src.m_filterB[0].m_out[2] = _14;
        _15 = (_11 + _14) * 0.5f;
        _16 = src.m_filterA[1].m_in + ((_15 - src.m_filterA[1].m_out[0]) * 0.039151598f);
        _17 = src.m_filterA[1].m_out[0] + ((_16 - src.m_filterA[1].m_out[1]) * 0.30264685f);
        _18 = src.m_filterA[1].m_out[1] + ((_17 - src.m_filterA[1].m_out[2]) * 0.6746159f);
        src.m_filterA[1].m_in = _15;
        src.m_filterA[1].m_out[0] = _16;
        src.m_filterA[1].m_out[1] = _17;
        src.m_filterA[1].m_out[2] = _18;
        _19 = src.m_filterB[1].m_in + ((_8 - src.m_filterB[1].m_out[0]) * 0.14737712f);
        _20 = src.m_filterB[1].m_out[0] + ((_19 - src.m_filterB[1].m_out[1]) * 0.48246855f);
        _21 = src.m_filterB[1].m_out[1] + ((_20 - src.m_filterB[1].m_out[2]) * 0.883005f);
        src.m_filterB[1].m_in = _8;
        src.m_filterB[1].m_out[0] = _19;
        src.m_filterB[1].m_out[1] = _20;
        src.m_filterB[1].m_out[2] = _21;
        output = (_18 + _21) * 0.5f;
        src.m_bufferPos = 0;
    }

    //==============================================================================
    int32_t _internal___minInt32 (int32_t a, int32_t b) noexcept
    {
        if (! (a < b)) goto _moreThan;
        _lessThan: { return a; }
        _moreThan: { return b; }
    }


    #if __clang__
     #pragma clang diagnostic pop
    #elif defined(__GNUC__)
     #pragma GCC diagnostic pop
    #elif defined(_MSC_VER)
     #pragma warning (pop)
    #endif

    //==============================================================================
    // The program contains no string literals, so this function should never be called
    static constexpr const char* lookupStringLiteral (int32_t)  { return {}; }

    //==============================================================================
    _State state = {}, initialisedState;

    double sampleRate = 1.0;
    uint32_t framesToAdvance = 0;
    uint64_t totalFramesElapsed = 0;
};

