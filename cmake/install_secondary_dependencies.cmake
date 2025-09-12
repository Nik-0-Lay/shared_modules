#  |PRIVATE|
# Fetches onnxruntime-gpu based on arguments specified
function(FetchOnnxRuntimeGpu VERSION)
  if(${VERSION} STREQUAL "1.22.0")
    set(THIS_URL https://github.com/microsoft/onnxruntime/releases/download/v1.22.0/onnxruntime-win-x64-gpu-1.22.0.zip)
    set(THIS_URL_HASH SHA256=5B5241716B2628C1AB5E79EE620BE767531021149EE68F30FC46C16263FB94DD)
  elseif(${VERSION} STREQUAL "1.17.1")
    set(THIS_URL https://github.com/microsoft/onnxruntime/releases/download/v1.17.1/onnxruntime-win-x64-gpu-1.17.1.zip)
    set(THIS_URL_HASH SHA256=B7A66F50AD146C2CCB43471D2D3B5AD78084C2D4DDBD3EA82D65F86C867408B2)
  else()
    message(FATAL_ERROR "FAILED TO INSTALL DEPENDENCIES | function: FetchOnnxRuntimeGpu | version: ${VERSION} | reason: version not supported")
  endif()

  include(FetchContent)
  FetchContent_Declare(
    onnxruntime
    URL ${THIS_URL}
    URL_HASH ${THIS_URL_HASH}
  )
endfunction()

#  |PUBLIC|
macro(InstallSecondaryDependencies)
    cmake_parse_arguments(install_sd_arg
        ""
        "ONNXRUNTIME_GPU" 
        ""
        ${ARGN}
    )

    message(STATUS "CMAKE | 'InstallSecondaryDependencies()' | start")

    #  Install onnxruntime-gpu if specified in arguments
    if(install_sd_arg_ONNXRUNTIME_GPU)
        list(GET install_sd_arg_ONNXRUNTIME_GPU 0 ONNXRUNTIME_GPU_VERSION)
        FetchOnnxRuntimeGpu(${ONNXRUNTIME_GPU_VERSION})
        FetchContent_MakeAvailable(onnxruntime)
    endif()

    message(STATUS "CMAKE | 'InstallSecondaryDependencies()' | end")
endmacro()