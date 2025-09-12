include(cmake/install_conan_dependencies.cmake)
include(cmake/install_secondary_dependencies.cmake)

#  |PUBLIC|
macro(InstallDependencies)
    cmake_parse_arguments(install_dep_arg 
        ""
        "ARCH_VER;COMPILER_VER;ONNXRUNTIME_GPU" 
        ""
        ${ARGN}
    )

    message(STATUS "CMAKE | 'InstallDependencies()' | start")

    InstallConanDependencies(ARCH_VER ${install_dep_arg_ARCH_VER} COMPILER_VER ${install_dep_arg_COMPILER_VER})

    InstallSecondaryDependencies(ONNXRUNTIME_GPU ${install_dep_arg_ONNXRUNTIME_GPU})

    message(STATUS "CMAKE | 'InstallDependencies()' | end")
endmacro()