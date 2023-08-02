#include <vector>
#include <functional>
#include <atomic>
#include <memory>
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>
#include "WorkStealingQueue.hpp"

namespace AudioKit {

using std::vector;
using std::shared_ptr;
using std::atomic;
using RenderJobVector = vector<shared_ptr<RenderJob>>;
class AudioProgram {
    
public:
    vector<int> generatorIndices;
    
    AudioProgram(const RenderJobVector& jobs, vector<int> generatorIndices)
    : jobs(jobs), generatorIndices(generatorIndices), finished(new atomic<int>[jobs.size()])
    {
        reset();
    }
    
    void reset() {
        for (int i=0;i < jobs.size(); ++i) {
            finished[i].store(0);
        }
        remaining.store(static_cast<int>(jobs.size()));
    }
    
    ~AudioProgram() {
        delete[] finished;
    }
    
    void run(AudioUnitRenderActionFlags* actionFlags,
             const AudioTimeStamp* timeStamp,
             AUAudioFrameCount frameCount,
             AudioBufferList* outputBufferList,
             int workerIndex,
             std::vector<WorkStealingQueue<int>>& runQueues) {
        
        auto exec = [&](int index) {
            auto& job = jobs[index];
            
            job->render(actionFlags, timeStamp, frameCount,
                       (index == jobs.size() - 1) ? outputBufferList : nullptr);
            
            // Increment outputs.
            for (int outputIndex : job->outputIndices) {
                if (finished[outputIndex].fetch_add(1, std::memory_order_relaxed) == jobs[outputIndex]->inputCount()) {
                    runQueues[workerIndex].push(outputIndex);
                }
            }
            
            remaining.fetch_sub(1, std::memory_order_relaxed);
        };
        
        while (remaining.load(std::memory_order_relaxed) > 0) {
            // Pop an index off our queue.
            if (auto index = runQueues[workerIndex].pop()) {
                exec(*index);
            } else {
                // Try to steal an index. Start with the next worker and wrap around,
                // but don't steal from ourselves.
                for (int i = 0; i < runQueues.size() - 1; ++i) {
                    int victim = (workerIndex + i) % runQueues.size();
                    if (auto index = runQueues[victim].steal()) {
                        exec(*index);
                        break;
                    }
                }
            }
        }
    }

private:
    vector<shared_ptr<RenderJob>> jobs;
    atomic<int>* finished;
    atomic<int> remaining = {0};
};

} //namespace AudioKit
