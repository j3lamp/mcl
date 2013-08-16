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
# Usage: mcl_bool(<variable> <expression>...)
#
#  Assign the boolean value of <expression>... to
#  <variable>. <expression>... can be any expression that would be valid for an
#  if statement.
#
function(mcl_bool variable)
    if (${ARGN})
        set(${variable} TRUE PARENT_SCOPE)
    else()
        set(${variable} FALSE PARENT_SCOPE)
    endif()
endfunction()