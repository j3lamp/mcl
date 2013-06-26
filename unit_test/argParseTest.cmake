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

include(mcl/argParse)

#! @todo looks like death tests could be useful...


set(val1 42)
set(val2 panama)
set(fish 1 2 red blue)
set(cheese brie swiss american provalone parmesan mozzarella "pepper jack")

set(empty)

# variable arguments
test(parseArgumentsTest oneVariable_correctValueSet)
    mcl_parseArguments(test1 prefix_ "<one>" ARGN ${val1})

    EXPECT_THAT(prefix_one EQUAL val1)
endtest()

test(parseArgumentsTest twoVariables_correctValuesSet)
    mcl_parseArguments(test2 blargh "<A> <B>" ARGN ${val1} ${val2})

    EXPECT_THAT(blarghA    EQUAL val1)
    EXPECT_THAT(blarghB STREQUAL val2)
endtest()

# flag and variable arguments
test(parseArgumentsTest flagThenVariable_correctValuesSet)
    mcl_parseArguments(test3 prefix_ "FLAG <value>" ARGN FLAG ${val1})

    EXPECT_TRUE(prefix_FLAG "Expected prefix_FLAG to be TRUE, but it wasn't")
    EXPECT_THAT(prefix_value EQUAL val1)
endtest()

test(parseArgumentsTest variableThenFlag_correctValuesSet)
    mcl_parseArguments(test4 a_ "<var> STUFF" ARGN ${val2} STUFF)

    EXPECT_THAT(a_var STREQUAL val2)
    EXPECT_TRUE(a_STUFF "Expected a_STUFF to be TRUE, but it wasn't")
endtest()

# list arguments
test(parseArgumentsTest oneList_oneValue_oneValueSet)
    list(APPEND expectedList ${val1})

    mcl_parseArguments(test5 l_ "<args>..." ARGN ${expectedList})

    EXPECT_LIST(l_args EQUAL_ORDERED expectedList)
endtest()

test(parseArgumentsTest oneList_manyValues_manyValuesSet)
    mcl_parseArguments(test6 l_ "<args>..." ARGN ${fish})

    EXPECT_LIST(l_args EQUAL_ORDERED fish)
endtest()

test(parseArgumentsTest listThenFlagThenList_manyAndMany_correctValuesSet)
    mcl_parseArguments(test7 l_ "<left>... MIDDLE <right>..."
                       ARGN ${fish} MIDDLE ${cheese})

    EXPECT_LIST(l_left EQUAL_ORDERED fish)
    EXPECT_TRUE(l_MIDDLE "Expected l_MIDDLE to be TRUE, but it wasn't")
    EXPECT_LIST(l_right EQUAL_ORDERED cheese)
endtest()

test(parseArgumentsTest listTheFlag_many_correctValuesSet)
    mcl_parseArguments(test8 l_ "<args>... END" ARGN ${fish} END)

    EXPECT_LIST(l_args EQUAL_ORDERED fish)
    EXPECT_TRUE(l_END "Expected l_END to be TRUE, but it wasn't")
endtest()

test(parseArgumentsTest listThenVariable_many_correctValuesSet)
    mcl_parseArguments(test9 l_ "<args>... <var>" ARGN ${fish} ${val1})

     EXPECT_LIST(l_args EQUAL_ORDERED fish)
     EXPECT_THAT(l_var EQUAL val1)
endtest()

# optional arguments
test(parseArgumentsTest optionalFlagThenVariable_noFlag_correctValuesSet)
    mcl_parseArguments(test10 op_ "[FLAG] <arg>" ARGN ${val1})

    EXPECT_FALSE(op_FLAG "Expected op_FLAG to be FALSE, but it wasn't")
    EXPECT_THAT(op_arg EQUAL val1)
endtest()

test(parseArgumentsTest optionalFlagThenVariable_withFlag_correctValuesSet)
    mcl_parseArguments(test11 op_ "[FLAG] <arg>" ARGN FLAG ${val1})

    EXPECT_TRUE(op_FLAG "Expected op_FLAG to be TRUE, but it wasn't")
    EXPECT_THAT(op_arg EQUAL val1)
endtest()

test(parseArgumentsTest variableThenOptionalFlag_noFlag_correctValuesSet)
    mcl_parseArguments(test12 op_ "<arg> [FLAG]" ARGN ${val1})

    EXPECT_FALSE(op_FLAG "Expected op_FLAG to be FALSE, but it wasn't")
    EXPECT_THAT(op_arg EQUAL val1)
endtest()

test(parseArgumentsTest variableThenOptionalFlag_withFlag_correctValuesSet)
    mcl_parseArguments(test13 op_ "<arg> [FLAG]" ARGN ${val1} FLAG)

    EXPECT_TRUE(op_FLAG "Expected op_FLAG to be TRUE, but it wasn't")
    EXPECT_THAT(op_arg EQUAL val1)
endtest()


test(parseArgumentsTest variableThenOptionalList_noListArguments_listEmpty)
    mcl_parseArguments(test14 op_ "<arg> [<list>...]" ARGN ${val1})

    EXPECT_THAT(op_arg EQUAL val1)
    EXPECT_LIST(op_list EQUAL_ORDERED empty)
endtest()

test(parseArgumentsTest variableThenOptionalList_manyListArguments_listFull)
    mcl_parseArguments(test14 op_ "<arg> [<list>...]" ARGN ${val1} ${cheese})

    EXPECT_THAT(op_arg EQUAL val1)
    EXPECT_LIST(op_list EQUAL_ORDERED cheese)
endtest()

test(parseArgumentsTest optionalListThenVariable_oneArgument_listEmpty)
    mcl_parseArguments(test19 op_ "[<list>...] <arg>" ARGN ${val1})

    EXPECT_LIST(op_list EQUAL_ORDERED empty)
    EXPECT_THAT(op_arg EQUAL val1)
endtest()

test(parseArgumentsTest optionalListThenVariable_manyArguments_listFull)
    mcl_parseArguments(test20 op_ "[<list>...] <arg>" ARGN ${fish} ${val1})

    EXPECT_LIST(op_list EQUAL_ORDERED fish)
    EXPECT_THAT(op_arg EQUAL val1)
endtest()


test(parseArgumentsTest varThenOptVar_noSecondVar_firstSetSecondEmpty)
    mcl_parseArguments(test15 op_ "<arg1> [<arg2>]" ARGN ${val1})

    EXPECT_THAT(op_arg1 EQUAL val1)
    EXPECT_THAT(op_arg2 STREQUAL empty)
endtest()

test(parseArgumentsTest varThenOptVar_hasSecondVar_firstSetSecondEmpty)
    mcl_parseArguments(test16 op_ "<arg1> [<arg2>]" ARGN ${val1} ${val2})

    EXPECT_THAT(op_arg1 EQUAL val1)
    EXPECT_THAT(op_arg2 STREQUAL val2)
endtest()

test(parseArgumentsTest optVarThenVar_onlyOneArg_firstEmptySecondSet)
    mcl_parseArguments(test17 op_ "[<arg0>] <arg1>" ARGN ${val2})

    EXPECT_THAT(op_arg0 STREQUAL empty)
    EXPECT_THAT(op_arg1 STREQUAL val2)
endtest()

test(parseArgumentsTest optVarThenVar_twoArgs_firstEmptySecondSet)
    mcl_parseArguments(test18 op_ "[<arg0>] <arg1>" ARGN ${val1} ${val2})

    EXPECT_THAT(op_arg0 EQUAL val1)
    EXPECT_THAT(op_arg1 STREQUAL val2)
endtest()
