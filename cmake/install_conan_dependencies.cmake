include(cmake/environment_setup)

option(CONAN_UPDATE "Check Conan remotes for newer dependency versions and revisions" OFF)

#  |PRIVATE|
#  Tries to determine architecture and compiler versions, then installs dependencies using Conan
#  Stops processing and outputs an error message if fails to install the dependencies for any configuration
function(RunConanInstall)
    cmake_parse_arguments(arg
        "" 
        "ARCH_VER;COMPILER_VER" 
        ""
        ${ARGN}
    )

    SetArchitectureVersion(ARCH_VER ${arg_ARCH_VER})
    SetCompilerVersion(COMPILER_VER ${arg_COMPILER_VER})

    # Only request dependency updates when explicitly enabled.
    set(CONAN_UPDATE_ARGS)
    if(CONAN_UPDATE)
        list(APPEND CONAN_UPDATE_ARGS --update)
    endif()

    if(CMAKE_CONFIGURATION_TYPES)
        set(CONAN_CONFIGURATIONS ${CMAKE_CONFIGURATION_TYPES})
    elseif(CMAKE_BUILD_TYPE)
        set(CONAN_CONFIGURATIONS "${CMAKE_BUILD_TYPE}")
    else()
        set(CONAN_CONFIGURATIONS Debug Release)
    endif()

    foreach(CONFIG IN LISTS CONAN_CONFIGURATIONS)
        message(STATUS "Installing dependencies | configuration: ${CONFIG}")
        #  Invoke "conan install" command
        execute_process(
            COMMAND conan install "${CMAKE_CURRENT_SOURCE_DIR}"
                --output-folder "${CMAKE_BINARY_DIR}"
                -c "tools.cmake.cmake_layout:build_folder=."
                -c "tools.cmake.cmaketoolchain:generator=${CMAKE_GENERATOR}"
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
    
        #  Report result of the "conan install" command execution
        if(NOT CONAN_INSTALL_RESULT EQUAL 0)
            message(FATAL_ERROR "FAILED TO INSTALL DEPENDENCIES | function: RunConanInstall | configuration: ${CONFIG} | conan install result: ${CONAN_INSTALL_RESULT}")
        else()
            message(STATUS "Dependencies are successfuly installed | configuration: ${CONFIG}")
        endif()
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

    #  Include variables and configurations set up by conan into parent scope
    include("${CMAKE_BINARY_DIR}/generators/conan_toolchain.cmake")

    message(STATUS "CMAKE | 'InstallConanDependencies()' | end")
endmacro()