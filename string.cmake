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
# Usage: mcl_string(JOIN <value>... <separator> <variable>)
#        mcl_string(FOR_NUMBER <number> <singular> <plural> <variable>)
#
#  JOIN will concatenate all of the <values> with <separator> and store the
#       result in <variable>.
#
#  FOR_NUMBER will set <variable> to either <singular> or <plural> as
#             appropriate based on the value of <number>.
function(mcl_string operation)
    if (operation STREQUAL "JOIN")
        _mcl_string_join(${ARGN})
    elseif (operation STREQUAL "FOR_NUMBER")
        _mcl_string_for_number(${ARGN})
    else()
        message(FATAL_ERROR "Invalid MCL string operation '${operation}'. "
                            "Valid operations are: JOIN and FOR_NUMBER")
    endif()
endfunction()


macro(_mcl_string_join)
    if (ARGC LESS 3)
        message(FATAL_ERROR "mcl_string(JOIN) requires at least 3 arguments. "
                            "Usage: mcl_string(JOIN <value>... <separator> "
                            "<variable>)")
    endif()

    set(arguments ${ARGN})
    list(GET arguments -1 variable)
    list(GET arguments -2 separator)
    list(REMOVE_AT arguments -1 -2)

    set(output)
    set(first TRUE)
    foreach(entry ${arguments})
        if (first)
            set(first FALSE)
        else()
            set(output "${output}${separator}")
        endif()
        set(output "${output}${entry}")
    endforeach()

    set(${variable} ${output} PARENT_SCOPE)
endmacro()

macro(_mcl_string_for_number number singular plural variable)
     if (${number} EQUAL 1 OR ${number} EQUAL -1)
        set(${variable} ${singular} PARENT_SCOPE)
    else()
        set(${variable} ${plural} PARENT_SCOPE)
    endif()
endmacro()
