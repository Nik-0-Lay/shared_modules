include(FetchContent)

macro(FetchCmakeModules)
    cmake_parse_arguments(fetch_cmake_mdls
        ""                       
        "NAME;REPOSITORY;TAG"
        ""                    
        ${ARGN}
    )

    #  Declare module to fetch
    FetchContent_Declare(
        ${fetch_cmake_mdls_NAME}
        GIT_REPOSITORY ${fetch_cmake_mdls_REPOSITORY}
        ${fetch_cmake_mdls_TAG}          
    )

    #  Make contents of the module available
    FetchContent_MakeAvailable(${fetch_cmake_mdls_NAME})

    #  Add the fetched module directory to the cmake modules path
    if(EXISTS "${fetch_cmake_mdls_SRC_DIR}/cmake")
        list(APPEND CMAKE_MODULE_PATH "${fetch_cmake_mdls_SRC_DIR}/cmake")
    else()
        message(FATAL_ERROR "FAILED TO ADD ${fetch_cmake_mdls_NAME} MODULE TO CMAKE_MODULES_PATH 
                | reason: no such path exists 
                | path: ${fetch_cmake_mdls_SRC_DIR}/cmake"
        )
    endif()
endmacro()