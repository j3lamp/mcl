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

include(mcl/list)
include(mcl/parse_arguments)


#! @todo add an option for excluding tests from all
#! @todo add a list for including only certain tags in check
#! @todo add a list for excluding certain tags from check
#! @todo add an option for auto-running tests

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
# mcl_add_test(<name> <command>... [DEPENDS] [<dependencies>...])
#
#  Add a test target as add_test() does, if enable_testing() has been called
#  first. If mcl_enable_check() has been called then <dependencies> will be
#  added as dependencies of the check target. Additionally any element of the
#  command can be tagged as a target by prepending [TARGET] to it, these will
#  also be added as dependencies of the check target.
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
                        "<name> <command>... [DEPENDS] [<dependencies>...]"
                        ARGN ${ARGN})
    mcl_list(PROCESS_TAGS mclat_command mclat_ TARGET)

    add_test(${mclat_name} ${mclat_command})
    _mcl_test_add_dependencies_to_check(${mclat_TARGET} ${mclat_dependencies})
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
        # Note that because of the use of ${ARGN} we could not create define
        # this function inside the mcl_enable_check() macro as it would replace
        # ${ARGN} with nothing, yeilding this function useless.
endfunction()
