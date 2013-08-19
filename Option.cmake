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


include(mcl/Bool)

#!
# Usage mcl_option(<variable> <docstring> [<default>])
#
#  This has the same basic functionality of the option() command built into
#  CMake, however its handling of the default is different. If not provided the
#  default is off unless it has been overriden. It can be overriden in two ways:
#  using the -D<variable>=<default> command line option and second by defining a
#  regular variable named <variable>_DEFUALT. Note that this <variable>_DEFAULT
#  variable will only overried the default value when CMake first configures,
#  once <variable> is in the cache <variable>_DEFUALT will not affect it.
#
function(mcl_option variable docstring)
    mcl_bool(default ${ARGV2})

    get_property(cahceType CACHE ${variable} PROPERTY TYPE)
    if (cacheType STREQUAL UNINITIALIZED)
        mcl_bool(default ${variable})
    elseif (NOT cacheType AND DEFINED ${variable}_DEFAULT)
        mcl_bool(default ${variable}_DEFAULT)
    endif()

    option(${variable} ${docstring} ${default})
endfunction()
