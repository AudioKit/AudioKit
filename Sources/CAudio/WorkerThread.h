// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#pragma once
#include <vector>
#include <functional>
#include <atomic>
#include <memory>
#include <thread>
#include <dispatch/dispatch.h>
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>
#include <mach/mach_time.h>
#include "AudioProgram.h"
#include "WorkStealingQueue.hpp"

#define one_billion 1000000000

namespace AudioKit {
using std::condition_variable;
using std::mutex;
using std::vector;
using std::shared_ptr;

class WorkerThread {
public:
    /// Information about rendering jobs.
    shared_ptr<AudioProgram> program;
    
    /// AU stuff.
    AudioUnitRenderActionFlags actionFlags;
    
    /// AU stuff.
    AudioTimeStamp timeStamp;
    
    /// Number of audio frames to render.
    AUAudioFrameCount frameCount = 0;
    
    /// Our main output buffer.
    AudioBufferList* _Nonnull outputBufferList;
    
    /// Queue for submitting jobs to the worker.
    vector<RenderJobIndex> initialJobs;
    
    int workerIndex;
    
    int initialJobCount = 0;
    
    vector<shared_ptr<WorkStealingQueue<int>>> runQueues;
    
    os_workgroup_t _Nonnull workgroup;
    
    os_workgroup_join_token_t _Nonnull joinToken;
    
    WorkerThread(int index,
                     std::vector<std::shared_ptr<WorkStealingQueue<int>>> &queues,
                 dispatch_semaphore_t _Nonnull prodSemaphore,
                 dispatch_semaphore_t _Nonnull doneSemaphore,
                 os_workgroup_t _Nonnull workgroupInstance)
            : workerIndex(index), runQueues(queues), prod(prodSemaphore), done(doneSemaphore), workgroup(workgroupInstance)
        {
            initialJobs.resize(1024);
            run.store(true);
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
        if (workgroup != nullptr) {
            mach_timebase_info_data_t tbinfo = mach_timebase_info_data_t();
            mach_timebase_info(&tbinfo);
            
            double seconds = tbinfo.denom / tbinfo.numer * one_billion;
            
            // Guessing what the parameters would be for 128 frame buffer at 44.1kHz
            double period = (128.0 / 44100.0) * seconds;
            double constraint = 0.5 * period;
            double computation = 0.5 * constraint;
            
            struct thread_time_constraint_policy ttcpolicy;
            int ret;
            thread_port_t threadport = pthread_mach_thread_np(pthread_self());
         
            ttcpolicy.period=period; // HZ/160
            ttcpolicy.computation=computation; // HZ/3300;
            ttcpolicy.constraint=constraint; // HZ/2200;
            ttcpolicy.preemptible=1;
         
            if ((ret=thread_policy_set(threadport,
                THREAD_TIME_CONSTRAINT_POLICY, (thread_policy_t)&ttcpolicy,
                THREAD_TIME_CONSTRAINT_POLICY_COUNT)) != KERN_SUCCESS) {
                    fprintf(stderr, "set_realtime() failed.\n");
                    ///Should we throw an error here?
            }
            ///we set thread policy to realtime?
            
            /// I'm unsure what to do with the int that is returned, perhaps we can detect any errors with it?
            int workgroup_join_status = os_workgroup_join(workgroup, joinToken);
        }
        
        while (true) {
            /* #define DISPATCH_TIME_NOW (0ull)
             #define DISPATCH_TIME_FOREVER (~0ull)*/
            
            intptr_t wait = dispatch_semaphore_wait(prod, DISPATCH_TIME_FOREVER);
                        
            if (!run.load()) {
                break;
            }
            
            for (int i = 0; i < initialJobCount; ++i) {
                runQueues[workerIndex]->push(initialJobs[i]);
            }
            initialJobCount = 0;

            if (program) {
                program->run(&actionFlags,
                             &timeStamp,
                             frameCount,
                             outputBufferList,
                             workerIndex,
                             runQueues);
            } else {
                printf("worker has no program!\n");
            }

            intptr_t done_semaphore_int = dispatch_semaphore_signal(done);
            
            if (joinToken) {
                os_workgroup_leave(workgroup, joinToken);
            }
        }
        
    }
    
    void exit() {
        run.store(false);
        dispatch_semaphore_signal(prod);
    }

private:
    std::atomic<bool> run = true;
    
    /// Used to wake the worker.
    dispatch_semaphore_t _Nonnull prod;

    /// Used to wait for the worker to finish a cycle.
    dispatch_semaphore_t _Nonnull done;
    
};

} //namespace AudioKit
