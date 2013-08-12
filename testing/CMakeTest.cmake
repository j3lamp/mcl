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

include(mcl/Test)


set(_mcl_testing_base_path ${CMAKE_CURRENT_LIST_DIR})

#-------------------------------------------------------------------------------
# Functions for adding tests
#-------------------------------------------------------------------------------

#!
# Usage: mcl_add_cmake_test_script(<scriptName> [<modulePaths>...])
#
#  Add a CMake test script. This will handle necessary pre-processing, etc. and
#  set up the test to be runable by CTest.
#
#  scriptName  - the file name of the test script
#  modulePaths - any module paths the test script will need, the current value
#                of CMAKE_MODULE_PATH is assumed and needn't be provided
#
function(mcl_add_cmake_test_script scriptName)
    get_filename_component(testName ${scriptName} NAME_WE)
    set(testFile ${testName}.cmake)

    get_filename_component(inputPath ${scriptName} ABSOLUTE)
    set(outputPath "${CMAKE_CURRENT_BINARY_DIR}/${testFile}")

    add_custom_command(
        OUTPUT ${outputPath}
        COMMAND ${CMAKE_COMMAND} -P ${_mcl_testing_base_path}/CMakeTestPreprocessor.cmake
                ${inputPath} ${outputPath}
        DEPENDS ${inputPath}
        COMMENT "Processing CMake test script \"${testName}\""
        VERBATIM)

    add_custom_target(${testFile} ALL DEPENDS ${outputPath})

    mcl_add_test(${testName} ${CMAKE_COMMAND} -P
                 ${_mcl_testing_base_path}/CMakeTestRunner.cmake
                 ${outputPath}
                 ${CMAKE_MODULE_PATH} ${ARGN}
                 DEPENDS ${testFile})
endfunction()


#-------------------------------------------------------------------------------
# Functions for writing tests
#-------------------------------------------------------------------------------

#!
#  Define a set up macro for the named test group. The resulting macro will be
#  called before each test macro is called, in the same scope.
#
#  groupName - the name of the test group for which this set up macro is being
#              defined
#
macro(setup groupName)
    _mcl_cmakeTest_neverCall()
endmacro()

#!
#  End a set up macro.
#
#  @see setup()
#
macro(endsetup)
    _mcl_cmakeTest_neverCall()
endmacro()

#!
#  Define a tear down macro for the names test group. The resulting macro will
#  be called after each test macro is called, in the parent scope.
#
#  groupName - the name of the test group for which this tear down macro is
#              being defined
#
macro(teardown groupName)
    _mcl_cmakeTest_neverCall()
endmacro()

#!
#  End a tear down macro.
#
#  @see teardown()
#
macro(endteardown)
    _mcl_cmakeTest_neverCall()
endmacro()

#!
#  Define a test macro in a particular group. All tests must be in a particular
#  group. There can be any number of test groups in a test script. Each test
#  macro will be run in its own scope preceded by its group's set up macro and
#  follwoed by its group's tear down macro.
#
#  groupName - the name of the test group for which this test macro is being
#              defined
#  testName  - the name of this test
#
macro(test groupName testName)
    _mcl_cmakeTest_neverCall()
endmacro()

#!
#  End a test macro.
#
#  @see test()
#
macro(endtest)
    _mcl_cmakeTest_neverCall()
endmacro()


include(mcl/testing/CMakeTestAssertions)
include(mcl/testing/CMakeTestDetail)
