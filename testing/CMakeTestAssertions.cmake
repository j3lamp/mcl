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

include(mcl/String)
include(mcl/Bool)


#!
# Usage: EXPECT_TRUE(<variable> <message>...)
#
#  Expect the value of <variable> to be TRUE, or something that evaluates to
#  TRUE. If not true then <message>... will be printed along with a backtrace
#  and the current test will be marked as a failure, but continues.
#
#  variable   - the variable to be tested
#  message    - the message to be printed if the variable is not true, the
#               message will be formatted by the message() command.
#
macro(EXPECT_TRUE variable)
    if (NOT ${variable})
        _mcl_cmakeTest_checkFailed()
        message(WARNING ${ARGN})
    endif()
endmacro()

#!
# Usage: ASSERT_TRUE(<variable> <message>...)
#
#  Assert that the value of <variable> must be TRUE, or something that evaluates
#  to TRUE. If not true then <message>... will be printed along with a backtrace
#  and the current test will be marked as a failure and aborted.
#
#  variable   - the variable to be tested
#  message    - the message to be printed if the variable is not true, the
#               message will be formatted by the message() command.
#
macro(ASSERT_TRUE variable)
    _mcl_cmakeTest_assertStart()

    EXPECT_TRUE(${variable} ${ARGN})

    _mcl_cmakeTest_assertEnd()
endmacro()

#!
# Usage: EXPECT_FALSE(<variable> <message>...)
#
#  Expect the value of <variable> to be FALSE, or something that evaluates to
#  FALSE. If not false then <message>... will be printed along with a backtrace
#  and the current test will be marked as a failure, but continues.
#
#  variable   - the variable to be tested
#  message    - the message to be printed if the variable is not false, the
#               message will be formatted by the message() command.
#
macro(EXPECT_FALSE variable)
    # set(__temp_bool ${${variable}})
    # mcl_invert(__temp_bool)

    mcl_bool(__temp_bool NOT ${variable})

    EXPECT_TRUE(__temp_bool ${ARGN})
endmacro()

#!
# Usage: ASSERT_FALSE(<variable> <message>...)
#
#  Assert that the value of <variable> must be FALSE, or something that
#  evaluates to FALSE. If not false then <message>... will be printed along with
#  a backtrace and the current test will be marked as a failure and aborted.
#
#  variable   - the variable to be tested
#  message    - the message to be printed if the variable is not false, the
#               message will be formatted by the message() command.
#
macro(ASSERT_FALSE variable)
    _mcl_cmakeTest_assertStart()

    EXPECT_FALSE(${variable} ${ARGN})

    _mcl_cmakeTest_assertEnd()
endmacro()

#!
# Usage: EXPECT_THAT(<actualVariable> [NOT] <CONDITION> <expectedVariable>)
#
#  Expect <actualVariable> to meet some condition relative to
#  <expectedVariable>. Any binary condition supported by the if() command is
#  supported, e.g. EXPECT_THAT(actual STREQUAL expected) which would check that
#  the value of 'actual' is a string that equals the value of 'expected'. To
#  invert a condition simply precede it by NOT, e.g.
#  EXPECT_THAT( actual NOT EQUAL expected).
#
#  If the expectation is not met a message explaining the failure and a
#  backtrace are printed. The test is also marked as a failure, but continues.
#
#  actualVariable   - the name of the variable with the actual value to be
#                     tested, this should be a value produced by the code under
#                     test
#  'NOT'            - invert the condition used for the comparison
#  CONDITION        - the condition to be used when comparing the actual value
#                     against the expected value, e.g. VERSION_EQUAL
#  expectedVariable - the name of the variable with the value against which the
#                     actual value should be compared
#
macro(EXPECT_THAT)
    set(__arguments ${ARGN})
    list(GET __arguments  0 __actual)
    list(GET __arguments -1 __expected)

    list(REMOVE_AT __arguments 0 -1)
    set(__condition ${__arguments})
    mcl_string(JOIN ${__condition} " " __conditionString)

    set(__conditionInverted FALSE)
    list(GET __condition 0 __condition0)
    if (__condition0 STREQUAL "NOT")
        list(REMOVE_AT __condition 0)
        set(__conditionInverted TRUE)
    endif()

    if ("${${__actual}}" ${__condition} "${${__expected}}")
        set(__checkPassed YES)
    else()
        set(__checkPassed NO)
    endif()
    set(__message "Expected '${__actual}' to ${__conditionString}")
    set(__message "${__message} (${${__expected}}) but was (${${__actual}}).")
    if (__conditionInverted)
        EXPECT_FALSE(__checkPassed ${__message})
    else()
        EXPECT_TRUE(__checkPassed ${__message})
    endif()
endmacro()

#!
# Usage: ASSERT_THAT(<actualVariable> [NOT] <CONDITION> <expectedVariable>)
#
#  Assert that <actualVariable> must meet some condition relative to
#  <expectedVariable>. Any binary condition supported by the if() command is
#  supported, e.g. EXPECT_THAT(actual STREQUAL expected) which would check that
#  the value of 'actual' is a string that equals the value of 'expected'. To
#  invert a condition simply precede it by NOT, e.g.
#  EXPECT_THAT( actual NOT EQUAL expected).
#
#  If the assertion is not met a message explaining the failure and a backtrace
#  are printed. The test is also marked as a failure and aborted.
#
#  actualVariable   - the name of the variable with the actual value to be
#                     tested, this should be a value produced by the code under
#                     test
#  'NOT'            - invert the condition used for the comparison
#  CONDITION        - the condition to be used when comparing the actual value
#                     against the expected value, e.g. VERSION_EQUAL
#  expectedVariable - the name of the variable with the value against which the
#                     actual value should be compared
#
macro(ASSERT_THAT)
    _mcl_cmakeTest_assertStart()

    EXPECT_THAT(${ARGN})

    _mcl_cmakeTest_assertEnd()
endmacro()


#!
# Usage: EXPECT_LIST(<actualListVariable> [NOT] <CONDITION>
#                    <expectedListVariable>)
#
#  Expect that <actualListVariable> meets some condition relative to
#  <expectedListVariable>. EXPECT_THAT does not handle lists so this must be
#  used for list comparisons.
#
#  If the expectation is not met a message explaining the failure and a
#  backtrace are printed. The test is also marked as a failure, but continues.
#
#  actualListVariable   - the name of the variable containing the actual list to
#                         be tested, this should be a list produced by the code
#                         under test.
#  'NOT'                - invert the condition used for the comparison
#  CONDITION            - the condition to be used when comparing the actual
#                         value against the expected value, see below
#  expectedListVariable - name of the variable containing the list against
#                         which the actual list is to be compared
#
#  Conditions:
#    EQUAL         - both lists contain the same number of items and for each
#                    item in the expexted list there is a corresponding equal
#                    item in the actual list
#    EQUAL_ORDERED - both lists contain the same number of items and each item
#                    of the expected list the same item of the actual list is
#                    equal, that is the first item of the expected list is the
#                    same as the first of tem of the actual list, the second is
#                    equal to the second, and so on for each additional item
#
macro(EXPECT_LIST)
    set(__arguments ${ARGN})
    list(GET __arguments  0 __actual)
    list(GET __arguments -1 __expected)

    list(REMOVE_AT __arguments 0 -1)
    set(__condition ${__arguments})
    mcl_string(JOIN ${__condition} " " __conditionString)

    set(__conditionInverted FALSE)
    list(GET __condition 0 __condition0)
    if (__condition0 STREQUAL "NOT")
        list(REMOVE_AT __condition 0)
        set(__conditionInverted TRUE)
    endif()

    if (${__condition} STREQUAL "EQUAL_ORDERED")
        _mcl_cmakeTest_checkIfListsAreEqualOrdered(${__actual} ${__expected})
    elseif (${__condition} STREQUAL "EQUAL")
        _mcl_cmakeTest_checkIfListsAreEqual(${__actual} ${__expected})
    else()
        ASSERT_TRUE(FALSE "'${__conditionString}' is not a valid condition for "
                          "list expectations and assertions")
    endif()

    mcl_string(JOIN ${${__actual}}   ", " __actualString)
    mcl_string(JOIN ${${__expected}} ", " __expectedString)
    set(__message "Expected list '${__actual}' to ${__conditionString}")
    set(__message "${__message} (${__expectedString}) but was")
    set(__message "${__message} (${__actualString}).")
    if (__conditionInverted)
        EXPECT_FALSE(__checkPassed ${__message})
    else()
        EXPECT_TRUE(__checkPassed ${__message})
    endif()
endmacro()

#!
# Usage: ASSERT_LIST(<actualListVariable> [NOT] <CONDITION>
#                    <expectedListVariable>)
#
#  Assert that <actualListVariable> must meet some condition relative to
#  <expectedListVariable>. ASSERT_THAT does not handle lists so this must be
#  used for list comparisons.
#
#  If the assertion is not met a message explaining the failure and a
#  backtrace are printed. The test is also marked as a failure and aborted.
#
#  actualListVariable   - the name of the variable containing the actual list to
#                         be tested, this should be a list produced by the code
#                         under test.
#  'NOT'                - invert the condition used for the comparison
#  CONDITION            - the condition to be used when comparing the actual
#                         value against the expected value, see below
#  expectedListVariable - name of the variable containing the list against
#                         which the actual list is to be compared
#
#  Conditions:
#    EQUAL         - both lists contain the same number of items and for each
#                    item in the expexted list there is a corresponding equal
#                    item in the actual list
#    EQUAL_ORDERED - both lists contain the same number of items and each item
#                    of the expected list the same item of the actual list is
#                    equal, that is the first item of the expected list is the
#                    same as the first of tem of the actual list, the second is
#                    equal to the second, and so on for each additional item
#
macro(ASSERT_LIST)
    _mcl_cmakeTest_assertStart()

    EXPECT_LIST(${ARGN})

    _mcl_cmakeTest_assertEnd()
endmacro()