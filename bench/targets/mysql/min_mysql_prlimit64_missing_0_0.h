/*
 * Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * SPDX-License-Identifier: MIT
 */
/**
 * @file bm_autogen.h
 * @brief CSB target registry generated from syzkaller programs.
 */

#include <CSB/bm_generated_program.h>
#include <CSB/bm_target.h>

#include <assert.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define NOP_PER_OP 1

#define MAX_NAME_LEN 20U
#define NUM_SYSCALLS 1

extern const csb_generated_program_t
    csb_program_min_mysql_prlimit64_missing_0_0;

static const csb_generated_program_t *const csb_programs[] = {
    &csb_program_min_mysql_prlimit64_missing_0_0,
};

static const size_t csb_program_count =
    sizeof(csb_programs) / sizeof(csb_programs[0]);
static const char *op_name_tbl[NUM_SYSCALLS];

struct thread_ctx_s {
    size_t tid;
    size_t iteration;
    bool aggregation_threads;
    void **program_states;
};

static inline char *
bm_target_get_name(void)
{
    return "min_mysql_prlimit64_missing_0_0";
}

static inline size_t
bm_target_op_count(void)
{
    return NUM_SYSCALLS;
}

static inline void
bm_target_get_op_name(char *out_str, const size_t len, size_t op_id)
{
    assert(len >= MAX_NAME_LEN && "output buffer too small");
    assert(op_id < NUM_SYSCALLS);
    snprintf(out_str, len, "%s", op_name_tbl[op_id]);
}

static inline void
bm_target_init(uint16_t port, size_t num_threads)
{
    op_name_tbl[0] = "min_mysql_prlimit64_missing_0_0";
    for (size_t i = 0; i < csb_program_count; i++)
        csb_programs[i]->init(port);
    V_UNUSED(num_threads);
}

static inline void
bm_target_reg(thread_ctx_t *ctx, size_t tid)
{
    assert(ctx);
    ctx->tid                 = tid;
    ctx->aggregation_threads = false;
    ctx->program_states =
        calloc(csb_program_count, sizeof(*ctx->program_states));
    assert(ctx->program_states);

    for (size_t i = 0; i < csb_program_count; i++) {
        ctx->program_states[i] = csb_programs[i]->create(tid);
        assert(ctx->program_states[i]);
    }
}

static inline bm_op_res_t
bm_dispatch_operation(thread_ctx_t *ctx, size_t op_id)
{
    bm_op_res_t total = {0};
    for (size_t i = 0; i < csb_program_count; i++) {
        csb_program_result_t result =
            csb_programs[i]->dispatch(ctx->program_states[i], op_id);
        total.op_count += result.op_count;
        total.succ_count += result.succ_count;
    }
    ctx->iteration++;
    return total;
}

static inline void
bm_target_dereg(thread_ctx_t *ctx, size_t tid)
{
    for (size_t i = 0; i < csb_program_count; i++)
        csb_programs[i]->destroy(ctx->program_states[i]);
    free(ctx->program_states);
    ctx->program_states = NULL;
    V_UNUSED(tid);
}

static inline void
bm_target_destroy(size_t num_threads)
{
    V_UNUSED(num_threads);
}

static inline void
bm_target_extra_info(char *buf, size_t len)
{
    V_UNUSED(buf, len);
}
