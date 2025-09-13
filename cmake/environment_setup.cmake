#  |PUBLIC|
#  Sets architecure version in parent scope as ${ARCHITECTURE_VERSION}.
#  Tries to detect architecture a version if not set explicitly.
#  Stops processing and outputs an error message if fails to detect version.
function (SetArchitectureVersion)
    cmake_parse_arguments(set_archv_arg
        ""
        "ARCH_VER" 
        ""
        ${ARGN}
    )

    if (DEFINED set_archv_arg_ARCH_VER)
        set(ARCHITECTURE_VERSION ${set_archv_arg_ARCH_VER} PARENT_SCOPE)
    else()
        message(STATUS "Architecture version was not explicitly set. Detecting architecture...")
        if(CMAKE_SIZEOF_VOID_P EQUAL 4)
            set(ARCHITECTURE_VERSION "x86" PARENT_SCOPE)
        elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(ARCHITECTURE_VERSION "x86_64" PARENT_SCOPE)
        else()
            message(FATAL_ERROR "FAILED TO DETECT ARCHITECTURE VERSION" 
                "| function: SetArchitectureVersion" 
                "| version value: ${ARCHITECTURE_VERSION}" 
                "| CMAKE_SIZEOF_VOID_P: ${CMAKE_SIZEOF_VOID_P}"
            )
        endif()
    endif()
    message(STATUS "Architecture version detected | version: ${ARCHITECTURE_VERSION}")
endfunction()

#  Sets compiler version in parent scope as ${COMPILER_VERSION}.
#  Tries to detect compiler version if not set explicitly.
#  Stops processing and outputs an error message if fails to detect version.
function(SetCompilerVersion)
    cmake_parse_arguments(set_cmplrv_arg
        "" 
        "COMPILER_VER"
        "" 
        ${ARGN}
    )

    if(DEFINED set_cmplrv_arg_COMPILER_VERSION)
        set(COMPILER_VERSION ${set_cmplrv_arg_COMPILER_VER} PARENT_SCOPE)
    else()
        #  MSVC
        if(MSVC AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "19.40")
            set(COMPILER_VERSION 194 PARENT_SCOPE)
        elseif(MSVC AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "19.20")
            set(COMPILER_VERSION 192 PARENT_SCOPE)
        elseif(MSVC AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "19.16")
            set(COMPILER_VERSION 191 PARENT_SCOPE)
        elseif(CMAKE_GENERATOR MATCHES "Visual Studio 15")
            set(COMPILER_VERSION 15 PARENT_SCOPE)
        elseif(CMAKE_GENERATOR MATCHES "Visual Studio 16")
            set(COMPILER_VERSION 16 PARENT_SCOPE)
        elseif(CMAKE_GENERATOR MATCHES "Visual Studio 17")
            set(COMPILER_VERSION 17 PARENT_SCOPE)
        #  Unknown
        else()
            message(FATAL_ERROR "FAILED TO DETECT COMPILER VERSION" 
                " | function: SetCompilerVersion | version value: ${COMPILER_VERSION}" 
                " | MSVC: ${MSVC}" 
                " | CMAKE_CXX_COMPILER_VERSION: ${CMAKE_CXX_COMPILER_VERSION}" 
                " | CMAKE_GENERATOR: ${CMAKE_GENERATOR}"
            )
        endif()
    endif()

    message(STATUS "Compiler version detected | version: ${COMPILER_VERSION}")
endfunction()