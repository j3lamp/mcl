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

cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

# argv are {CMAKE} -P <this file> <test script file> [<module path> [...]]
set(_mcl_ctr_thisFile   ${CMAKE_ARGV2})
set(_mcl_ctr_testScript ${CMAKE_ARGV3})
set(_mcl_ctr_arg 4)
while(_mcl_ctr_arg LESS ${CMAKE_ARGC})
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_ARGV${_mcl_ctr_arg}})

    math(EXPR _mcl_ctr_arg "${_mcl_ctr_arg} + 1")
endwhile()

set(_mcl_ctr_cannotRunTest YES)
if (NOT _mcl_ctr_testScript)
    message("ERROR: ${_mcl_ctr_thisFile} requires at least one argument, "
                       "the test script to run.")
elseif (NOT EXISTS ${_mcl_ctr_testScript})
    message("ERROR: '${_mcl_ctr_testScript}' does not exist and cannot be run")
else()
    set(_mcl_ctr_cannotRunTest NO)
endif()
if (_mcl_ctr_cannotRunTest)
    get_filename_component(_mcl_ctr_thisFileBase ${_mcl_ctr_thisFile} NAME)

    message("")
    message("${_mcl_ctr_thisFile}")
    message("Usage:")
    message("  ${_mcl_ctr_thisFileBase} <test script> [<module path> [...]]")
    message("")
    message("    test script - the path to the CMake script to be run for this test")
    message("    module path - one or more paths to be appended to the CMAKE_MODULE_PATH")
    message("                  before running the <test script>")
    message("")
    message("Note: Generally there is no reason to be calling this script directly.")
    message("      Instead use mcl_add_cmake_test_script(<script name>) to add your test")
    message("      script. This will automatically handle the necessary pre-processing and")
    message("      running via this script for you.")
    message("")
    message(FATAL_ERROR "Cannot run ${_mcl_ctr_thisFile}")
endif()

include(mcl/testing/cmake_test)


include(${_mcl_ctr_testScript})
