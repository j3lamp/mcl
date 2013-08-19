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

#!
# Usage: RuNTestWithCTest.cmake <testName> [<flagFile>]
#
#  This runs the desired test, <testName>, using CTest. If the test fails the
#  output will be printed. If the flagFile argument is provided then the test
#  is only run if the flag file exists.
#

set(CTEST_PREFIX_RE "^[1-9][0-9]*: ")

set(thisFile ${CMAKE_ARGV2})
set(testName ${CMAKE_ARGV3})
set(flagFile ${CMAKE_ARGV4})

if (flagFile AND NOT EXISTS ${flagFile})
    return()
endif()

message("Running ${testName}...")
execute_process(COMMAND ${CMAKE_CTEST_COMMAND} -V -R "^${testName}$"
                RESULT_VARIABLE testResult
                OUTPUT_VARIABLE testOutput
                ERROR_QUIET)

if (NOT testResult STREQUAL "0")
    string(REPLACE "\n" ";" outputLines ${testOutput})
    set(ignoreCount 2) # the first two lines of test output are from CTest not the
                       # test being run and we don't want to see them
    foreach(line ${outputLines})
        if (line MATCHES ${CTEST_PREFIX_RE})
            if (ignoreCount GREATER 0)
                math(EXPR ignoreCount "${ignoreCount} - 1")
            else()
                string(REGEX REPLACE ${CTEST_PREFIX_RE} "" line ${line})
                message("${line}")
            endif()
        endif()
    endforeach()

    message(FATAL_ERROR "Test '${testName}' failed")
else()
    if (flagFile)
        file(REMOVE ${flagFile})
    endif()
endif()
