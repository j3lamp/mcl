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

include(mcl/ParseArguments)


#!
# Usage: mcl_map(<operation> <map> [arguments])
#
# Operations:
#   SET <map> <key> [<values>...] [GLOBAL]
#     Set a list of values for <key> in <map>. If GLOBAL then the map is stored
#     as a global variable.
#
#   GET <map> <key> <variable>
#     Set <variable> to the value associated iwth <key> in map <map>.
#
#   MAKE <map> GLOBAL
#     Change the map <map> to be stored as a global variable. That is put it in
#     the cache as an internal variable.
#
#   KEYS <map> <variable>
#     Set <variable> to the list of keys in map <map>.
#
#   CONTAINS <map> <key> <variable>
#      Set <variable> to TRUE if ket <key> is in map <map>, otherwise it is set
#      to FALSE.
#
function(mcl_map)
    mcl_parse_arguments(mcl_map mclm_
                        "SET <map> <key> [<values>...] [GLOBAL]"
                        "GET <map> <key> <variable>"
                        "MAKE <map> GLOBAL"
                        "KEYS <map> <variable>"
                        "CONTAINS <map> <key> <variable>"
                        ARGN ${ARGN})

    set(keyList ${mclm_map}_Keys_)
    _mcl_map_key(keyVar ${mclm_map} "${mclm_key}")

    if (mclm_SET)
        _mcl_map_set(${mclm_map} ${mclm_key} ${keyList} ${keyVar} ${mclm_GLOBAL} ${mclm_values})

    elseif (mclm_GET)
        set(${mclm_variable} ${${keyVar}} PARENT_SCOPE)

    elseif (mclm_MAKE)
        # GLOBAL is currently the only option, so there's no need to check
        _mcl_map_in_cache(global ${keyList})
        if (NOT global)
            _mcl_map_make_global(${mclm_map} ${keyList})
        endif()

    elseif (mclm_KEYS)
        set(${mclm_variable} ${${keyList}} PARENT_SCOPE)

    elseif (mclm_CONTAINS)
        list(FIND ${keyList} ${mclm_key} keyIndex)
        if (keyIndex EQUAL -1)
            set(${mclm_variable} FALSE PARENT_SCOPE)
        else()
            set(${mclm_variable} TRUE  PARENT_SCOPE)
        endif()

    endif()
endfunction()


macro(_mcl_map_set map key keyList keyVar global)
    set(_tempKeys ${${keyList}})

    _mcl_map_in_cache(_global ${keyList})
    if (${global})
        if (NOT _global)
            _mcl_map_make_global(${map} ${keyList})
        endif()
        set(_global TRUE)
    endif()

    list(APPEND _tempKeys ${key})
    list(REMOVE_DUPLICATES _tempKeys)

    if (_global)
        _mcl_map_docstring(docstring ${map})

        set(${keyVar}  ${ARGN} CACHE INTERNAL ${docstring})
        set(${keyList} ${_tempKeys}  CACHE INTERNAL ${docstring})
    else()
        set(${keyVar}  ${ARGN} PARENT_SCOPE)
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