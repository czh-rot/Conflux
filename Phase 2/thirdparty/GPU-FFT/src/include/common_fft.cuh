// Copyright 2024 Alişah Özcan
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Developer: Alişah Özcan

#ifndef COMMON_FFT_H
#define COMMON_FFT_H

#include <cuda_runtime.h>

#include <cassert>
#include <exception>
#include <iostream>
#include <string>

namespace gpufft
{

    class CudaException : public std::exception
    {
      public:
        CudaException(const std::string& file, int line, cudaError_t error)
            : file_(file), line_(line), error_(error)
        {
        }

        const char* what() const noexcept override
        {
            return m_error_string.c_str();
        }

      private:
        std::string file_;
        int line_;
        cudaError_t error_;
        std::string m_error_string = "CUDA Error in " + file_ + " at line " +
                                     std::to_string(line_) + ": " +
                                     cudaGetErrorString(error_);
    };

#define GPUFFT_CUDA_CHECK(err)                                                 \
    do                                                                         \
    {                                                                          \
        cudaError_t error = err;                                               \
        if (error != cudaSuccess)                                              \
        {                                                                      \
            throw CudaException(__FILE__, __LINE__, error);                    \
        }                                                                      \
    } while (0)

    void customAssert(bool condition, const std::string& errorMessage);

    float calculate_mean(const float array[], int size);

    float calculate_standard_deviation(const float array[], int size);

    float find_best_average(const float array[], int array_size,
                            int num_elements);

    float find_min_average(const float array[], int array_size,
                           int num_elements);

    __global__ void GPU_ACTIVITY(unsigned long long* output,
                                 unsigned long long fix_num);
    __host__ void GPU_ACTIVITY_HOST(unsigned long long* output,
                                    unsigned long long fix_num);

} // namespace gpufft
#endif // COMMON_FFT_H