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
endmacro()