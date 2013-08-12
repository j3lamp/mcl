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
include(mcl/String)

#!
# Usage: mcl_list(PROCESS_TAGS <list> <prefix> <tags>...)
#
#  PROCESS_TAGS processes a <list> with tagged elements by removing the tags and
#               creating a set of lists named after the <tags> prefixed by
#               <prefix>. Tags take the form of a word enclosed in square
#               brackets immediately preceding the element. For example:
#               "[tagged]element", the tag would be "tagged" and the element
#               would be "element".
#
function(mcl_list)
    mcl_parse_arguments(mcl_list mcll_
                        "PROCESS_TAGS <list> <prefix> <tags>..."
                        ARGN ${ARGN})

    if(mcll_PROCESS_TAGS)
        _mcl_list_processTags()
    endif()
endfunction()


macro(_mcl_list_processTags)
    set(tagRe "\\[(.+)\\](.+)")

    foreach (tag ${mcll_tags})
        set(${mcll_prefix}${tag})
    endforeach()

    set(result)
    foreach (item ${${mcll_list}})
        if (item MATCHES ${tagRe})
            string(REGEX REPLACE ${tagRe} "\\1;\\2" parts ${item})
            list(GET parts 0 tag)
            list(GET parts 1 item)

            list(FIND mcll_tags ${tag} tagIndex)
            if (tagIndex EQUAL -1)
                mcl_string(JOIN ${mcll_tags} ", " expectedTags)
                message(FATAL_ERROR "Found unexpected tag (${tag}) in list. "
                                    "Expected tags are: "
                                    ${expectedTags})
            endif()

            list(APPEND result               ${item})
            list(APPEND ${mcll_prefix}${tag} ${item})
        else()
            list(APPEND result ${item})
        endif()
    endforeach()

    set(${mcll_list} ${result} PARENT_SCOPE)
    foreach (tag ${mcll_tags})
        set(${mcll_prefix}${tag} ${${mcll_prefix}${tag}} PARENT_SCOPE)
    endforeach()
endmacro()
