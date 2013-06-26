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
# mcl_parseArguments(<name> <prefix> <specification>... ARGN <arg>...)
function(mcl_parseArguments functionName prefix)
    set(this_usage "mcl_parseArguments(<name> <prefix> <specification>... ARGN <arg>...)")

    list(APPEND specifications)
    list(APPEND arguments)

    set(haveArgn FALSE)
    foreach (argument ${ARGN})
        if (haveArgn)
            list(APPEND arguments ${argument})
        elseif(${argument} STREQUAL "ARGN")
            set(haveArgn TRUE)
        else()
            list(APPEND specifications ${argument})
        endif()
    endforeach()
    if (NOT haveArgn)
        message(FATAL_ERROR "mcl_parseArguments requires the 'ARGN' flag "
                            "argument before the argument list to be parsed. "
                            "Usage: ${this_usage}")
    endif()

    # <debug>
    message("Specifications:")
    foreach(spec ${specifications})
        message("    ${spec}")
    endforeach()
    message("Arguments:")
    foreach(arg ${arguments})
        message("    ${arg}")
    endforeach()
    # </debug>

    _mcl_argParse_getSpecification()
    set(usage "Usage: ${functionName}(${specification})")
    _mcl_argParse_parseSpecification()

    _mcl_argParse_initializeVariables()
    _mcl_argParse_parseArguments()
    _mcl_argParse_storeVariables()
endfunction()


macro(_mcl_argParse_getSpecification)
    list(LENGTH specifications specificationCount)
    if (specificationCount EQUAL 0)
        message(FATAL_ERROR "mcl_parseArguments was called without any argument "
                            "specifications. Proper usage: "
                            ${this_usage})
    elseif (specificationCount EQUAL 1)
        # do stuff
        list(GET specifications 0 specification)
    else()
        message(FATAL_ERROR "mcl_parseArguments does not yet support multiple "
                            "specifications")
    endif()
endmacro()

macro(_mcl_argParse_appendSpecData name type optional)
    list(APPEND allSpecNames ${name})

    list(APPEND specNames     ${name})
    list(APPEND specTypes     ${type})
    if (${optional} STREQUAL "OPTIONAL")
        list(APPEND specOptionals TRUE)
    elseif (${optional} STREQUAL "REQUIRED")
        list(APPEND specOptionals FALSE)
    else()
        message(FATAL_ERROR "we should never get here")
    endif()

    list(LENGTH specNames specCount)
    math(EXPR specMaxIndex "${specCount} - 1")
endmacro()

macro(_mcl_argParse_removeSpecDataAt index)
    foreach (_list Names Types Optionals)
        list(REMOVE_AT spec${_list} ${index})
    endforeach()

    list(LENGTH specNames specCount)
    math(EXPR specMaxIndex "${specCount} - 1")
endmacro()

macro(_mcl_argParse_makeSpecOptional index)
    list(REMOVE_AT specOptionals ${index})
    if (${index} EQUAL specMaxIndex)
        list(APPEND specOptionals TRUE)
    else()
        list(INSERT specOptionals ${index} TRUE)
    endif()
endmacro()

macro(_mcl_argParse_getSpecData index)
    if (${ARGC} EQUAL 2)
        set(_dataPrefix ${ARGV1})
    else()
        set(_dataPrefix "")
    endif()

    if (${index} LESS    ${specCount} AND
        ${index} GREATER -2)
        list(GET specNames     ${index} ${_dataPrefix}name)
        list(GET specTypes     ${index} ${_dataPrefix}type)
        list(GET specOptionals ${index} ${_dataPrefix}optional)
    else()
        set(${_dataPrefix}type "NONE")
    endif()
endmacro()

macro(_mcl_argParse_parseSpecification)
    set(_optionalRE "^\\[(.+)\\]$")
    set(_variableRE "^<(.+)>$")
    set(_listRE     "^<(.+)>...$")

    set(specNames)
    set(specTypes)

    string(REPLACE " " ";" specificationParts ${specification})
    foreach(specPart ${specificationParts})
        set(optional REQUIRED)

        if (${specPart} MATCHES ${_optionalRE})
            string(REGEX REPLACE ${_optionalRE} "\\1" specPart ${specPart})
            set(optional OPTIONAL)
        endif()

        if (${specPart} MATCHES ${_variableRE})
            string(REGEX REPLACE ${_variableRE} "\\1" name ${specPart})

            _mcl_argParse_appendSpecData(${prefix}${name} "variable" ${optional})
        elseif (${specPart} MATCHES ${_listRE})
            string(REGEX REPLACE ${_listRE} "\\1" name ${specPart})

            _mcl_argParse_appendSpecData(${prefix}${name} "list" ${optional})
        else()
            _mcl_argParse_appendSpecData(${prefix}${specPart} "flag" ${optional})
        endif()
    endforeach()

    message("specNames: ${specNames}")
    message("specTypes: ${specTypes}")
endmacro()

macro(_mcl_argParse_initializeVariables)
    foreach(index RANGE specCount)
        _mcl_argParse_getSpecData(${index})

        if (type STREQUAL "variable" OR
            type STREQUAL "list")
            set(${name})
        elseif (type STREQUAL "flag")
            set(${name} FALSE)
        else()
            message(FATAL_ERROR "we should never get here")
        endif()
    endforeach()
endmacro()

macro(_mcl_argParse_parseArguments)
    list(LENGTH arguments argumentCount)
    set(parseDirection BACKWARDS)
    set(index ${specMaxIndex})
    while (index         GREATER -1           AND
           index         LESS    ${specCount} AND
           specCount     GREATER 0            AND
           argumentCount GREATER 0)
        math(EXPR nextIndex "${index} + 1")

        _mcl_argParse_getSpecData(${index})
        _mcl_argParse_getSpecData(${nextIndex} next_)
        set(specCompleted TRUE)
        if (parseDirection STREQUAL BACKWARDS)
            list(GET arguments -1 arg)
        else()
            list(GET arguments 0 arg)
        endif()
        set(consumeArgument TRUE)

        if (${optional}                     AND
            ${next_type}    STREQUAL "flag" AND
            ${prefix}${arg} STREQUAL "${next_name}")
            # our current spec is optional and the current argument matches the
            # following flag spec, so we want to skip the current spec
            set(type "SKIP")
        endif()

        if (type STREQUAL "variable")
            set(${name} ${arg})
        elseif (type STREQUAL "list")
            if (parseDirection STREQUAL BACKWARDS)
                # once we hit a list going backwards we need to parse forwards
                # from the beginning, then the list will be last and the
                # arguments will be parsed correctly
                set(parseDirection FORWARDS)
                set(index 0)

                set(consumeArgument FALSE)
                set(specCompleted   FALSE)
            else()
                list(APPEND ${name} ${arg})

                set(specCompleted FALSE)
                _mcl_argParse_makeSpecOptional(${index})
            endif()
        elseif (type STREQUAL "flag")
            if (${prefix}${arg} STREQUAL ${name})
                set(${name} TRUE)
            else()
                if (optional)
                    set(consumeArgument FALSE)
                else()
                    message(FATAL_ERROR "Invalid arguments passed to ${functionName}."
                                        ${usage})
                endif()
            endif()
        else(type STREQUAL "SKIP")
            set(consumeArgument FALSE)
        else()
            message(FATAL_ERROR "we should never get here")
        endif()

        if (consumeArgument)
            if (parseDirection STREQUAL BACKWARDS)
                list(REMOVE_AT arguments -1)
            else()
                list(REMOVE_AT arguments 0)
            endif()
            list(LENGTH arguments argumentCount)
        endif()
        if (specCompleted)
            if (parseDirection STREQUAL BACKWARDS)
                _mcl_argParse_removeSpecDataAt(${index})
                set(index ${specMaxIndex})
            else()
                math(EXPR index "${index} + 1")
            endif()
        endif()
    endwhile()

    if (parseDirection STREQUAL BACKWARDS)
        set(index 0)            # we want to be going forwards now
    endif()
    while (index LESS ${specCount})
         _mcl_argParse_getSpecData(${index})
         if (optional)
            math(EXPR index "${index} + 1")
        else()
            break()
        endif()
    endwhile()

    if (NOT index EQUAL ${specCount})
        message(FATAL_ERROR "Too few arguments passed to ${functionName}. "
                            ${usage})
    elseif (NOT argumentCount EQUAL 0)
        message(FATAL_ERROR "Too many arguments passed to ${functionName}. "
                            ${usage})
    endif()
endmacro()

macro(_mcl_argParse_storeVariables)
    foreach(name ${allSpecNames})
        set(${name} ${${name}} PARENT_SCOPE)
    endforeach()
endmacro()