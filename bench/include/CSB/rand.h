/*
 * Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * SPDX-License-Identifier: MIT
 * Author: Huawei Dresden Research Center
 */
#ifndef SHE_HULK_UTILS_RAND_H
#define SHE_HULK_UTILS_RAND_H

#include <assert.h>
#include "math.h"
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <sys/random.h>
#include <stdbool.h>

#include <time.h>

static inline uint64_t
rand_gen_seed(void)
{
    return (uint64_t)time(0);
}

/**
 * rand is not thread-safe. If you need to use rand in a concurrent algo
 * pre-generate the randoms, save them and then use them.
 * @see random_gen_values
 */

static bool g_rand_initialized             = false;
static __thread unsigned int g_thread_seed = 0;

/**
 * uses time(0) as the seed of srand
 *
 */
static inline void
random_init(void)
{
    unsigned int seed = time(0);
    if (!g_rand_initialized) {
        srand(seed);
        g_rand_initialized = true;
    }
}
/**
 * Wraps rand
 * @return int what rand returns
 */
static inline int
random_rand(void)
{
#ifdef __APPLE__
    char buf[sizeof(int)] = {0};
    if (getentropy(buf, sizeof(int)) == -1) {
        assert(0 && "getentropy failed");
        return 0;
    } else {
        return *((int *)buf);
    }
#else
    char buf[sizeof(int)] = {0};
    if (getrandom(buf, sizeof(int), GRND_RANDOM) == -1) {
        assert(0 && "getrandom failed");
        return 0;
    } else {
        return *((int *)buf);
    }
#endif
}

/**
 * Wraps rand_r
 * @return int what rand returns
 * @note it is thread safe
 * @note uses thread local storage
 */
static inline int
random_thread_safe_rand(void)
{
    if (g_thread_seed == 0) {
        g_thread_seed = time(NULL);
    }
    return rand_r(&g_thread_seed);
}

/**
 * Generates a random number in [`min`, `max`]
 * @note uses a thread safe random number generator
 * @param min minimum number that can to be generated
 * @param max maximum number that can to be generated
 * @return uint32_t a number between [`min`, `max`]
 */
static inline uint32_t
random_thread_safe_get_next(uint32_t min, uint32_t max)
{
    assert(min <= max);
    assert(max < INT32_MAX);
    int r = random_thread_safe_rand();
    if (r < 0) {
        r *= -1;
    }
    return (((uint32_t)r) % (max - min + 1U)) + min;
}

/**
 * Uses the given seed to initialize srand
 *
 * @param seed
 */
static inline void
random_init_seed(unsigned int seed)
{
    assert(!g_rand_initialized && "was initialized before");
    srand(seed);
    g_rand_initialized = true;
}
/**
 * Wraps rand to generate a more of evenly distributed random number
 * @param range
 * @pre range <= 0x0FFFFFF
 * @return uint32_t
 */
static inline uint32_t
_random(uint32_t range)
{
    uint32_t r = 0;
    if (!g_rand_initialized) {
        random_init_seed(0);
    }
    assert(g_rand_initialized &&
           "the module needs to be initialized first. call "
           "random_init_seed/random_init");

    assert(range <= 0x0FFFFFFF && "Value is not supported");

    do {
        r = (uint32_t)random_rand() % v_pow2_round_up(range);
    } while (r >= range);

    return r;
}
/**
 * Returns a uint32_t random number in [min, max]
 *
 * @param min
 * @param max
 * @return uint32_t
 */
static inline uint32_t
random_next_int(uint32_t min, uint32_t max)
{
    uint32_t random_number = 0;
    assert(max >= min);
    random_number = _random(max - min + 1);
    return random_number + min;
}

/**
 * Returns a uint64_t random number in [min, max]
 *
 * @param min
 * @param max
 * @param alignment
 * @return uint64_t
 */
static inline uint64_t
random_next_int64(uint64_t min, uint64_t max, uint16_t alignment)
{
    uint64_t random_number      = 0;
    uint32_t rand_msbits        = 0;
    uint32_t rand_lsbits        = 0;
    uint64_t range              = (max - min) + 1;
    const uint32_t shift_to_msb = 32;
    assert(max >= min);

    rand_lsbits = random_rand();
    rand_msbits = random_rand();

    random_number = ((uint64_t)rand_msbits << shift_to_msb) | rand_lsbits;

    random_number = (random_number) % range + min;

    random_number = random_number & ~((1 << alignment) - 1);

    assert(random_number >= min);
    assert(random_number <= max);

    return random_number;
}
/**
 * random_with_probability
 * e.g. given an array of {20, 20, 60} the probabilities of the return value
 * will be as follows
 * 	~ 20%  0
 * 	~ 20%  1
 * 	~ 60%  2
 * @note the sum of the array elements should be exactly 100 (i.e. 100%)
 * @param probabilities an array of the probabilities one wants to achieve
 * @param length of the "probabilities" array
 * @return uint32_t
 * 	an integer between [0, length-1]
 */
static inline uint32_t
random_with_probability(uint32_t *probabilities, uint32_t length)
{
    uint32_t r     = random_next_int(1, 100);
    uint32_t i     = 0;
    uint32_t start = 0;

    for (i = 0; i < length; i++) {
        if (r > start && r <= (start + probabilities[i])) {
            return i;
        }
        start += probabilities[i];
    }

    assert(0 && "something is wrong this should not be reachable");
    return 0;
}
/**
 * random_next_string
 * creates a non-null-terminating string of the given len
 * @param len length of the desired string
 * @param str output parameter where the string will be stored
 */
static inline void
random_next_string(unsigned char *str, size_t len)
{
    size_t i = 0;

    for (i = 0; i < len; i++) {
        str[i] = (unsigned char)random_next_int(0, UINT8_MAX);
    }
}
/**
 * random_next_string
 * creates a non-null-terminating string of the given len
 * @param len length of the desired string
 * @param str output parameter where the string will be stored
 */
static inline void
random_next_printable_string(unsigned char *str, size_t len)
{
    size_t i                = 0;
    const uint32_t min_char = 33;
    const uint32_t max_char = 126;

    for (i = 0; i < len - 1; i++) {
        // 33 = '!'
        // 126 = '~'
        str[i] = (unsigned char)random_next_int(min_char, max_char);
    }
    assert(i == len - 1);
    str[i] = '\0';
}

/**
 * fills the given array with random numbers that fall in [min, max]
 *
 * @param arr uint32_t array to be filled with random numbers
 * @param len the length of the array
 * @param min
 * @param max
 */
static inline void
random_gen_values(uint32_t arr[], size_t len, uint32_t min, uint32_t max)
{
    size_t i = 0;

    for (i = 0; i < len; i++) {
        arr[i] = random_next_int(min, max);
    }
}

/* Deterministic random generator that allows multiple seeding,
 * to be used in testing.
 */

static inline void
deterministic_random_init(unsigned int seed)
{
    srand(seed);
}

static inline uint32_t
deterministic_random(uint32_t range)
{
    uint32_t r = 0;
    do {
        r = rand() % v_pow2_round_up(range);
    } while (r >= range);
    return r;
}

static inline uint32_t
deterministic_random_next_int(uint32_t min, uint32_t max)
{
    assert(max >= min);
    return deterministic_random(max - min + 1) + min;
}

static inline void
deterministic_random_shuffle(size_t arr[], size_t len)
{
    for (size_t i = 1; i < len; ++i) {
        size_t index = deterministic_random_next_int(0, i - 1);
        size_t temp  = arr[i];
        arr[i]       = arr[index];
        arr[index]   = temp;
    }
}

#endif
