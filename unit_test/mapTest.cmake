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

include(mcl/map)


macro(EXPECT_MAP_CONTAIN map key)
    mcl_map(KEYS ${map} _keys)
    mcl_string(JOIN ${_keys} ", " _keysString)

    mcl_map(CONTAINS ${map} ${key} _hasKey)
    EXPECT_TRUE(_hasKey "Expected map '${map}' to contain key (${key}) but it "
                        "doesn't. Keys are (${_keysString}).")
endmacro()

macro(EXPECT_MAP_NOT_CONTAIN map key)
    mcl_map(KEYS ${map} _keys)
    mcl_string(JOIN ${_keys} ", " _keysString)

    mcl_map(CONTAINS ${map} ${key} _hasKey)
    EXPECT_FALSE(_hasKey "Expected map '${map}' to not contain key (${key}) "
                         "but it does. Keys are (${_keysString}).")
endmacro()


set(key1 aKey)
set(key2 crazy_key)
set(key3 keyNumber3)
set(val1 "simple value")
set(val2 42)
set(val3 "The quick brown fox jumped over the lazy dog")
set(aList item "second item" 3 "forty two" 5)


function(setGlobalMap)
    mcl_map(SET globalMap1 ${key1} ${val1} GLOBAL)
endfunction()

function(setGlobalMap2)
    mcl_map(SET globalMap2 ${key1} ${val1})
    mcl_map(SET globalMap2 ${key2} ${val2} GLOBAL)
endfunction()

function(makeMapGlobal)
    mcl_map(SET globalMap3 ${key1} ${val1})

    mcl_map(MAKE globalMap3 GLOBAL)
endfunction()


test(mapTest setOne_getWorks)
    mcl_map(SET mapTest ${key1} ${val1})

    mcl_map(GET mapTest ${key1} actualValue)

    EXPECT_THAT(actualValue STREQUAL val1)
endtest()

test(mapTest setSeveral_getWorks)
    mcl_map(SET mapTest ${key1} ${val1})
    mcl_map(SET mapTest ${key2} ${val2})
    mcl_map(SET mapTest ${key3} ${val3})

    mcl_map(GET mapTest ${key1} actual1)
    mcl_map(GET mapTest ${key2} actual2)
    mcl_map(GET mapTest ${key3} actual3)

    EXPECT_THAT(actual1 STREQUAL val1)
    EXPECT_THAT(actual2    EQUAL val2)
    EXPECT_THAT(actual3 STREQUAL val3)
endtest()

test(mapTest setListValue_getYieldsList)
    mcl_map(SET mapTest ${key1} ${aList})

    mcl_map(GET mapTest ${key1} actual)

    EXPECT_LIST(actual EQUAL_ORDERED aList)
endtest()

test(mapTest setSeveral_keysYieldsAllKeys)
    set(expectedKeys ${key1} ${key2} ${key3})

    mcl_map(SET mapTest ${key1} ${val1})
    mcl_map(SET mapTest ${key2} ${val2})
    mcl_map(SET mapTest ${key3} ${val3})

    mcl_map(KEYS mapTest actualKeys)

    EXPECT_LIST(actualKeys EQUAL expectedKeys)
endtest()

test(mapTest setOneKeySeveralTimes_getYeildsLastValueSet)
    mcl_map(SET mapTest ${key1} ${val1})
    mcl_map(SET mapTest ${key1} ${val2})
    mcl_map(SET mapTest ${key1} ${val3})

    mcl_map(GET mapTest ${key1} actualValue)

    EXPECT_THAT(actualValue STREQUAL val3)
endtest()

test(mapTest setOneKeySeveralTimes_keysYeildsOneKey)
    mcl_map(SET mapTest ${key1} ${val1})
    mcl_map(SET mapTest ${key1} ${val2})
    mcl_map(SET mapTest ${key1} ${val3})

    mcl_map(KEYS mapTest actualKeys)

    EXPECT_LIST(actualKeys EQUAL key1)
endtest()

test(mapTest setSeveralKeys_containsYeildsCorrectResults)
    mcl_map(SET mapTest ${key1} ${val1})
    mcl_map(SET mapTest ${key2} ${val2})
    mcl_map(SET mapTest ${key3} ${val3})

    EXPECT_MAP_CONTAIN(mapTest ${key1})
    EXPECT_MAP_CONTAIN(mapTest ${key2})
    EXPECT_MAP_CONTAIN(mapTest ${key3})

    EXPECT_MAP_NOT_CONTAIN(mapTest not_${key1})
    EXPECT_MAP_NOT_CONTAIN(mapTest 3${key2})
    EXPECT_MAP_NOT_CONTAIN(mapTest ${key3}_on_steroids)
endtest()

test(mapTest setGlobally_canGetInParentScope)
    setGlobalMap()

    mcl_map(GET globalMap1 ${key1} actualValue)

    EXPECT_THAT(actualValue STREQUAL val1)
endtest()

test(mapTest setThenSetGlobally_canGetBothInParentScope)
    setGlobalMap2()

    mcl_map(GET globalMap2 ${key1} actual1)
    mcl_map(GET globalMap2 ${key2} actual2)

    EXPECT_THAT(actual1 STREQUAL val1)
    EXPECT_THAT(actual2    EQUAL val2)
endtest()

test(mapTest setThenSetGlobally_keysAvailalbeInParentScope)
    set(expectedKeys ${key1} ${key2})

    setGlobalMap2()

    mcl_map(KEYS globalMap2 actualKeys)

    EXPECT_LIST(actualKeys EQUAL expectedKeys)
endtest()

test(mapTest makeGlobal_canGetInParentScope)
    makeMapGlobal()

    mcl_map(GET globalMap3 ${key1} actualValue)

    EXPECT_THAT(actualValue STREQUAL val1)
endtest()

test(mapTest makeGlobal_keysAvaialbleInParentScope)
    makeMapGlobal()

    mcl_map(KEYS globalMap3 actualKeys)

    EXPECT_LIST(actualKeys EQUAL key1)
endtest()
