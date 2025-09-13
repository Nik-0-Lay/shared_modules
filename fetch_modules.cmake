include(FetchContent)

macro(FetchCmakeModules)
    cmake_parse_arguments(fetch_cmake_mdls
        ""                       
        "NAME;REPOSITORY;TAG"
        ""                    
        ${ARGN}
    )

    message(STATUS "CMAKE | 'FetchCmakeModules()' | start")

    if(NOT fetch_cmake_mdls_NAME)
        set(_fetch_cmake_mdls_NAME "cmake_module")
    endif()

    #  Declare module to fetch
    FetchContent_Declare(
        ${fetch_cmake_mdls_NAME}
        GIT_REPOSITORY ${fetch_cmake_mdls_REPOSITORY}
        ${fetch_cmake_mdls_TAG}          
    )

    #  Make contents of the module available
    FetchContent_MakeAvailable(${fetch_cmake_mdls_NAME})

    if(EXISTS "${${fetch_cmake_mdls_NAME}_SOURCE_DIR}/cmake")
        list(APPEND CMAKE_MODULE_PATH "${${fetch_cmake_mdls_NAME}_SOURCE_DIR}/cmake")
    else()
        message(FATAL_ERROR "FAILED TO ADD ${fetch_cmake_mdls_NAME} MODULE TO CMAKE_MODULES_PATH"
            " | function: FetchCmakeModules"
            " | name: ${fetch_cmake_mdls_NAME}"
            " | path: ${${fetch_cmake_mdls_NAME}_SOURCE_DIR}/cmake")
    endif()

    message(STATUS "CMAKE | 'FetchCmakeModules()' | end")
endmacro()