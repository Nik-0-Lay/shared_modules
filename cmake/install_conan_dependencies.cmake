include(cmake/environment_setup)

option(CONAN_INSTALL "Regenerate Conan dependencies on the next configure" OFF)
option(CONAN_UPDATE "Update Conan dependencies from remotes on the next configure" OFF)

#  |PRIVATE|
# Reuse generated dependencies during normal CMake regeneration. Installation is
# needed only for a missing configuration or an explicit initialization request.
function(RunConanInstall)
    cmake_parse_arguments(arg
        ""
        "ARCH_VER;COMPILER_VER"
        ""
        ${ARGN}
    )

    # These requests apply to this invocation, including every configuration.
    # Consume them before running Conan so a failed refresh cannot leave --update
    # enabled for the next ALL_BUILD / ZERO_CHECK regeneration.
    set(CONAN_INSTALL_REQUESTED "${CONAN_INSTALL}")
    set(CONAN_UPDATE_REQUESTED "${CONAN_UPDATE}")
    set(CONAN_INSTALL OFF CACHE BOOL "Regenerate Conan dependencies on the next configure" FORCE)
    set(CONAN_UPDATE OFF CACHE BOOL "Update Conan dependencies from remotes on the next configure" FORCE)
    set(CONAN_INSTALL OFF PARENT_SCOPE)
    set(CONAN_UPDATE OFF PARENT_SCOPE)

    SetArchitectureVersion(ARCH_VER ${arg_ARCH_VER})
    SetCompilerVersion(COMPILER_VER ${arg_COMPILER_VER})

    set(CONAN_UPDATE_ARGS)
    if(CONAN_UPDATE_REQUESTED)
        list(APPEND CONAN_UPDATE_ARGS --update)
    endif()

    if(CMAKE_CONFIGURATION_TYPES)
        set(CONAN_CONFIGURATIONS ${CMAKE_CONFIGURATION_TYPES})
    elseif(CMAKE_BUILD_TYPE)
        set(CONAN_CONFIGURATIONS "${CMAKE_BUILD_TYPE}")
    else()
        set(CONAN_CONFIGURATIONS Debug Release)
    endif()

    set(CONAN_GENERATORS_DIR "${CMAKE_BINARY_DIR}/generators")
    set(CONAN_TOOLCHAIN_AVAILABLE FALSE)
    if(EXISTS "${CONAN_GENERATORS_DIR}/conan_toolchain.cmake")
        set(CONAN_TOOLCHAIN_AVAILABLE TRUE)
    endif()
    foreach(CONFIG IN LISTS CONAN_CONFIGURATIONS)
        string(TOLOWER "${CONFIG}" CONFIG_LOWER)
        file(GLOB CONAN_CONFIG_DATA
            "${CONAN_GENERATORS_DIR}/*-${CONFIG_LOWER}-${ARCHITECTURE_VERSION}-data.cmake")
        if(NOT CONAN_INSTALL_REQUESTED AND NOT CONAN_UPDATE_REQUESTED
                AND CONAN_TOOLCHAIN_AVAILABLE
                AND CONAN_CONFIG_DATA)
            message(STATUS "Reusing Conan dependencies | configuration: ${CONFIG}")
            continue()
        endif()

        message(STATUS "Installing dependencies | configuration: ${CONFIG}")
        # Keep these overrides in the consumer recipe; dependencies must retain
        # their own layout and generator (for example Ninja when building Qt).
        execute_process(
            COMMAND conan install "${CMAKE_CURRENT_SOURCE_DIR}"
                --output-folder "${CMAKE_BINARY_DIR}"
                -c "&:tools.cmake.cmake_layout:build_folder=."
                -c "&:tools.cmake.cmaketoolchain:generator=${CMAKE_GENERATOR}"
                -pr:b=default
                -pr:h=default
                -s arch=${ARCHITECTURE_VERSION}
                -s compiler.version=${COMPILER_VERSION}
                -s build_type=${CONFIG}
                --build missing
                ${CONAN_UPDATE_ARGS}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            RESULT_VARIABLE CONAN_INSTALL_RESULT
            COMMAND_ECHO STDOUT
        )

        if(NOT CONAN_INSTALL_RESULT EQUAL 0)
            message(FATAL_ERROR "FAILED TO INSTALL DEPENDENCIES | function: RunConanInstall | configuration: ${CONFIG} | conan install result: ${CONAN_INSTALL_RESULT}")
        endif()
        message(STATUS "Dependencies are successfully installed | configuration: ${CONFIG}")
    endforeach()
endfunction()

#  |PUBLIC|
macro(InstallConanDependencies)
    cmake_parse_arguments(install_cd_arg
        ""
        "ARCH_VER;COMPILER_VER"
        ""
        ${ARGN}
    )

    message(STATUS "CMAKE | 'InstallConanDependencies()' | start")

    RunConanInstall(ARCH_VER ${install_cd_arg_ARCH_VER} COMPILER_VER ${install_cd_arg_COMPILER_VER})

    # Include variables and configurations set up by Conan into parent scope.
    include("${CMAKE_BINARY_DIR}/generators/conan_toolchain.cmake")

    message(STATUS "CMAKE | 'InstallConanDependencies()' | end")
endmacro()
