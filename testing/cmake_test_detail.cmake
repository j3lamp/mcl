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