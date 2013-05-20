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

#
# This file is for small random functions that don't yet have a home. It's a
# place for little things that are needed by other modules. Add them here and
# the reorganize them later. At the time of any release *NO* file should include
# this one and this one should be empty, save for these comments.
#

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
