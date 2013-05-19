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

#! @todo determine the absolute path to this file automagically
set(_mcl_testing_base_path ${CMAKE_SOURCE_DIR}/testing)

#-------------------------------------------------------------------------------
# Functions for adding tests
#-------------------------------------------------------------------------------

# mcl_add_cmake_test_script(<script name> [<module path> [...]])
#
#  Add a CMake test script. This will handle necessary pre-processing, etc. and
#  set up the test to be runable by CTest.
#
#  script name  - the file name of the test script
#  module paths - any module paths the test script will need the current value
#                 of CMAKE_MODULE_PATH is assumed
#
function(mcl_add_cmake_test_script scriptName)
    get_filename_component(testName ${scriptName} NAME_WE)
    set(testFile ${testName}.cmake)

    get_filename_component(inputPath ${scriptName} ABSOLUTE)
    set(outputPath "${CMAKE_CURRENT_BINARY_DIR}/${testFile}")

    add_custom_target(${testFile} ALL # ?
                      ${CMAKE_COMMAND} -P ${_mcl_testing_base_path}/cmake_test_preprocessor.cmake
                      ${inputPath} ${outputPath}

                      DEPENDS ${inputPath}
                      COMMENT "Processing CMake test script \"${testName}\""
                      VERBATIM)

    #! @todo update to use mcl_add_test once written
    add_test(${testName} ${CMAKE_COMMAND} -P
             ${_mcl_testing_base_path}/cmake_test_runner.cmake
             ${outputPath}
             ${CMAKE_MODULE_PATH} ${ARGN})
endfunction()

#-------------------------------------------------------------------------------
# Functions for writing tests
#-------------------------------------------------------------------------------

# setup(<group name>)
#
#  Define a set up macro for the names test group. The resulting macro will be
#  called before each test macro is called, in the same scope.
#
#  group name - the name of the test group for which this set up macro is being
#               defined
#
macro(setup groupName)
    _mcl_cmakeTest_neverCall()
endmacro()

# endsetup()
#
#  End a set up macro.
#
#  @see setup()
#
macro(endsetup)
    _mcl_cmakeTest_neverCall()
endmacro()

# teardown(<group name>)
#
#  Define a tear down macro for the names test group. The resulting macro will
#  be called after each test macro is called, in the same scope.
#
#  group name - the name of the test group for which this tear down macro is
#               being defined
#
macro(teardown groupName)
    _mcl_cmakeTest_neverCall()
endmacro()

# endteardown()
#
#  End a tear down macro.
#
#  @see teardown()
#
macro(endteardown)
    _mcl_cmakeTest_neverCall()
endmacro()

# test(<group name> <test name>)
#
#  Define a test macro in a particular group. All tests must be in a particular
#  group. There can be any number of test groups in a test script. Each test
#  macro will be run in its own scope preceded by its group's set up macro and
#  follwoed by its group's tear down macro.
#
#  group name - the name of the test group for which this test macro is being
#               defined
#  test name  - the name of this test
#
macro(test groupName testName)
    _mcl_cmakeTest_neverCall()
endmacro()

# endtest()
#
#  End a test macro.
#
#  @see test()
#
macro(endtest)
    _mcl_cmakeTest_neverCall()
endmacro()


# EXPECT_TRUE(<variable> <message>[...])
macro(EXPECT_TRUE variable)
    if (NOT ${variable})
        _mcl_cmakeTest_checkFailed()
        message(WARNING ${ARGN})
    endif()
endmacro()

# ASSERT_TRUE(<variable> <message>[...])
macro(ASSERT_TRUE variable)
    _mcl_cmakeTest_assertStart()

    EXPECT_TRUE(${variable} ${ARGN})

    _mcl_cmakeTest_assertEnd()
endmacro()

# EXPECT_FALSE(<variable> <message>[...])
macro(EXPECT_FALSE variable)
    set(__temp_bool ${${variable}})
    mcl_invert(__temp_bool)

    EXPECT_TRUE(__temp_bool ${ARGN})
endmacro()

# ASSERT_FALSE(<variable> <message>[...])
macro(ASSERT_FALSE variable)
    _mcl_cmakeTest_assertStart()

    EXPECT_FALSE(${variable} ${ARGN})

    _mcl_cmakeTest_assertEnd()
endmacro()

# EXPECT_THAT(<actual variable> [NOT] <CONDITION> <expected variable>)
macro(EXPECT_THAT)
    set(__arguments ${ARGN})
    list(GET __arguments  0 __actual)
    list(GET __arguments -1 __expected)

    list(REMOVE_AT __arguments 0 -1)
    set(__condition ${__arguments})
    mcl_list_to_string(__condition " " __conditionString)

    set(__conditionInverted FALSE)
    list(GET __condition 0 __condition0)
    if (__condition0 STREQUAL "NOT")
        list(REMOVE_AT __condition 0)
        set(__conditionInverted TRUE)
    endif()

    if (${__actual} ${__condition} ${__expected})
        set(__checkPassed YES)
    else()
        set(__checkPassed NO)
    endif()
    set(__message "Expected '${__actual}' to ${__conditionString}")
    set(__message "${__message} (${${__expected}}) but was (${${__actual}}).")
    if (__conditionInverted)
        EXPECT_FALSE(__checkPassed ${__message})
    else()
        EXPECT_TRUE(__checkPassed ${__message})
    endif()
endmacro()

# ASSERT_THAT(<actual variable> [NOT] <CONDITION> <expected variable>)
macro(ASSERT_THAT)
    _mcl_cmakeTest_assertStart()

    EXPECT_THAT(${ARGN})

    _mcl_cmakeTest_assertEnd()
endmacro()


# EXPECT_LIST(<actual list variable> [NOT] <CONDITION> < expected list variable>)
macro(EXPECT_LIST)
    set(__arguments ${ARGN})
    list(GET __arguments  0 __actual)
    list(GET __arguments -1 __expected)

    list(REMOVE_AT __arguments 0 -1)
    set(__condition ${__arguments})
    mcl_list_to_string(__condition " " __conditionString)

    set(__conditionInverted FALSE)
    list(GET __condition 0 __condition0)
    if (__condition0 STREQUAL "NOT")
        list(REMOVE_AT __condition 0)
        set(__conditionInverted TRUE)
    endif()

    if (${__condition} STREQUAL "EQUAL_ORDERED")
        _mcl_cmakeTest_checkIfListsAreEqualOrdered(${__actual} ${__expected})
    elseif (${__condition} STREQUAL "EQUAL")
        _mcl_cmakeTest_checkIfListsAreEqual(${__actual} ${__expected})
    else()
        ASSERT_TRUE(FALSE "'${__conditionString}' is not a valid condition for "
                          "list expectations and assertions")
    endif()

    mcl_list_to_string(${__actual}   ", " __actualString)
    mcl_list_to_string(${__expected} ", " __expectedString)
    set(__message "Expected list '${__actual}' to ${__conditionString}")
    set(__message "${__message} (${__expectedString}) but was")
    set(__message "${__message} (${__actualString}).")
    if (__conditionInverted)
        EXPECT_FALSE(__checkPassed ${__message})
    else()
        EXPECT_TRUE(__checkPassed ${__message})
    endif()
endmacro()

# ASSERT_LIST(<actual variable> [NOT] <CONDITION> <expected variable>)
macro(ASSERT_LIST)
    _mcl_cmakeTest_assertStart()

    EXPECT_LIST(${ARGN})

    _mcl_cmakeTest_assertEnd()
endmacro()


#===============================================================================
# Start detail
#===============================================================================

macro(_mcl_cmakeTest_checkFailed)
    set(_mcl_cmakeTest_currentCheckPassed FALSE)
    set(_mcl_cmakeTest_currentTestPassed NO CACHE INTERNAL "")
endmacro()

macro(_mcl_cmakeTest_assertStart)
    set(_mcl_cmakeTest_currentCheckPassed TRUE)
endmacro()

macro(_mcl_cmakeTest_assertEnd)
    if (NOT _mcl_cmakeTest_currentCheckPassed)
        return()
    endif()
endmacro()

macro(_mcl_cmakeTest_checkIfListsAreEqualOrdered actual expected)
    list(LENGTH ${actual}   __check_actualLength)
    list(LENGTH ${expected} __check_expectedLength)

    set(__checkPassed FALSE)
    if (__check_actualLength EQUAL __check_expectedLength)
        set(__check_matchCount 0)
        set(__check_index      0)

        while (__check_index LESS __check_expectedLength)
            LIST(GET ${actual}   ${__check_index} __check_actual)
            LIST(GET ${expected} ${__check_index} __check_expected)

            if (__check_expected MATCHES "^(-|)[0-9]*$" AND
                __check_actual   MATCHES "^(-|)[0-9]*$" AND
                __check_actual   EQUAL __check_expected)
                math(EXPR __check_matchCount "${__check_matchCount} + 1")
            elseif (__check_actual STREQUAL __check_expected)
                math(EXPR __check_matchCount "${__check_matchCount} + 1")
            else()
                break()
            endif()

            math(EXPR __check_index "${__check_index} + 1")
        endwhile()

        if (__check_matchCount EQUAL __check_expectedLength)
            set(__checkPassed TRUE)
        endif()
    endif()
endmacro()

macro(_mcl_cmakeTest_checkIfListsAreEqual actual expected)
    list(LENGTH ${actual}   __check_actualLength)
    list(LENGTH ${expected} __check_expectedLength)

    set(__checkPassed FALSE)
    if (__check_actualLength EQUAL __check_expectedLength)
        set(__check_actual ${${actual}})

        foreach (__check_expected ${${expected}})
            list(FIND __check_actual ${__check_expected} __check_index)

            if (__check_index EQUAL -1)
                break()
            else()
                list(REMOVE_AT __check_actual ${__check_index})
            endif()
        endforeach()

        list(LENGTH __check_actual __check_notMatchedCount)
        if (__check_notMatchedCount EQUAL 0)
            set(__checkPassed TRUE)
        endif()
    endif()
endmacro()


function(_mcl_cmakeTest_neverCall)
    message(FATAL_ERROR
            "CMake test scripts need to processed before they can be run. Call "
            "mcl_add_cmake_test_script(<script name>) isntead of running it "
            "directly")
endfunction()


macro(_mcl_cmakeTest_startTestScript)
    set(_mcl_cmakeTest_ranTestCount 0)
    set(_mcl_cmakeTest_passedTestCount 0)
    set(_mcl_cmakeTest_failedTests)
endmacro()

macro(_mcl_cmakeTest_endTestScript)
    mcl_number_match(${_mcl_cmakeTest_ranTestCount} test tests __test_s)
    message(STATUS "Ran ${_mcl_cmakeTest_ranTestCount} ${__test_s}")

    if (_mcl_cmakeTest_passedTestCount GREATER 0)
        mcl_number_match(${_mcl_cmakeTest_passedTestCount} test tests __test_s)
        message(STATUS "${_mcl_cmakeTest_passedTestCount} ${__test_s} Passed")
    endif()

    list(LENGTH _mcl_cmakeTest_failedTests __failedTestCount)
    if (__failedTestCount GREATER 0)
        mcl_number_match(${__failedTestCount} test tests __test_s)
        message(STATUS "${__failedTestCount} ${__test_s} FAILED, listed below")
        foreach(_mcl_cmakeTest_failedTest ${_mcl_cmakeTest_failedTests})
            message(STATUS "    ${_mcl_cmakeTest_failedTest}")
        endforeach()
        message("")
        message("")
        message(FATAL_ERROR "Tests failed.")
    endif()
endmacro()

macro(_mcl_cmakeTest_startGroup groupName)
    set(_mcl_cmakeTest_currentGroupName ${groupName})
endmacro()

macro(_mcl_cmakeTest_endGroup)
    message("")
endmacro()

macro(_mcl_cmakeTest_startTest testName)
    set(_mcl_cmakeTest_currentTestName ${_mcl_cmakeTest_currentGroupName}.${testName})
    set(_mcl_cmakeTest_currentTestPassed YES CACHE INTERNAL "")

    message(STATUS "Start ${_mcl_cmakeTest_currentTestName}")
endmacro()

macro(_mcl_cmakeTest_endTest)
    math(EXPR _mcl_cmakeTest_ranTestCount
        "${_mcl_cmakeTest_ranTestCount} + 1")
    if (_mcl_cmakeTest_currentTestPassed)
        math(EXPR _mcl_cmakeTest_passedTestCount
            "${_mcl_cmakeTest_passedTestCount} + 1")
        set(_mcl_cmakeTest_testStatus "Passed")
    else()
        list(APPEND _mcl_cmakeTest_failedTests ${_mcl_cmakeTest_currentTestName})
        set(_mcl_cmakeTest_testStatus "FAILED")
    endif()

    message(STATUS "Test  ${_mcl_cmakeTest_currentTestName} "
                   "${_mcl_cmakeTest_testStatus}")
endmacro()

#===============================================================================
# End detail
#===============================================================================


#===============================================================================
# Start other utilities
#===============================================================================

function(mcl_invert variable)
    if (${variable})
        set(${variable} FALSE PARENT_SCOPE)
    else()
        set(${variable} TRUE PARENT_SCOPE)
    endif()
endfunction()

function(mcl_list_to_string listVariable delimeter outputVariable)
    set(output)

    set(first TRUE)
    foreach(entry ${${listVariable}})
        if (first)
            set(first FALSE)
        else()
            set(output "${output}${delimeter}")
        endif()
        set(output "${output}${entry}")
    endforeach()

    set(${outputVariable} ${output} PARENT_SCOPE)
endfunction()

function(mcl_number_match number singular plural variable)
    if (${number} EQUAL 1 OR ${number} EQUAL -1)
        set(${variable} ${singular} PARENT_SCOPE)
    else()
        set(${variable} ${plural} PARENT_SCOPE)
    endif()
endfunction()

#===============================================================================
# End other utilities
#===============================================================================