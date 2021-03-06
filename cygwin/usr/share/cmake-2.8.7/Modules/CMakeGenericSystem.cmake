
#=============================================================================
# Copyright 2004-2009 Kitware, Inc.
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

SET(CMAKE_SHARED_LIBRARY_C_FLAGS "")            # -pic 
SET(CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS "-shared")       # -shared
SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")         # +s, flag for exe link to use shared lib
SET(CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG "")       # -rpath
SET(CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG_SEP "")   # : or empty
SET(CMAKE_INCLUDE_FLAG_C "-I")       # -I
SET(CMAKE_INCLUDE_FLAG_C_SEP "")     # , or empty
SET(CMAKE_LIBRARY_PATH_FLAG "-L")
SET(CMAKE_LIBRARY_PATH_TERMINATOR "")  # for the Digital Mars D compiler the link paths have to be terminated with a "/"
SET(CMAKE_LINK_LIBRARY_FLAG "-l")

SET(CMAKE_LINK_LIBRARY_SUFFIX "")
SET(CMAKE_STATIC_LIBRARY_PREFIX "lib")
SET(CMAKE_STATIC_LIBRARY_SUFFIX ".a")
SET(CMAKE_SHARED_LIBRARY_PREFIX "lib")          # lib
SET(CMAKE_SHARED_LIBRARY_SUFFIX ".so")          # .so
SET(CMAKE_EXECUTABLE_SUFFIX "")          # .exe
SET(CMAKE_DL_LIBS "dl")

SET(CMAKE_FIND_LIBRARY_PREFIXES "lib")
SET(CMAKE_FIND_LIBRARY_SUFFIXES ".so" ".a")

# basically all general purpose OSs support shared libs
SET_PROPERTY(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS TRUE)

SET (CMAKE_SKIP_RPATH "NO" CACHE BOOL
     "If set, runtime paths are not added when using shared libraries.")

SET(CMAKE_VERBOSE_MAKEFILE FALSE CACHE BOOL "If this value is on, makefiles will be generated without the .SILENT directive, and all commands will be echoed to the console during the make.  This is useful for debugging only. With Visual Studio IDE projects all commands are done without /nologo.") 

IF(CMAKE_GENERATOR MATCHES "Makefiles")
  SET(CMAKE_COLOR_MAKEFILE ON CACHE BOOL
    "Enable/Disable color output during build."
    )
  MARK_AS_ADVANCED(CMAKE_COLOR_MAKEFILE)
  IF(DEFINED CMAKE_RULE_MESSAGES)
    SET_PROPERTY(GLOBAL PROPERTY RULE_MESSAGES ${CMAKE_RULE_MESSAGES})
  ENDIF(DEFINED CMAKE_RULE_MESSAGES)
  IF(CMAKE_GENERATOR MATCHES "Unix Makefiles")
    SET(CMAKE_EXPORT_COMPILE_COMMANDS OFF CACHE BOOL
      "Enable/Disable output of compile commands during generation."
      )
    MARK_AS_ADVANCED(CMAKE_EXPORT_COMPILE_COMMANDS)
  ENDIF(CMAKE_GENERATOR MATCHES "Unix Makefiles")
ENDIF(CMAKE_GENERATOR MATCHES "Makefiles")


# GetDefaultWindowsPrefixBase
#
# Compute the base directory for CMAKE_INSTALL_PREFIX based on:
#  - is this 32-bit or 64-bit Windows
#  - is this 32-bit or 64-bit CMake running
#  - what architecture targets will be built
#
function(GetDefaultWindowsPrefixBase var)

  # Try to guess what architecture targets will end up being built as,
  # even if CMAKE_SIZEOF_VOID_P is not computed yet... We need to know
  # the architecture of the targets being built to choose the right
  # default value for CMAKE_INSTALL_PREFIX.
  #
  if("${CMAKE_GENERATOR}" MATCHES "(Win64|IA64)")
    set(arch_hint "x64")
  elseif("${CMAKE_SIZEOF_VOID_P}" STREQUAL "8")
    set(arch_hint "x64")
  elseif("$ENV{LIB}" MATCHES "(amd64|ia64)")
    set(arch_hint "x64")
  endif()

  if(NOT arch_hint)
    set(arch_hint "x86")
  endif()

  # default env in a 64-bit app on Win64:
  # ProgramFiles=C:\Program Files
  # ProgramFiles(x86)=C:\Program Files (x86)
  # ProgramW6432=C:\Program Files
  #
  # default env in a 32-bit app on Win64:
  # ProgramFiles=C:\Program Files (x86)
  # ProgramFiles(x86)=C:\Program Files (x86)
  # ProgramW6432=C:\Program Files
  #
  # default env in a 32-bit app on Win32:
  # ProgramFiles=C:\Program Files
  # ProgramFiles(x86) NOT DEFINED
  # ProgramW6432 NOT DEFINED

  # By default, use the ProgramFiles env var as the base value of
  # CMAKE_INSTALL_PREFIX:
  #
  set(_PREFIX_ENV_VAR "ProgramFiles")

  if ("$ENV{ProgramW6432}" STREQUAL "")
    # running on 32-bit Windows
    # must be a 32-bit CMake, too...
    #message("guess: this is a 32-bit CMake running on 32-bit Windows")
  else()
    # running on 64-bit Windows
    if ("$ENV{ProgramW6432}" STREQUAL "$ENV{ProgramFiles}")
      # 64-bit CMake
      #message("guess: this is a 64-bit CMake running on 64-bit Windows")
      if(NOT "${arch_hint}" STREQUAL "x64")
      # building 32-bit targets
        set(_PREFIX_ENV_VAR "ProgramFiles(x86)")
      endif()
    else()
      # 32-bit CMake
      #message("guess: this is a 32-bit CMake running on 64-bit Windows")
      if("${arch_hint}" STREQUAL "x64")
      # building 64-bit targets
        set(_PREFIX_ENV_VAR "ProgramW6432")
      endif()
    endif()
  endif()

  #if("${arch_hint}" STREQUAL "x64")
  #  message("guess: you are building a 64-bit app")
  #else()
  #  message("guess: you are building a 32-bit app")
  #endif()

  if(NOT "$ENV{${_PREFIX_ENV_VAR}}" STREQUAL "")
    file(TO_CMAKE_PATH "$ENV{${_PREFIX_ENV_VAR}}" _base)
  elseif(NOT "$ENV{SystemDrive}" STREQUAL "")
    set(_base "$ENV{SystemDrive}/Program Files")
  else()
    set(_base "C:/Program Files")
  endif()

  set(${var} "${_base}" PARENT_SCOPE)
endfunction()


# Set a variable to indicate whether the value of CMAKE_INSTALL_PREFIX
# was initialized by the block below.  This is useful for user
# projects to change the default prefix while still allowing the
# command line to override it.
IF(NOT DEFINED CMAKE_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT 1)
ENDIF(NOT DEFINED CMAKE_INSTALL_PREFIX)

# Choose a default install prefix for this platform.
IF(CMAKE_HOST_UNIX)
  SET(CMAKE_INSTALL_PREFIX "/usr/local"
    CACHE PATH "Install path prefix, prepended onto install directories.")
ELSE(CMAKE_HOST_UNIX)
  GetDefaultWindowsPrefixBase(CMAKE_GENERIC_PROGRAM_FILES)
  SET(CMAKE_INSTALL_PREFIX
    "${CMAKE_GENERIC_PROGRAM_FILES}/${PROJECT_NAME}"
    CACHE PATH "Install path prefix, prepended onto install directories.")
  SET(CMAKE_GENERIC_PROGRAM_FILES)
ENDIF(CMAKE_HOST_UNIX)

MARK_AS_ADVANCED(
  CMAKE_SKIP_RPATH
  CMAKE_VERBOSE_MAKEFILE
)
