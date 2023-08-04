// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#include <vector>
#include <functional>
#include <atomic>
#include <memory>
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>
#include "AudioProgram.h"
#include "WorkStealingQueue.h"

namespace AudioKit {
using std::condition_variable
using std::mutex
using std::vector

class WorkerThread {
public:
    /// Information about rendering jobs.
    AudioProgram program;
    
    /// AU stuff.
    AudioUnitRenderActionFlags actionFlags;
    
    /// AU stuff.
    AudioTimeStamp timeStamp;
    
    /// Number of audio frames to render.
    AUAudioFrameCount frameCount = 0
    
    /// Our main output buffer.
    vector<AudioBufferList> outputBufferList;
    
    /// Queue for submitting jobs to the worker.
    vector<RenderJobIndex> initalJobs;
    
    int workerIndex;
    
    vector<WorkStealingQueue> runQueues;
    
//    var workgroup: WorkGroup?
//
//    var joinToken: WorkGroup.JoinToken?
    WorkerThread(int index,
                     std::vector<WorkStealingQueue> &runQueues)
                     : workerIndex(index), runQueues(runQueues)
        {
            
        }
    
    /// Add a job for the worker.
    ///
    /// Call this *before* the worker is awakened or will have a data race.
    bool add(RenderJobIndex job) {
        if (initialJobCount < initialJobs.size()) {
            initialJobs[initialJobCount] = job;
            initialJobCount += 1;
            return true;
        }
        return false;
    }
    
    void main() {
        // Omitted: The real-time scheduling setup. This is very platform-dependent in C++.

        while (true) {
            // Wait until signaled to do some work
            std::unique_lock<std::mutex> lk_prod(mtx_prod);
            cv_prod.wait(lk_prod, [this] { return ready_prod; });
            ready_prod = false;

            if (!run) {
                break;
            }

            for (size_t i = 0; i < initialJobCount; i++) {
                runQueues[workerIndex].push(initialJobs[i]);
            }
            initialJobCount = 0;

            if (program) {
                program.run(actionFlags,
                            timeStamp,
                            frameCount,
                            outputBufferList, // Assume this is correctly initialized
                            workerIndex,
                            runQueues);
            } else {
                std::cout << "worker has no program!" << std::endl;
            }

            // Signal that we're done
            {
                std::lock_guard<std::mutex> lk_done(mtx_done);
                ready_done = true;
            }
            cv_done.notify_one();
        }

        // Omitted: The workgroup leave logic. There's no direct C++ equivalent.
    }

    
    void exit() {
        run = false;
        {
            std::lock_guard<std::mutex> lk_prod(mtx_prod);
            ready_prod = true;
        }
        cv_prod.notify_one();
    }


    
private:
    bool run = true
    
    /// Used to wake the worker.
    condition_variable cv_prod;
    mutex mtx_prod;
    bool ready_prod = false;

    /// Used to wait for the worker to finish a cycle.
    condition_variable cv_done;
    mutex mtx_done;
    bool ready_done = false;
    
}
} //namespace AudioKit
