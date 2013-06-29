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

include(mcl/string)


test(join oneValue_setsOriginal)
    set(original "some value")

    mcl_string(JOIN ${original} ", " actual)

    EXPECT_THAT(actual STREQUAL original)
endtest()

test(join twoValues_yieldsStringWithSeparator)
    set(expected "one fish, two fish")

    mcl_string(JOIN "one fish" "two fish" ", " actual)

    EXPECT_THAT(actual STREQUAL expected)
endtest()

test(join manyValues_yieldsStringWithManySeparators)
    set(expected "one fish, two fish, red fish, blue fish")

    mcl_string(JOIN "one fish" "two fish" "red fish" "blue fish" ", " actual)

    EXPECT_THAT(actual STREQUAL expected)
endtest()

test(join valuesFromList_yieldsExpectedSeparatedString)
    set(expected "one fish, two fish, red fish, blue fish")

    set(values "one fish" "two fish" "red fish" "blue fish")

    mcl_string(JOIN ${values} ", " actual)

    EXPECT_THAT(actual STREQUAL expected)
endtest()

test(join manySeparators_yeailsStringsWithCorrectSeparators)
    set(expected1 "one, two, three")
    set(expected2 "one-two-three")
    set(expected3 "one then two then three")

    set(strings one two three)

    mcl_string(JOIN ${strings} ", " actual1)
    mcl_string(JOIN ${strings} "-" actual2)
    mcl_string(JOIN ${strings} " then " actual3)

    EXPECT_THAT(actual1 STREQUAL expected1)
    EXPECT_THAT(actual2 STREQUAL expected2)
    EXPECT_THAT(actual3 STREQUAL expected3)
endtest()


test(for_number one_yieldsSingular)
    set(expected thing)

    mcl_string(FOR_NUMBER 1 thing things actual)

    EXPECT_THAT(actual STREQUAL expected)
endtest()

test(for_number negativeOne_yieldsSingular)
    set(expected thing)

    mcl_string(FOR_NUMBER -1 thing things actual)

    EXPECT_THAT(actual STREQUAL expected)
endtest()

test(for_number zero_yieldsPlural)
    set(expected dollars)

    mcl_string(FOR_NUMBER 0 dollar dollars actual)

    EXPECT_THAT(actual STREQUAL expected)
endtest()

test(for_number largeNumbers_yieldPlural)
    set(expected data)

    mcl_string(FOR_NUMBER 2    datum data actual1)
    mcl_string(FOR_NUMBER 3    datum data actual2)
    mcl_string(FOR_NUMBER 47   datum data actual3)
    mcl_string(FOR_NUMBER 5493 datum data actual4)

    EXPECT_THAT(actual1 STREQUAL expected)
    EXPECT_THAT(actual2 STREQUAL expected)
    EXPECT_THAT(actual3 STREQUAL expected)
    EXPECT_THAT(actual4 STREQUAL expected)
endtest()

test(for_number largeNegativeNumbers_yieldPlural)
    set(expected earnings)

    mcl_string(FOR_NUMBER -2     earning earnings actual1)
    mcl_string(FOR_NUMBER -5     earning earnings actual2)
    mcl_string(FOR_NUMBER -72    earning earnings actual3)
    mcl_string(FOR_NUMBER -81327 earning earnings actual4)

    EXPECT_THAT(actual1 STREQUAL expected)
    EXPECT_THAT(actual2 STREQUAL expected)
    EXPECT_THAT(actual3 STREQUAL expected)
    EXPECT_THAT(actual4 STREQUAL expected)
endtest()

test(for_number decimalNumbers_yieldPlural)
    set(expected "inches")

    mcl_string(FOR_NUMBER -0.3          inch inches actual1)
    mcl_string(FOR_NUMBER -0.0000005    inch inches actual2)
    mcl_string(FOR_NUMBER  0.25         inch inches actual3)
    mcl_string(FOR_NUMBER  0.0000000007 inch inches actual4)

    EXPECT_THAT(actual1 STREQUAL expected)
    EXPECT_THAT(actual2 STREQUAL expected)
    EXPECT_THAT(actual3 STREQUAL expected)
    EXPECT_THAT(actual4 STREQUAL expected)
endtest()
