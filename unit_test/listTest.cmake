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

include(mcl/list)


set(fish 1 2 red blue)

set(empty)


macro(tagItem list index tag)
    list(GET       ${list} ${index} _element)
    list(REMOVE_AT ${list} ${index})

    set(_newElement [${tag}]${_element})
    list(LENGTH ${list} _length)
    if (${index} EQUAL ${_length})
        list(APPEND ${list} ${_newElement})
    else()
        list(INSERT ${list} ${index} ${_newElement})
    endif()
endmacro()


test(processTagsTest oneTag_nothingTagged_listUnchanged)
    set(testList ${fish})

    mcl_list(PROCESS_TAGS testList ot_ TAG)

    EXPECT_LIST(testList EQUAL_ORDERED fish)
    EXPECT_LIST(ot_TAG   EQUAL_ORDERED empty)
endtest()

test(processTagsTest oneTag_oneTagged_listCorrect_tagHasCorrectItem)
    set(testList ${fish})
    list(GET testList 2 expectedTag)
    tagItem(testList 2 TAG)

    mcl_list(PROCESS_TAGS testList ot_ TAG)

    EXPECT_LIST(testList EQUAL_ORDERED fish)
    EXPECT_LIST(ot_TAG   EQUAL_ORDERED expectedTag)
endtest()

test(processTagsTest oneTag_allTagged_listsIdentical)
    set(testList ${fish})
    tagItem(testList 3 TAG)
    tagItem(testList 2 TAG)
    tagItem(testList 1 TAG)
    tagItem(testList 0 TAG)

    mcl_list(PROCESS_TAGS testList ot_ TAG)

    EXPECT_LIST(testList EQUAL_ORDERED fish)
    EXPECT_LIST(ot_TAG   EQUAL_ORDERED fish)
endtest()

test(processTagsTest twoTags_oneTaggedEach_tagsHaveCorrectItem)
    set(testList ${fish})
    list(GET testList 3 expectedONE)
    tagItem(testList 3 ONE)
    list(GET testList 1 expectedTWO)
    tagItem(testList 1 TWO)

    mcl_list(PROCESS_TAGS testList tt_ ONE TWO)

    EXPECT_LIST(testList EQUAL_ORDERED fish)
    EXPECT_LIST(tt_ONE   EQUAL_ORDERED expectedONE)
    EXPECT_LIST(tt_TWO   EQUAL_ORDERED expectedTWO)
endtest()