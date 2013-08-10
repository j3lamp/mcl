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

include(mcl/uncategorized)

function(mcl_print_var var)
    message("${var}: ${${var}}")
endfunction()

function(mcl_print_vars)
    set(varLengths)
    foreach (var ${ARGN})
        string(LENGTH ${var} length)
        list(APPEND varLengths ${length})
    endforeach()
    mcl_math_max(maxVarLength ${varLengths})
    math(EXPR maxVarLength "${maxVarLength} + 1")

    foreach (var ${ARGN})
        string(LENGTH ${var} length)
        math(EXPR padLength "${maxVarLength} - ${length}")
        string(RANDOM LENGTH ${padLength} ALPHABET " " pad)
        message("${var}:${pad}${${var}}")
    endforeach()
endfunction()

function(mcl_print_list list)
    message("${list}:")
    foreach (item ${${list}})
        message("    ${item}")
    endforeach()
endfunction()

function(mcl_print_package package)
    message("Package ${package}:")
    set(standardVars ${package}_INCLUDE_DIR
                     ${package}_INCLUDE_DIRS
                     ${package}_INCLUDES
                     ${package}_LIBRARY
                     ${package}_LIBRARIES
                     ${package}_LIBS
                     ${package}_DEFINITIONS)
    foreach(var ${ARGN})
        list(APPEND specificVars ${package}_${var})
    endforeach()

    mcl_print_vars(${standardVars} ${specificVars})
endfunction()
