# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

import unittest

import torch
from executorch.backends.xnnpack.test.tester import Tester


class TestCeil(unittest.TestCase):
    class Ceil(torch.nn.Module):
        def __init__(self):
            super().__init__()

        def forward(self, x):
            z = torch.ceil(x)
            return z

    def test_fp32_ceil(self):
        inputs = (
            torch.Tensor(
                [
                    [0.0, 0.1, 0.5, 0.499],
                    [-0.6, -0.4, 100.1, -1000.1],
                ]
            ),
        )
        (
            Tester(self.Ceil(), inputs)
            .export()
            .check_count({"torch.ops.aten.ceil.default": 1})
            .to_edge()
            .check_count({"executorch_exir_dialects_edge__ops_aten_ceil_default": 1})
            .partition()
            .check_count({"torch.ops.higher_order.executorch_call_delegate": 1})
            .check_not(["executorch_exir_dialects_edge__ops_aten_ceil_default"])
            .to_executorch()
            .serialize()
            .run_method()
            .compare_outputs()
        )
