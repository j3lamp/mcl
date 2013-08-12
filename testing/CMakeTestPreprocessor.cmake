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

# argv are {CMAKE} -P <this file> <input script> <output file>
set(thisFile    ${CMAKE_ARGV2})
set(inputScript ${CMAKE_ARGV3})
set(outputFile  ${CMAKE_ARGV4})

get_filename_component(thisFileName ${thisFile} NAME)

set(cannotRun TRUE)
if (NOT inputScript OR NOT outputFile)
    message("ERROR: ${thisFIleName} requires two arguments: the test script "
            "and the output file")
elseif (NOT EXISTS ${inputScript})
    message("ERROR: '${inputScript}' does not exist and cannot be processed")
else()
    set(cannotRun FALSE)
endif()
if (cannotRun)
    message("")
    message("${thisFile}")
    message("    Process a CMake test script so that it can actually be run.")
    message("")
    message("Usage:")
    message("  ${thisFileName} <input script> <output file>")
    message("")
    message("    input script - the path to the CMake test script to be processed")
    message("    output file  - the path where the output should be written")
    message("")
    message("Note: Generally there is no reason to be calling this script directly. Instead")
    message("use mcl_add_cmake_test_script(<script name>) to add your test script. This will")
    message("automatically set up a target to run this script and create an entry to run the")
    message("output of this script via CTest.")
    message("")
    message(FATAL_ERROR "Cannot run ${thisFile}")
endif()


set(START_OPEN_RE "^[ ]*(setup|teardown|test)[(]")
set(END_NAME_RE "end(setup|teardown|test)")
set(ARGUMENTS_RE "[^)]*")
set(FUNCTION_END_RE "[)][ ]*(#.*|)$")
set(START_RE "${START_OPEN_RE}${ARGUMENTS_RE}${FUNCTION_END_RE}")
set(END_RE   "^[ ]*${END_NAME_RE}[(]${ARGUMENTS_RE}${FUNCTION_END_RE}")


set(parseFailed FALSE CACHE INTERNAL "")
set(testGroups "" CACHE INTERNAL "")


macro(error)
    message("${inputScript}:${lineNumber} error: ${ARGN}")
    set(parseFailed TRUE CACHE INTERNAL "")

    return()
endmacro()

function(processLine variable line)
    if (line MATCHES "${START_RE}")
        string(REGEX REPLACE "${START_OPEN_RE}"   "" arguments "${line}")
        string(REGEX REPLACE "${FUNCTION_END_RE}" "" arguments "${arguments}")
        separate_arguments(arguments)

        if (line MATCHES "setup[(]")
            processStartSetupOrTeradown(output setup ${arguments})
        elseif (line MATCHES "teardown[(]")
            processStartSetupOrTeradown(output teardown ${arguments})
        elseif (line MATCHES "test[(]")
            processStartTest(output ${arguments})
        endif()
    elseif (line MATCHES "${END_RE}")
        string(REGEX REPLACE "${END_NAME_RE}" "endmacro" output "${line}")
    else()
         set(output ${line})
    endif()

    set(${variable} ${output} PARENT_SCOPE)
endfunction()

function(processStartSetupOrTeradown variable which)
    list(LENGTH ARGN argc)
    if (NOT argc EQUAL 1)
        error("The command ${which}() requires one argument, group name")
    endif()

    list(GET ARGN 0 groupName)

    addGlobal(testGroups ${groupName})
    set(${groupName}_has_${which} TRUE CACHE INTERNAL "")

    set(output "macro(${groupName}__${which})" PARENT_SCOPE)
endfunction()

function(processStartTest variable)
    list(LENGTH ARGN argc)
    if (NOT argc EQUAL 2)
        error("The command test() requires two arguments, group name and test name")
    endif()

    list(GET ARGN 0 groupName)
    list(GET ARGN 1 testName)

    addGlobal(testGroups ${groupName})
    addGlobal(${groupName}_tests ${testName})

    set(output "macro(${groupName}_${testName})" PARENT_SCOPE)
endfunction()


function(addGlobal set)
    set(localCopy ${${set}})

    list(APPEND localCopy ${ARGN})
    list(REMOVE_DUPLICATES localCopy)

    set(${set} ${localCopy} CACHE INTERNAL "")
endfunction()

function(fappend)
    file(APPEND ${outputFile} ${ARGN} "\n")
endfunction()


get_filename_component(outputDirectory ${outputFile} ABSOLUTE)
get_filename_component(outputDirectory ${outputDirectory} PATH)

file(STRINGS ${inputScript} lines)

if (NOT EXISTS ${outputDirectory})
    file(MAKE_DIRECTORY ${outputDirectory})
endif()
file(WRITE ${outputFile})

set(lineNumber 0)
foreach (line IN LISTS lines)
    math(EXPR lineNumber "${lineNumber} + 1")
    processLine(line "${line}")

    fappend("${line}")
endforeach()

if (parseFailed)
    message("")
    message(FATAL_ERROR "Unable to parse the CMake test script ${inputScript}")
endif()

fappend()
fappend()
fappend("#-------------------------------------------------------------------------------")
fappend("# Autogenerated test runner code")
fappend("#-------------------------------------------------------------------------------")
fappend()
fappend("_mcl_cmakeTest_startTestScript()")
fappend()

foreach (group ${testGroups})
    fappend("# Group ${group}")
    fappend("_mcl_cmakeTest_startGroup(${group})")
    fappend()

    if (NOT ${group}_has_setup)
        fappend("macro(${group}__setup)")
        fappend("    # none provided")
        fappend("endmacro()")
        fappend()
    endif()
    if (NOT ${group}_has_teardown)
        fappend("macro(${group}__teardown)")
        fappend("    # none provided")
        fappend("endmacro()")
        fappend()
    endif()

    foreach(test ${${group}_tests})
        set(function _run_${group}_${test})

        fappend("_mcl_cmakeTest_startTest(${test})")
        fappend("function(${function})")
        fappend("    ${group}__setup()")
        fappend("    ${group}_${test}()")
        fappend("endfunction()")
        fappend("${function}()")
        fappend("${group}__teardown()")
        fappend("_mcl_cmakeTest_endTest()")
        fappend()
    endforeach()

    fappend("_mcl_cmakeTest_endGroup()")
    fappend()
endforeach()

fappend("_mcl_cmakeTest_endTestScript()")
