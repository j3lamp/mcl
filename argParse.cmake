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

#! @todo optional and repeated argument groups
#        "... [FLAG <list>...] ..."
#        "... [FLAG <list>...]... ..."
#        "... (FLAG <var> <var2>)... ..."
#! @todo more examples probably wouldn't hurt

#!
# mcl_parseArguments(<name> <prefix> <specifications>... ARGN <args>...)
#
#  Parse the arguments passed to a function. This should only be used when the
#  in-built parsing provided by CMake isn't sufficient. Argument parsing can get
#  rather complex whenever optional paramters are involved, especially if they
#  are not at the end of the argument list.
#
#  name          - the name of the function whose arguments are being parsed,
#                  this is used when printing error messages if <args> are
#                  invalid
#  prefix        - a variable is set for each parameter listed in
#                  <specification>, all are prefixed by this to avoid name
#                  collisions
#  specification - a string describing the parameters expected by the calling
#                  function
#  args          - the arguments provided to the calling function, usually just
#                  ${ARGN}
#
#  Specifications:
#    Specifications are strings that describe the parameters expected by a
#    function. They are a small description language of their own. This language
#    was designed to use common conventions already used for describing
#    parameters as might be seen in documentation comments or man
#    pages. Parameters are separated by spaces and use certain symbols to
#    describe what kind they are.
#
#    <variable> - A single parameter that whose name is inside the angle
#                 brackets. This argument can have any value.
#    FLAG       - A single literal parameter whose name is the same as its
#                 specification. These are typically written in UPPER_SCORE, but
#                 they needn't be. The argument is expected to be the parameter
#                 name exactly. The value returned will be either TRUE or FALSE.
#    <list>...  - Like a variable this parameter's name is inside the angle
#                 brackets. It accepts one or more arguments. Only one argument
#                 is required to satisfy this type of parameter, additional
#                 values are optional.
#    [optional] - An optional parameter is, of course, one that needn't be
#                 present in the argument list. Unlike the others inside the
#                 square brackets is a parameter specification. It could be a
#                 variable, flag, or list. NOTE: only one parameter can be
#                 inside the square brackets.
#
#    Optional parameters, including additional list values, are included from
#    left to right. List parsing consumes all available arguments until there
#    are no extra arguments left or an argument matching a flag parameter
#    immediately following the list parameter is found. Please keep in mind that
#    some parameter specifications are ambiguous and may not behave as
#    desired. For example a list followed by an optional variable,
#    "<list>... [<variable>]", will result in the variable parameter never being
#    assigned a value. A similar situation occurs with two lists,
#    "<list1>... <list2>...", where list2 will never have more than 1 value.
#
#  Multiple Specifications:
#    If multiple specifications are provided the first item in <args> will be
#    checked to determine which specification should be used for
#    parsing. Because of this each specification must start with a unique
#    required flag parameter. An argument specification can start with one or
#    more optional flag parameters, however they must all be able unique to that
#    specification. Additionally only one specification can start with a
#    non-flag parameter. If the first argumetn does not match any of the flag
#    parameters then the specification that starts with a non-flag parameter
#    will be chosen, if one is provided.
#
#  Specification Examples:
#    These examples are taken from current MCL functions to, hopefully, make
#    them easier to understand.
#
#    mcl_map():    "SET <map> <key> <value>... [GLOBAL]"
#    mcl_string(): "JOIN <value>... <separator> <variable>"
#
#  Multiple Specification Examples:
#    These examples list several specifications, then which will be chosen for a
#    given first argument.
#
#    mcl_string():
#      1: "JOIN <value>... <separator> <variable>"
#      2: "FOR_NUMBER <number> <singular> <plural> <variable>"
#
#      "JOIN":       1
#      "FOR_NUMBER": 2
#
#    optional flag:
#      1: "JOIN <value>... <separator> <variable>"
#      2: "[FOR_NUMBER] <number> <singular> <plural> <variable>"
#
#      "JOIN":        1
#      "FOR_NUMBER":  2
#      anything else: 2
#
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
        list(GET specifications 0 specification)
    else()
        list(LENGTH arguments argumentCount)
        set(matchedSpecification)

        if (argumentCount GREATER 0)
            set(specificationPrefixes)
                # a list of flag parameters for matching against the first
                # argument to determine which specification should be used
            set(specificationPrefixIndices)
                # a list of indices that match entries from the prefix list to
                # their corresponding specification; because of optional
                # parameters there can be more than one prefix per specification
            set(specificationDefault  -1)
                # if there is a prefix that begins with a variable or list
                # (optionally, or required) it becomes the default specification
                # if the first argument does not match any of the prefixes,
                # there can only be *one* default specification

            math(EXPR specificationMaxIndex "${specificationCount} - 1")
            foreach (specIndex RANGE ${specificationMaxIndex})
                list(GET specifications ${specIndex} specification)

                _mcl_argParse_getPrefixesFromSpec()
            endforeach()

            foreach (specificationPrefix ${specificationPrefixes})
                set(${specificationPrefix} FALSE PARENT_SCOPE)
            endforeach()

            list(GET arguments 0 firstArgument)
            list(FIND specificationPrefixes ${prefix}${firstArgument} matchedIndex)
            if (matchedIndex EQUAL -1)
                set(matchedIndex ${specificationDefault})
            endif()
            if (NOT matchedIndex EQUAL -1)
                list(GET specifications ${matchedIndex} matchedSpecification)
            endif()
        endif()

        if (NOT matchedSpecification)
            set(usages)
            foreach(specification ${specifications})
                list(APPEND usages "\n  ${functionName}(${specification})")
            endforeach()
            message(FATAL_ERROR
                    "Incorrect arguments passed to ${functionName}()\n"
                    "Usages:" ${usages})
        endif()

        set(specification ${matchedSpecification})
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
    if (${optional} STREQUAL "REQUIRED")
        math(EXPR specRequiredCount "${specRequiredCount} + 1")
    endif()
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
    set(specOptionals)
    set(specRequiredCount 0)

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
endmacro()

macro(_mcl_argParse_initializeVariables)
    foreach(index RANGE ${specMaxIndex})
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
    math(EXPR optionalArgumentCount "${argumentCount} - ${specRequiredCount}")
    set(index 0)
    while (index         LESS    ${specCount} AND
           argumentCount GREATER 0)
        math(EXPR nextIndex "${index} + 1")

        _mcl_argParse_getSpecData(${index})
        _mcl_argParse_getSpecData(${nextIndex} next_)
        set(specCompleted TRUE)
        list(GET arguments 0 arg)
        set(consumeArgument TRUE)

        if (${optional}                     AND
            ((NOT ${optionalArgumentCount} GREATER 0) OR
             (${next_type}    STREQUAL "flag" AND
              ${prefix}${arg} STREQUAL "${next_name}")))
            # our current spec is optional and the current argument matches the
            # following flag spec, so we want to skip the current spec
            set(type "SKIP")
        endif()

        if (type STREQUAL "variable")
            set(${name} ${arg})
        elseif (type STREQUAL "list")
            list(APPEND ${name} ${arg})

            set(specCompleted FALSE)
            _mcl_argParse_makeSpecOptional(${index})
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
            list(REMOVE_AT arguments 0)
            list(LENGTH arguments argumentCount)
            if (${optional})
                math(EXPR optionalArgumentCount "${optionalArgumentCount} - 1")
            endif()
        endif()
        if (specCompleted)
            math(EXPR index "${index} + 1")
        endif()
    endwhile()

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


macro(_mcl_argParse_getPrefixesFromSpec)
    _mcl_argParse_parseSpecification()

    set(canBeDefault FALSE)
    foreach(index RANGE ${specMaxIndex})
        _mcl_argParse_getSpecData(${index})

        if (type STREQUAL "variable" OR
            type STREQUAL "list")
            set(canBeDefault TRUE)
        elseif (type STREQUAL "flag")
            list(APPEND specificationPrefixes      ${name})
            list(APPEND specificationPrefixIndices ${specIndex})
        else()
            message(FATAL_ERROR "we should never get here")
        endif()

        if (NOT optional)
            break()
        endif()
    endforeach()

    if (canBeDefault)
        if (NOT specificationDefault EQUAL -1)
            message(FATAL_ERROR "When passing multiple specifications to "
                                "mcl_parseArguments() there can only be one "
                                "that does not begin with a required flag "
                                "parameter.")
        endif()

        set(specificationDefault ${specIndex})
    endif()
endmacro()