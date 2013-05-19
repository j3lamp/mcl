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
# Usage: cml_map(<operation> <map> [arguments])
#
# Operations:
#   SET <map> <key> <value> [<value> ...] [GLOBAL]
#     Set a list of values for <key> in <map>. If GLOBAL then the map is stored
#     as a global varialble.
#
#   GET <map> <key> <variable>
#     Set <variable> to the value associated iwth <key> in map <map>.
#
#   MAKE <map> GLOBAL
#     Change the map <map> to be stored as a global varialbe. That is put it in
#     the cache as an internal variable.
#
#   KEYS <map> <variable>
#     Set <varaible> to the list of keys in map <map>.
#
#   CONTAINS <map> <key> <variable>
#      Set <variable> to TRUE if ket <key> is in map <map>, otherwise it is set
#      to FALSE.
#
function(mcl_map operation map thirdArg)
    set(key      ${thirdArg})
    set(state    ${thirdArg})
    set(variable ${thirdArg})

    set(keyList ${map}_Keys_)
    _mcl_map_key(keyVar ${map} ${key})

    if (operation STREQUAL "SET")
        _mcl_map_set(${map} ${key} ${keyList} ${keyVar} ${ARGN})

    elseif (operation STREQUAL "GET")
        list(LENGTH ARGN argnCount)
        if (argnCount EQUAL 1)
            list(GET ARGN 0 variable)

            set(${variable} ${${keyVar}} PARENT_SCOPE)
        elseif (argnCount EQUAL 0)
            message(FATAL_ERROR "Map GET missing <variable> argument. Function"
                                "signature is map(GET <map> <key> <variable>).")
        else()
            message(FATAL_ERROR "Map GET has extra arguments. Function"
                                "signature is map(GET <map> <key> <variable>).")
        endif()

    elseif (operation STREQUAL "MAKE")
        if (state STREQUAL "GLOBAL")
            _mcl_map_in_cache(global ${keyList})
            if (NOT global)
                _mcl_map_make_global(${map} ${keyList})
            endif()
        else()
            message(FATAL_ERROR "Invalid map operation: MAKE <map> GLOBAL is"
                                "the only valid option for the MAKE opertaion")
        endif()

    elseif (operation STREQUAL "KEYS")
        set(${variable} ${${keyList}} PARENT_SCOPE)

    elseif (operation STREQUAL "CONTAINS")
        list(LENGTH ARGN argnCount)
        if (argnCount EQUAL 1)
            list(GET ARGN 0 variable)

            list(FIND ${keyList} ${key} keyIndex)
            if (keyIndex EQUAL -1)
                set(${variable} FALSE PARENT_SCOPE)
            else()
                set(${variable} TRUE  PARENT_SCOPE)
            endif()
        elseif (argnCount EQUAL 0)
            message(FATAL_ERROR "Map CONTAINS missing <variable> argument."
                                "Function signature is map(CONTAINS <map> <key>"
                                "<variable>).")
        else()
            message(FATAL_ERROR "Map CONTAINSE has extra arguments. Function"
                                "signature is map(CONTAINS <map> <key> <variable>).")
        endif()

    else()
        message(FATAL_ERROR "Invalid map operation '${operation}'. Valid"
                            "operations are: SET, GET, MAKE, KEYS, and CONTAINS")
    endif()
endfunction()


macro(_mcl_map_set map key keyList keyVar)
    set(_arguments ${ARGN}) # we need to manipulate this list
    set(_tempKeys ${${keyList}})

    _mcl_map_in_cache(_global ${keyList})
    list(GET _arguments -1 _lastArgument)
    if (_lastArgument STREQUAL "GLOBAL")
        if (NOT _global)
            _mcl_map_make_global(${map} ${keyList})
        endif()

        set(_global TRUE)
        list(REMOVE_AT _arguments -1)
    endif()

    list(APPEND _tempKeys ${key})
    list(REMOVE_DUPLICATES _tempKeys)

    if (_global)
        _mcl_map_docstring(docstring ${map})

        set(${keyVar}  ${_arguments} CACHE INTERNAL ${docstring})
        set(${keyList} ${_tempKeys}  CACHE INTERNAL ${docstring})
    else()
        set(${keyVar}  ${_arguments} PARENT_SCOPE)
        set(${keyList} ${_tempKeys}  PARENT_SCOPE)
    endif()
endmacro()


function(_mcl_map_key variable map key)
    set(${variable} "${map}[${key}]" PARENT_SCOPE)
endfunction()

function(_mcl_map_in_cache variable keyList)
    list(FIND CACHE_VARIABLES ${keyList} keyIndex)
    if (keyIndex EQUAL -1)
        set(${variable} FALSE PARENT_SCOPE)
    else()
        set(${variable} TRUE PARENT_SCOPE)
    endif()
endfunction()

function(_mcl_map_make_global map keyList)
    list(LENGTH ${keyList} keyCount)
    if (keyCount EQUAL 0)
        # nothing has been stored in this map yet, so we have nothing to do
        return()
    endif()

    set(tempKeys ${${keyList}})
    _mcl_map_docstring(docstring ${map})

    foreach(key ${tempKeys})
        _mcl_map_key(keyVar ${map} ${key})

        set(tempVar ${${keyVar}})
        set(${keyVar} ${tempVar} CACHE INTERNAL ${docstring})
    endforeach()

    set(${keyList} ${tempKeys} CACHE INTERNAL ${docstring})
endfunction()

function(_mcl_map_docstring variable map)
    set(${variable} "part of the global map '${map}'" PARENT_SCOPE)
endfunction()