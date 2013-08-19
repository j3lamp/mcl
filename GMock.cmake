#=============================================================================
# mcl - The Missing CMake Library
# Copyright 2013 John Lamp
#
# Distributed under the OSI-approved Modified BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================

include(mcl/Test.cmake)


#!
# Usage: add_gmock_test(<target> <sources>...)
#
#  Adds a Google Mock based test executable, <target>, built from
#  <sources>... and adds the test so that CTest will run it. Both the executable
#  and the test will be name <target>.
#
function(add_gmock_test target)
    add_executable(${target} ${ARGN})
    target_link_libraries(${target} gmock_main)

    mcl_add_test({$target} ${target})
endfunction()
