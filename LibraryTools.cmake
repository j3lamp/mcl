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

cmake_minimum_required(VERSION 2.8.11 FATAL_ERROR)


#!
# Usage: mcl_auto_handle_libraries(<target>)
#
#  Set up <target> so that it can run where it is built without any extra steps
#  by either copying the DLLs it requires into the same directory (Windows) or
#  by setting its rpath appropriately (Unix, Linux, Mac OS X). This should be
#  called AFTER target_link_libraries() has been called.
#
function(mcl_auto_handle_libraries target)
    if (WIN32)
        mcl_auto_copy_dlls(${target})
    else()
        mcl_auto_rpath(${target})
    endif()
endfunction()

#!
# Usage: mcl_auto_copy_dlls(<target>)
#
#  Sets up a target to automatically copy the DLLs required by <target> into the
#  <target>'s output directory allowing the target to run without having to
#  modify the DLL search path. This should be called AFTER
#  target_link_libraries() has been called.
#
function(mcl_auto_copy_dlls target)
    get_property(libs TARGET ${target} PROPERTY LINK_LIBRARIES)
    set(dlls)
    foreach (lib ${libs})
        get_filename_component(dll ${lib}.dll ABSOLUTE)
        string(REPLACE "$(Configuration)" "Release" dllSearch "${dll}")
        if (EXISTS "${dllSearch}")
            list(APPEND dlls "${dll}")
        endif()
    endforeach()

    list(LENGTH dlls dllCount)
    if (dllCount EQUAL 0)
        return()
    endif()

    get_property(destination TARGET ${target} PROPERTY LOCATION)
    get_filename_component(destination ${destination} PATH)
    set(copiedDlls)
    foreach (dll ${dlls})
        get_filename_component(dllName ${dll} NAME)
        set(dllDestination "${destination}/${dllName}")

        add_custom_command(OUTPUT "${dllDestination}"
                           COMMAND ${CMAKE_COMMAND} -E copy "${dll}" "${dllDestination}"
                           DEPENDS "${dll}"
                           VERBATIM)

        list(APPEND copiedDlls "${dllDestination}")
    endforeach()
    add_custom_target(copy_dlls_for_${target} DEPENDS ${copiedDlls})
    add_dependencies(${target} copy_dlls_for_${target})
endfunction()

#!
# Usage mcl_auto_rpath(<target>)
#
#  Automatically sets <targets>'s rpath to include all the paths needed to find
#  all of the libraries it requires. Also the <target> is configured to have its
#  rpath set when it is built to simplify development, allowing it to be run in
#  place and eliminating the need for it to be installed. This should be called
#  AFTER target_link_libraries() has been called.
#
function(mcl_auto_rpath target)
    get_property(libs TARGET ${target} PROPERTY LINK_LIBRARIES)
    set(rpath)
    foreach (lib ${libs})
        if (NOT lib MATCHES "^-" AND NOT lib MATCHES ".a$")
            get_filename_component(directory ${lib} PATH)
            list(APPEND rpath ${directory})
        endif()
    endforeach()
    list(REMOVE_DUPLICATES rpath)
    set_property(TARGET ${target} APPEND PROPERTY INSTALL_RPATH ${rpath})
    set_property(TARGET ${target} PROPERTY BUILD_WITH_INSTALL_RPATH TRUE)
endfunction()