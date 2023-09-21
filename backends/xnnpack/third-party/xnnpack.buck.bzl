load("//third-party:glob_defs.bzl", "subdir_glob")
load(
    ":xnnpack_src_defs.bzl",
    "HOT_SRCS",
    "JIT_SRCS",
    "LOGGING_SRCS",
    "OPERATOR_SRCS",
    "SUBGRAPH_SRCS",
    "TABLE_SRCS",
)
load(
    ":xnnpack_wrapper_defs.bzl",
    "AARCH64_ASM_MICROKERNEL_SRCS",
    "ALL_NEONFMA_AARCH64_MICROKERNEL_SRCS",
    "ALL_NEON_AARCH64_MICROKERNEL_SRCS",
    "PROD_AARCH64_NEONFP16ARITH_MICROKERNEL_SRCS",
    "PROD_AVX2_MICROKERNEL_SRCS",
    "PROD_AVX512F_MICROKERNEL_SRCS",
    "PROD_AVX512SKX_MICROKERNEL_SRCS",
    "PROD_AVX512VBMI_MICROKERNEL_SRCS",
    "PROD_AVX_MICROKERNEL_SRCS",
    "PROD_F16C_MICROKERNEL_SRCS",
    "PROD_FMA3_MICROKERNEL_SRCS",
    "PROD_NEONDOT_MICROKERNEL_SRCS",
    "PROD_NEONFMA_MICROKERNEL_SRCS",
    "PROD_NEONFP16_MICROKERNEL_SRCS",
    "PROD_NEONV8_MICROKERNEL_SRCS",
    "PROD_NEON_MICROKERNEL_SRCS",
    "PROD_SCALAR_AARCH32_MICROKERNEL_SRCS",
    "PROD_SCALAR_PORTABLE_MICROKERNEL_SRCS",
    "PROD_SSE2_MICROKERNEL_SRCS",
    "PROD_SSE41_MICROKERNEL_SRCS",
    "PROD_SSE_MICROKERNEL_SRCS",
    "PROD_SSSE3_MICROKERNEL_SRCS",
    "PROD_XOP_MICROKERNEL_SRCS",
)

def define_xnnpack():
    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "interface",
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/include", "**/*.h"),
        ]),
        header_namespace = "",
        exported_headers = {
            "xnnpack.h": "XNNPACK/include/xnnpack.h",
        },
        compiler_flags = [
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ],
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        visibility = ["PUBLIC"],
        exported_deps = [
            ":pthreadpool",
        ],
    )

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "hot",
        srcs = HOT_SRCS,
        compiler_flags = [
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ],
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":FXdiv",
            ":clog",
            ":interface",
            ":cpuinfo",
        ],
    )

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "jit_memory",
        srcs = JIT_SRCS,
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-std=c++17",
        ],
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":clog",
            ":interface",
        ],
    )

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "operators",
        srcs = OPERATOR_SRCS + [
            "XNNPACK/src/allocator.c",
            "XNNPACK/src/binary-elementwise-config.c",
            "XNNPACK/src/cache.c",
            "XNNPACK/src/indirection.c",
            "XNNPACK/src/memory.c",
            "XNNPACK/src/mutex.c",
            "XNNPACK/src/normalization.c",
            "XNNPACK/src/operator-utils.c",
            "XNNPACK/src/packing.c",
        ],
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ],
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
            "-DXNN_ENABLE_GEMM_M_SPECIALIZATION=0",
        ],
        exported_deps = [
            ":FP16",
            ":FXdiv",
            ":clog",
            ":hot",
            ":interface",
            ":ukernels_f16c",
            ":cpuinfo",
        ],
    )

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "subgraph",
        srcs = SUBGRAPH_SRCS,
        compiler_flags = [
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ],
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
        ]),
        header_namespace = "",
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
            "-DXNN_ENABLE_JIT=0",
            "-DXNN_ENABLE_SPARSE=0",
            "-DXNN_ENABLE_GEMM_M_SPECIALIZATION=0",
            "-DXNN_ENABLE_MEMOPT",
        ],
        exported_deps = [
            ":FP16",
            ":FXdiv",
            ":clog",
            ":hot",
            ":interface",
        ],
    )

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "tables",
        srcs = TABLE_SRCS,
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ],
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":FXdiv",
            ":clog",
            ":hot",
            ":interface",
        ],
    )

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_scalar",
        srcs = PROD_SCALAR_PORTABLE_MICROKERNEL_SRCS,
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O3",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ],
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    DEFAULT_DUMMY_SRC = []

    SSE_COMPILER_FLAGS = ["-msse"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_sse",
        srcs = select({
            "DEFAULT": PROD_SSE_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": SSE_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":interface",
        ],
    )

    SSE2_COMPILER_FLAGS = ["-msse2"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_sse2",
        srcs = select({
            "DEFAULT": PROD_SSE2_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": SSE2_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    SSE3_COMPILER_FLAGS = ["-mssse3"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_ssse3",
        srcs = select({
            "DEFAULT": PROD_SSSE3_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": SSE3_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    SSE41_COMPILER_FLAGS = ["-msse4.1"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_sse41",
        srcs = select({
            "DEFAULT": PROD_SSE41_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": SSE41_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    AVX_COMPILER_FLAGS = ["-mavx"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_avx",
        srcs = select({
            "DEFAULT": PROD_AVX_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": AVX_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":interface",
        ],
    )

    XOP_COMPILER_FLAGS = ["-mxop"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_xop",
        srcs = select({
            "DEFAULT": PROD_XOP_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": XOP_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":interface",
        ],
    )

    F16C_COMPILER_FLAGS = ["-mf16c"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_f16c",
        srcs = select({
            "DEFAULT": PROD_F16C_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": F16C_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":interface",
        ],
    )

    FMA3_COMPILER_FLAGS = [
        "-mfma",
        "-mf16c",
    ]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_fma3",
        srcs = select({
            "DEFAULT": PROD_FMA3_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": FMA3_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":interface",
        ],
    )

    AVX2_COMPILER_FLAGS = [
        "-mavx2",
        "-mfma",
        "-mf16c",
    ]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_avx2",
        srcs = select({
            "DEFAULT": PROD_AVX2_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": AVX2_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":interface",
        ],
    )

    AVX512F_COMPILER_FLAGS = ["-mavx512f"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_avx512",
        srcs = select({
            "DEFAULT": PROD_AVX512F_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": AVX512F_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":interface",
        ],
    )

    AVX512SKX_COMPILER_FLAGS = [
        "-mavx512f",
        "-mavx512cd",
        "-mavx512bw",
        "-mavx512dq",
        "-mavx512vl",
    ]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_avx512skx",
        srcs = select({
            "DEFAULT": PROD_AVX512SKX_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": AVX512SKX_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":interface",
        ],
    )

    SCALAR_AARCH32_COMPILER_FLAGS = [
        "-march=armv7-a",
        "-fpu=neon",
        "-mfloat-abi=softfp",
    ]

    NEONFMA_AARCH64_COMPILER_FLAGS = [
        "-march=armv8-a",
        "-mfpu=neon-fp-armv8",
    ]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_scalar_aarch32",
        srcs = select({
            "DEFAULT": PROD_SCALAR_AARCH32_MICROKERNEL_SRCS,
            "ovr_config//cpu:x86_32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:x86_64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": [],
            "ovr_config//cpu:arm32": SCALAR_AARCH32_COMPILER_FLAGS,
            "ovr_config//cpu:x86_32": [],
            "ovr_config//cpu:x86_64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    NEON_COMPILER_FLAGS = [
        "-march=armv7-a",
        "-fpu=neon",
        "-mfloat-abi=softfp",
    ]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_asm_aarch64",
        srcs = select({
            "DEFAULT": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": AARCH64_ASM_MICROKERNEL_SRCS,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "xnnpack/assembly.h"),
            ("XNNPACK/src", "**/*.S"),
        ]),
        header_namespace = "",
        platform_compiler_flags = [
            (
                "(aarch64|arm64)",
                [
                    "-march=armv8.2-a+fp16+dotprod",
                ],
            ),
        ],
        compiler_flags = [
            "-O2",
        ],
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_neon",
        srcs = select({
            "DEFAULT": PROD_NEON_MICROKERNEL_SRCS,
            "ovr_config//cpu:x86_32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:x86_64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": [],
            "ovr_config//cpu:arm32": NEON_COMPILER_FLAGS,
            "ovr_config//cpu:x86_32": [],
            "ovr_config//cpu:x86_64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    AVX512VBMI_COMPILER_FLAGS = ["-mavx512vbmi"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_avx512vbmi",
        srcs = select({
            "DEFAULT": PROD_AVX512VBMI_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:arm64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": AVX512VBMI_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:arm64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":interface",
        ],
    )

    NEON64_AARCH64_COMPILER_FLAGS = ["-mfpu=neon-vfpv6"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_neon_aarch64",
        srcs = select({
            # "DEFAULT": PROD_AARCH64_NEON_MICROKERNEL_SRCS,
            "DEFAULT": ALL_NEON_AARCH64_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:x86_32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:x86_64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": NEON64_AARCH64_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:x86_32": [],
            "ovr_config//cpu:x86_64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    NEON_FP16_COMPILER_FLAGS = ["-mfpu=neon-fp16"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_neon_fp16",
        srcs = select({
            "DEFAULT": PROD_NEONFP16_MICROKERNEL_SRCS,
            "ovr_config//cpu:x86_32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:x86_64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": [],
            "ovr_config//cpu:arm32": NEON_FP16_COMPILER_FLAGS,
            "ovr_config//cpu:x86_32": [],
            "ovr_config//cpu:x86_64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":interface",
        ],
    )

    NEON_FMA_COMPILER_FLAGS = ["-mfpu=neon-vfp4"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_neon_fma",
        srcs = select({
            "DEFAULT": PROD_NEONFMA_MICROKERNEL_SRCS,
            "ovr_config//cpu:x86_32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:x86_64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": [],
            "ovr_config//cpu:arm32": NEON_FMA_COMPILER_FLAGS,
            "ovr_config//cpu:x86_32": [],
            "ovr_config//cpu:x86_64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    NEON64_V8_COMPILER_FLAGS = [
        "-march=armv8-a",
        "-mfpu=neon-fp-armv8",
    ]

    NEON32_V8_COMPILER_FLAGS = [
        "-march=armv8-a",
        "-mfpu=neon-fp-armv8",
        "-mfloat-abi=softfp",
    ]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_neon_v8",
        srcs = select({
            "DEFAULT": PROD_NEONV8_MICROKERNEL_SRCS,
            "ovr_config//cpu:x86_32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:x86_64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": NEON64_V8_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": NEON32_V8_COMPILER_FLAGS,
            "ovr_config//cpu:x86_32": [],
            "ovr_config//cpu:x86_64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    NEON64_FP16ARITH_COMPILER_FLAGS = ["-march=armv8.2-a+fp16"]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_neon_fp16arith_aarch64",
        srcs = select({
            "DEFAULT": PROD_AARCH64_NEONFP16ARITH_MICROKERNEL_SRCS,
            "ovr_config//cpu:arm32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:x86_32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:x86_64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": NEON64_FP16ARITH_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": [],
            "ovr_config//cpu:x86_32": [],
            "ovr_config//cpu:x86_64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    NEON64_DOT_COMPILER_FLAGS = ["-march=armv8.2-a+dotprod"]

    NEON32_DOT_COMPILER_FLAGS = [
        "-march=armv8.2-a+dotprod",
        "-mfpu=neon-fp-armv8",
        "-mfloat-abi=softfp",
    ]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_neon_dot",
        srcs = select({
            "DEFAULT": PROD_NEONDOT_MICROKERNEL_SRCS,
            "ovr_config//cpu:x86_32": DEFAULT_DUMMY_SRC,
            "ovr_config//cpu:x86_64": DEFAULT_DUMMY_SRC,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": NEON64_DOT_COMPILER_FLAGS,
            "ovr_config//cpu:arm32": NEON32_DOT_COMPILER_FLAGS,
            "ovr_config//cpu:x86_32": [],
            "ovr_config//cpu:x86_64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "ukernels_neonfma_aarch64",
        srcs = select({
            "DEFAULT": ALL_NEONFMA_AARCH64_MICROKERNEL_SRCS,
        }),
        headers = subdir_glob([
            ("XNNPACK/src", "**/*.h"),
            ("XNNPACK/src", "**/*.c"),
        ]),
        header_namespace = "",
        compiler_flags = [
            "-O2",
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ] + select({
            "DEFAULT": [],
            "ovr_config//cpu:arm32": NEONFMA_AARCH64_COMPILER_FLAGS,
            "ovr_config//cpu:x86_32": [],
            "ovr_config//cpu:x86_64": [],
        }),
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
        ],
        exported_deps = [
            ":FP16",
            ":interface",
        ],
    )

    COMMON_XNNPACK_DEPS = [
        ":operators",
        ":subgraph",
        ":tables",
        ":ukernels_scalar",
    ]

    X86_64_XNNPACK_DEPS = [
        ":ukernels_avx",
        ":ukernels_avx2",
        ":ukernels_avx512",
        ":ukernels_avx512skx",
        ":ukernels_f16c",
        ":ukernels_fma3",
        ":ukernels_sse",
        ":ukernels_sse2",
        ":ukernels_sse41",
        ":ukernels_ssse3",
        ":ukernels_xop",
        ":ukernels_avx512vbmi",
    ]

    ARM_XNNPACK_DEPS = [
        ":jit_memory",
        ":ukernels_asm_aarch64",
        ":ukernels_neon",
        ":ukernels_neon_aarch64",
        ":ukernels_neon_fp16",
        ":ukernels_neon_fma",
        ":ukernels_neon_v8",
        ":ukernels_neon_fp16arith_aarch64",
        ":ukernels_neon_dot",
        ":ukernels_neonfma_aarch64",
    ]

    # @lint-ignore BUCKLINT: native and fb_native are explicitly forbidden in fbcode.
    native.cxx_library(
        name = "XNNPACK",
        srcs = [
            "XNNPACK/src/amalgam/scalar.c",
            "XNNPACK/src/hardware-config.c",
            "XNNPACK/src/init.c",
            "XNNPACK/src/microparams-init.c",
            "XNNPACK/src/operator-run.c",
            "XNNPACK/src/operators/post-operation.c",
            "XNNPACK/src/params.c",
            "XNNPACK/src/transpose-config.c",
            "XNNPACK/src/x8-lut-config.c",
        ] + LOGGING_SRCS,
        headers = subdir_glob([
            ("XNNPACK/src", "xnnpack/*.h"),
            ("XNNPACK/include", "**/*.h"),
        ]),
        exported_headers = {
            "xnnpack.h": "XNNPACK/include/xnnpack.h",
        },
        header_namespace = "",
        compiler_flags = [
            "-Wno-error=missing-braces",  # required since the SGX toolchain does not have this by default
        ],
        preferred_linkage = "static",
        preprocessor_flags = [
            "-DXNN_LOG_LEVEL=0",
            "-DXNN_NO_Q8_OPERATORS",
            "-DXNN_NO_F16_OPERATORS",
            "-DXNN_NO_NCHW_OPERATORS",
            "-DXNN_NO_U8_OPERATORS",
            "-DXNN_NO_X32_OPERATORS",
            "-DXNN_NO_X8_OPERATORS",
            "-DXNN_ENABLE_MEMOPT",
            "-DXNN_ENABLE_SPARSE=0",
            "-DXNN_ENABLE_JIT=0",
            "-DXNN_ENABLE_ASSEMBLY",
            "-DXNN_ENABLE_GEMM_M_SPECIALIZATION",
            "-DXNN_ENABLE_ARM_DOTPROD",
        ],
        visibility = ["PUBLIC"],
        exported_deps = [":hot"] + COMMON_XNNPACK_DEPS + [
            ":pthreadpool",
            ":interface",
            ":cpuinfo",
        ] + select({
            "DEFAULT": X86_64_XNNPACK_DEPS,
            "ovr_config//cpu:arm32": ARM_XNNPACK_DEPS,
            "ovr_config//cpu:arm64": ARM_XNNPACK_DEPS,
        }),
    )