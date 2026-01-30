/*
 * Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * SPDX-License-Identifier: MIT
 */
#ifndef SHE_HULK_THREAD_LAUNCHER_H
#define SHE_HULK_THREAD_LAUNCHER_H

#include <assert.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include "time.h"
#include <stdbool.h>

#ifdef __linux__
    #if !defined(_GNU_SOURCE)
        #error add "-D_GNU_SOURCE" to your compile command
    #endif
    #include <sched.h>
    #include <sys/sysinfo.h>
#else
    #define DISABLE_LAUNCHER_AFFINITY
#endif
#include <stdatomic.h>
static atomic_bool g_go = false;
#define GIVE_START_SIGNAL()                                                    \
    atomic_store_explicit(&g_go, true, memory_order_relaxed)
#define RESET_START_SIGNAL() atomic_load_explicit(&g_go, memory_order_relaxed)
#define WAIT_FOR_GO_SIGNAL()                                                   \
    while (atomic_load_explicit(&g_go, memory_order_relaxed) == false)

typedef void *(*thread_fun_t)(void *);

typedef struct {
    pthread_t t;
    size_t id;
    bool assign_me_to_core;
    thread_fun_t run_fun;
} run_info_t;

static inline void set_cpu_affinity(size_t target_cpu);

static inline void *
common_run(void *args)
{
    run_info_t *run_info = (run_info_t *)args;

    if (run_info->assign_me_to_core)
        set_cpu_affinity(run_info->id);

    WAIT_FOR_GO_SIGNAL();

    return run_info->run_fun((void *)run_info->id);
}

/**
 * binds the calling thread to the target_cpu
 * @ref https://man7.org/linux/man-pages/man2/sched_setaffinity.2.html
 * @param target_cpu
 */
static inline void
set_cpu_affinity(size_t target_cpu)
{
#if !defined(DISABLE_LAUNCHER_AFFINITY)
    int number_of_cores = get_nprocs();

    cpu_set_t set;
    CPU_ZERO(&set);

    /* to cover for oversubscription */
    size_t core = target_cpu % (uint32_t)number_of_cores;

    CPU_SET(core, &set);

    if (sched_setaffinity(0, sizeof(set), &set) < 0) {
        assert(0 && "failed to set affinity");
    }
#else
    V_UNUSED(target_cpu);
#endif
}

static inline void
create_threads(run_info_t *threads, size_t num_threads, thread_fun_t fun,
               bool bind)
{
    size_t i = 0;
    for (i = 0; i < num_threads; i++) {
        threads[i].id                = i;
        threads[i].run_fun           = fun;
        threads[i].assign_me_to_core = bind;
        pthread_create(&threads[i].t, 0, common_run, &threads[i]);
    }
    GIVE_START_SIGNAL();
}

static inline void
await_threads(run_info_t *threads, size_t num_threads)
{
    size_t i = 0;
    for (i = 0; i < num_threads; i++) {
        pthread_join(threads[i].t, NULL);
    }
}
/**
 * Launches as many threads as `thread_count` and waits for them to finish
 * @note the threads start on the same signal, and are bound to different cores
 * @param thread_count number of threads to create
 * @param fun thread function to pass
 */
static inline void
launch_threads(size_t thread_count, thread_fun_t fun)
{
    run_info_t *threads = malloc(sizeof(run_info_t) * thread_count);

    create_threads(threads, thread_count, fun, true);

    await_threads(threads, thread_count);

    free(threads);
}
/**
 * Launches threads, waits for a given amount of time, write to stop signal and
 * wait for threads to finish gracefully
 *
 * @param thread_count number of threads to launch
 * @param fun thread function
 * @param wait_in_seconds number of seconds for main thread to sleep after
 * launching threads
 * @param stop_flag address of the stop flag to write to
 * @param bind should the thread be bound to a core or not
 */
static inline cpu_time_t
launch_threads_and_stop_them(size_t thread_count, thread_fun_t fun,
                             unsigned int wait_in_seconds,
                             atomic_bool *stop_flag, bool bind)
{
    cpu_time_t stop_time = {0};
    run_info_t *threads  = malloc(sizeof(run_info_t) * thread_count);

    create_threads(threads, thread_count, fun, bind);

    sleep(wait_in_seconds);

    atomic_store_explicit(stop_flag, true, memory_order_relaxed);
    record_time(&stop_time);

    await_threads(threads, thread_count);

    free(threads);
    return stop_time;
}

#endif
