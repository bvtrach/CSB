/*
 * Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * SPDX-License-Identifier: MIT
 */
#ifndef BM_ERROR_H
#define BM_ERROR_H

typedef enum {
    BM_ERR_NONE,
    BM_ERR_PARAMS_INCORRECT_COUNT,
    BM_ERR_PARAMS_CANNOT_PARSE,
    BM_ERR_PARAM_MISMATCH,
    BM_ERR_PARAM_MISSING,
} bm_error_t;

#endif
