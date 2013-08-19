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

include(mcl/List)
include(mcl/Option)
include(mcl/ParseArguments)


#! @todo add an option for excluding tests from all
#! @todo add a list for including only certain tags in check
#! @todo add a list for excluding certain tags from check
#! @todo add an option for auto-running tests


mcl_option(MCL_AUTO_RUN_TESTS
           "Automatically run tets whenever any of their dependencies have been updated."
           ON)

#!
# Enable testing and create the check target. This should be called before
# mcl_add_test() if check functionality is desired.
#
macro(mcl_enable_check)
    enable_testing()
        # enable_testing() does not work as desired if called from within a
        # function. Apparently the scope causes problems which is why this is a
        # macro.

    _mcl_test_enableCheckWorker()
        # To avoid possible scope pollution and work around other problems the
        # bulk of the work for mcl_enable_check() is done in this worker
        # function.
endmacro()

#!
# mcl_add_test(<name> <command>... [DEPENDS] [<dependencies>...] [NO_AUTO])
#
#  Add a test target as add_test() does, if enable_testing() has been called
#  first. If mcl_enable_check() has been called then <dependencies> will be
#  added as dependencies of the check target. Additionally any element of the
#  command can be marked as a target by prepending [TARGET] to it, these will
#  also be added as dependencies of the check target. If NO_AUTO is specified
#  then the test will not be run automatically even if MCL_AUTO_RUN_TESTS is
#  true.
#
#  Example:
#    mcl_add_test(sample [TARGET]myProg --input [TARGET]generatedFile DEPENDS config)
#    - the test command is: myProg --input generatedFile
#    - check will depend on: myProg, generatedFile, and config
#
# @todo add tags so that tests can be categorized
#
function(mcl_add_test)
    mcl_parse_arguments(mcl_add_test mclat_
                        "<name> <command>... [DEPENDS] [<dependencies>...] [NO_AUTO]"
                        ARGN ${ARGN})
    mcl_list(PROCESS_TAGS mclat_command mclat_ TARGET)

    add_test(${mclat_name} ${mclat_command})
    _mcl_test_add_dependencies_to_check(${mclat_TARGET} ${mclat_dependencies})

    if (MCL_AUTO_RUN_TESTS AND NOT mclat_NO_AUTO)
        get_property(mclScriptsDir GLOBAL PROPERTY mclScriptsDir)
        set(testCommand ${CMAKE_COMMAND} -P
                        ${mclScriptsDir}/RunTestWithCTest.cmake ${mclat_name})
        set(testComment "Running test ${mclat_name}")

        set(targets)
        set(generatedFiles)
        foreach (dependency ${mclat_TARGET} ${mclat_dependencies})
            if (TARGET ${dependency})
                list(APPEND  targets ${dependency})
            else()
                list(APPEND generatedFiles ${dependency})
            endif()
        endforeach()

        list(LENGTH targets        targetsLength)
        list(LENGTH generatedFiles generatedFilesLength)
        if (targetsLength        EQUAL 0 AND
            generatedFilesLength EQUAL 0)
            message(AUTHOR_WARNING "Test '${mclat_name}' has no dependencies, "
                                   "auto-running may not work as desired.")

            add_custom_target(run_${mclat_name} ALL
                              ${testCommand}
                              WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                              COMMENT ${testComment}
                              VERBATIM)
        elseif(targetsLength       EQUAL 1 AND
              generatedFilesLength EQUAL 0)
            add_custom_command(TARGET ${mclat_TARGET} POST_BUILD
                               COMMAND ${testCommand}
                               WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                               COMMENT ${testComment}
                               VERBATIM)
        else()
            set(flagFile ${CMAKE_CURRENT_BINARY_DIR}/${mclat_name}.flag)
            foreach (target ${targets})
                add_custom_command(TARGET ${target} POST_BUILD
                                   COMMAND ${CMAKE_COMMAND} -E touch ${flagFile}
                                   VERBATIM)
            endforeach()

            # handle generated files
            set(generateCheck)
            if (generatedFiles)
                set(generateTarget generateFilesFor_${mclat_name})
                set(generateCheck  checkGeneratedFilesFor_${mclat_name})
                add_custom_target(${generateTarget}
                                  DEPENDS ${generatedFiles})

                add_custom_target(${generateCheck}
                                  ${CMAKE_COMMAND} -P
                                    ${mclScriptsDir}/CheckGeneratedFiles.cmake
                                    ${mclat_name} ${flagFile} ${generatedFiles}
                                  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                                  DEPENDS ${generateTarget}
                                  VERBATIM)
            endif()

            add_custom_target(run_${mclat_name} ALL
                              ${testCommand} ${flagFile}
                              WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                              DEPENDS ${targets} ${generateCheck}
                              COMMENT ${testComment}
                              VERBATIM)
        endif()
    endif()
endfunction()


function(_mcl_test_add_dependencies_to_check)
    # if mcl_enable_check() hasn't been called we don't want to do anything
endfunction()

function(_mcl_test_enableCheckWorker)
    add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND}
                      COMMENT "Running tests...")

    # Redefine this function to actually do what it says it will now that we
    # have created the check target.
    function(_mcl_test_add_dependencies_to_check)
        if (NOT "${ARGN}" STREQUAL "")
            add_dependencies(check ${ARGN})
        endif()
    endfunction()
        # Note that because of the use of ${ARGN} we could not define this
        # function inside the mcl_enable_check() macro as it would replace
        # ${ARGN} with nothing, yeilding this function useless.
endfunction()


get_filename_component(mclDir ${CMAKE_CURRENT_LIST_FILE} PATH)
get_filename_component(mclScriptsDir ${mclDir}/scripts ABSOLUTE)
set_property(GLOBAL PROPERTY mclScriptsDir ${mclScriptsDir})
