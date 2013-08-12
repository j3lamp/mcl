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

#! @todo looks like death tests could be useful...


set(val1 42)
set(val2 panama)
set(val3 bridge)
set(val4 ephemaris)
set(fish 1 2 red blue)
set(cheese brie swiss american provalone parmesan mozzarella "pepper jack")

set(empty)


# variable arguments
test(variableArgumentsTest oneVariable_correctValueSet)
    mcl_parse_arguments(test1 prefix_ "<one>" ARGN ${val1})

    EXPECT_THAT(prefix_one EQUAL val1)
endtest()

test(variableArgumentsTest twoVariables_correctValuesSet)
    mcl_parse_arguments(test2 blargh "<A> <B>" ARGN ${val1} ${val2})

    EXPECT_THAT(blarghA    EQUAL val1)
    EXPECT_THAT(blarghB STREQUAL val2)
endtest()

# flag arguments
test(flagArgumentsTest flagThenVariable_correctValuesSet)
    mcl_parse_arguments(test3 prefix_ "FLAG <value>" ARGN FLAG ${val1})

    EXPECT_TRUE(prefix_FLAG "Expected prefix_FLAG to be TRUE, but it wasn't")
    EXPECT_THAT(prefix_value EQUAL val1)
endtest()

test(flagArgumentsTest variableThenFlag_correctValuesSet)
    mcl_parse_arguments(test4 a_ "<var> STUFF" ARGN ${val2} STUFF)

    EXPECT_THAT(a_var STREQUAL val2)
    EXPECT_TRUE(a_STUFF "Expected a_STUFF to be TRUE, but it wasn't")
endtest()

# list arguments
test(listArgumentsTest oneList_oneValue_oneValueSet)
    list(APPEND expectedList ${val1})

    mcl_parse_arguments(test5 l_ "<args>..." ARGN ${expectedList})

    EXPECT_LIST(l_args EQUAL_ORDERED expectedList)
endtest()

test(listArgumentsTest oneList_manyValues_manyValuesSet)
    mcl_parse_arguments(test6 l_ "<args>..." ARGN ${fish})

    EXPECT_LIST(l_args EQUAL_ORDERED fish)
endtest()

test(listArgumentsTest listThenFlagThenList_manyAndMany_correctValuesSet)
    mcl_parse_arguments(test7 l_ "<left>... MIDDLE <right>..."
                       ARGN ${fish} MIDDLE ${cheese})

    EXPECT_LIST(l_left EQUAL_ORDERED fish)
    EXPECT_TRUE(l_MIDDLE "Expected l_MIDDLE to be TRUE, but it wasn't")
    EXPECT_LIST(l_right EQUAL_ORDERED cheese)
endtest()

test(listArgumentsTest listTheFlag_many_correctValuesSet)
    mcl_parse_arguments(test8 l_ "<args>... END" ARGN ${fish} END)

    EXPECT_LIST(l_args EQUAL_ORDERED fish)
    EXPECT_TRUE(l_END "Expected l_END to be TRUE, but it wasn't")
endtest()

test(listArgumentsTest listThenVariable_many_correctValuesSet)
    mcl_parse_arguments(test9 l_ "<args>... <var>" ARGN ${fish} ${val1})

     EXPECT_LIST(l_args EQUAL_ORDERED fish)
     EXPECT_THAT(l_var EQUAL val1)
endtest()

# optional arguments
test(optionalArgumentsTest optionalFlagThenVariable_noFlag_correctValuesSet)
    mcl_parse_arguments(test10 op_ "[FLAG] <arg>" ARGN ${val1})

    EXPECT_FALSE(op_FLAG "Expected op_FLAG to be FALSE, but it wasn't")
    EXPECT_THAT(op_arg EQUAL val1)
endtest()

test(optionalArgumentsTest optionalFlagThenVariable_withFlag_correctValuesSet)
    mcl_parse_arguments(test11 op_ "[FLAG] <arg>" ARGN FLAG ${val1})

    EXPECT_TRUE(op_FLAG "Expected op_FLAG to be TRUE, but it wasn't")
    EXPECT_THAT(op_arg EQUAL val1)
endtest()

test(optionalArgumentsTest variableThenOptionalFlag_noFlag_correctValuesSet)
    mcl_parse_arguments(test12 op_ "<arg> [FLAG]" ARGN ${val1})

    EXPECT_FALSE(op_FLAG "Expected op_FLAG to be FALSE, but it wasn't")
    EXPECT_THAT(op_arg EQUAL val1)
endtest()

test(optionalArgumentsTest variableThenOptionalFlag_withFlag_correctValuesSet)
    mcl_parse_arguments(test13 op_ "<arg> [FLAG]" ARGN ${val1} FLAG)

    EXPECT_TRUE(op_FLAG "Expected op_FLAG to be TRUE, but it wasn't")
    EXPECT_THAT(op_arg EQUAL val1)
endtest()


test(optionalArgumentsTest variableThenOptionalList_noListArguments_listEmpty)
    mcl_parse_arguments(test14 op_ "<arg> [<list>...]" ARGN ${val1})

    EXPECT_THAT(op_arg EQUAL val1)
    EXPECT_LIST(op_list EQUAL_ORDERED empty)
endtest()

test(optionalArgumentsTest variableThenOptionalList_manyListArguments_listFull)
    mcl_parse_arguments(test14 op_ "<arg> [<list>...]" ARGN ${val1} ${cheese})

    EXPECT_THAT(op_arg EQUAL val1)
    EXPECT_LIST(op_list EQUAL_ORDERED cheese)
endtest()

test(optionalArgumentsTest optionalListThenVariable_oneArgument_listEmpty)
    mcl_parse_arguments(test19 op_ "[<list>...] <arg>" ARGN ${val1})

    EXPECT_LIST(op_list EQUAL_ORDERED empty)
    EXPECT_THAT(op_arg EQUAL val1)
endtest()

test(optionalArgumentsTest optionalListThenVariable_manyArguments_listFull)
    mcl_parse_arguments(test20 op_ "[<list>...] <arg>" ARGN ${fish} ${val1})

    EXPECT_LIST(op_list EQUAL_ORDERED fish)
    EXPECT_THAT(op_arg EQUAL val1)
endtest()


test(optionalArgumentsTest varThenOptVar_noSecondVar_firstSetSecondEmpty)
    mcl_parse_arguments(test15 op_ "<arg1> [<arg2>]" ARGN ${val1})

    EXPECT_THAT(op_arg1 EQUAL val1)
    EXPECT_THAT(op_arg2 STREQUAL empty)
endtest()

test(optionalArgumentsTest varThenOptVar_hasSecondVar_firstSetSecondEmpty)
    mcl_parse_arguments(test16 op_ "<arg1> [<arg2>]" ARGN ${val1} ${val2})

    EXPECT_THAT(op_arg1 EQUAL val1)
    EXPECT_THAT(op_arg2 STREQUAL val2)
endtest()

test(optionalArgumentsTest optVarThenVar_onlyOneArg_firstEmptySecondSet)
    mcl_parse_arguments(test17 op_ "[<arg0>] <arg1>" ARGN ${val2})

    EXPECT_THAT(op_arg0 STREQUAL empty)
    EXPECT_THAT(op_arg1 STREQUAL val2)
endtest()

test(optionalArgumentsTest optVarThenVar_twoArgs_firstEmptySecondSet)
    mcl_parse_arguments(test18 op_ "[<arg0>] <arg1>" ARGN ${val1} ${val2})

    EXPECT_THAT(op_arg0 EQUAL val1)
    EXPECT_THAT(op_arg1 STREQUAL val2)
endtest()


# multiple specifications
test(multiSpecTest twoBeginningWithFlags_firstFlagProvided_firstSpecUsed)
    mcl_parse_arguments(mst1 ms_
                       "JOIN <value>... <separator> <variable>"
                       "FOR_NUMBER <number> <singular> <plural> <variable>"
                       ARGN JOIN ${fish} ${val1} ${val2})

    EXPECT_TRUE(ms_JOIN "Expected ms_JOIN to be TRUE, but it wasn't")
    EXPECT_FALSE(ms_FOR_NUMBER "Expected ms_FOR_NUMBER to be FALSE, but it wasn't")
    EXPECT_LIST(ms_value     EQUAL_ORDERED fish)
    EXPECT_THAT(ms_separator EQUAL         val1)
    EXPECT_THAT(ms_variable  STREQUAL      val2)
endtest()

test(multiSpecTest twoBeginningWithFlags_secondFlagProvided_secondSpecUsed)
    mcl_parse_arguments(mst2 ms_
                       "JOIN <value>... <separator> <variable>"
                       "FOR_NUMBER <number> <singular> <plural> <variable>"
                       ARGN FOR_NUMBER ${val1} ${val2} ${val3} ${val4})

    EXPECT_FALSE(ms_JOIN "Expected ms_JOIN to be FALSE, but it wasn't")
    EXPECT_TRUE(ms_FOR_NUMBER "Expected ms_FOR_NUMBER to be TRUE, but it wasn't")
    EXPECT_THAT(ms_number   EQUAL    val1)
    EXPECT_THAT(ms_singular STREQUAL val2)
    EXPECT_THAT(ms_plural   STREQUAL val3)
    EXPECT_THAT(ms_variable STREQUAL val4)
endtest()

test(multiSpecTest secondIsDefaultWithOptionalFlag_opFlagProvided_secondSpecUsed)
    mcl_parse_arguments(mst3 ms_
                       "JOIN <value>... <separator> <variable>"
                       "[FOR_NUMBER] <number> <singular> <plural> <variable>"
                       ARGN  ${val1} ${val2} ${val3} ${val4})

    EXPECT_FALSE(ms_JOIN "Expected ms_JOIN to be FALSE, but it wasn't")
    EXPECT_FALSE(ms_FOR_NUMBER "Expected ms_FOR_NUMBER to be FALSE, but it wasn't")
    EXPECT_THAT(ms_number   EQUAL    val1)
    EXPECT_THAT(ms_singular STREQUAL val2)
    EXPECT_THAT(ms_plural   STREQUAL val3)
    EXPECT_THAT(ms_variable STREQUAL val4)
endtest()

test(multiSpecTest secondIsDefaultWithOptionalVar_varProvided_secondSpecUsed)
    mcl_parse_arguments(mst4 ms_
                       "JOIN <value>... <separator> <variable>"
                       "[<number>] FOR_NUMBER <singular> <plural> <variable>"
                       ARGN  ${val1} FOR_NUMBER ${val2} ${val3} ${val4})

    EXPECT_FALSE(ms_JOIN "Expected ms_JOIN to be FALSE, but it wasn't")
    EXPECT_TRUE(ms_FOR_NUMBER "Expected ms_FOR_NUMBER to be TRUE, but it wasn't")
    EXPECT_THAT(ms_number   EQUAL    val1)
    EXPECT_THAT(ms_singular STREQUAL val2)
    EXPECT_THAT(ms_plural   STREQUAL val3)
    EXPECT_THAT(ms_variable STREQUAL val4)
endtest()

test(multiSpecTest secondIsDefaultWithOptionalVar_varNotProvided_secondSpecUsed)
    mcl_parse_arguments(mst4 ms_
                       "JOIN <value>... <separator> <variable>"
                       "[<number>] FOR_NUMBER <singular> <plural> <variable>"
                       ARGN FOR_NUMBER ${val2} ${val3} ${val4})

    EXPECT_FALSE(ms_JOIN "Expected ms_JOIN to be FALSE, but it wasn't")
    EXPECT_TRUE(ms_FOR_NUMBER "Expected ms_FOR_NUMBER to be TRUE, but it wasn't")
    EXPECT_THAT(ms_number   STREQUAL empty)
    EXPECT_THAT(ms_singular STREQUAL val2)
    EXPECT_THAT(ms_plural   STREQUAL val3)
    EXPECT_THAT(ms_variable STREQUAL val4)
endtest()
