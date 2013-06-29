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

include(mcl/parse_arguments)


#!
# Usage: mcl_string(JOIN [<values>...] <separator> <variable>)
#        mcl_string(FOR_NUMBER <number> <singular> <plural> <variable>)
#
#  JOIN will concatenate all of the <values> with <separator> and store the
#       result in <variable>. If there are no <values> provided <variable> is
#       set to an empty string.
#
#  FOR_NUMBER will set <variable> to either <singular> or <plural> as
#             appropriate based on the value of <number>.
#
function(mcl_string)
    mcl_parse_arguments(mcl_string mcls_
                        "JOIN [<values>...] <separator> <variable>"
                        "FOR_NUMBER <number> <singular> <plural> <variable>"
                        ARGN ${ARGN})

    if (mcls_JOIN)
        _mcl_string_join()
    elseif (mcls_FOR_NUMBER)
        _mcl_string_for_number(${mcls_number}
                               ${mcls_singular} ${mcls_plural}
                               ${mcls_variable})
    endif()
endfunction()


macro(_mcl_string_join)
    set(output)
    set(first TRUE)
    foreach(entry ${mcls_values})
        if (first)
            set(first FALSE)
        else()
            set(output "${output}${mcls_separator}")
        endif()
        set(output "${output}${entry}")
    endforeach()

    set(${mcls_variable} ${output} PARENT_SCOPE)
endmacro()

macro(_mcl_string_for_number number singular plural variable)
     if (${number} EQUAL 1 OR ${number} EQUAL -1)
        set(${variable} ${singular} PARENT_SCOPE)
    else()
        set(${variable} ${plural} PARENT_SCOPE)
    endif()
endmacro()
