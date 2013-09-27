#
# Install llvmmath library from source
#

if (NOT llvmmath_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (ExternalSource)
include (BuildSupport)

include (python)
include (llvmpy)

external_git_repo (llvmmath
    HEAD
    http://github.com/ContinuumIO/llvmmath)

# FIXME: For some reason, setup.py hangs during a call to llvmmath.build.have_clang(), during subprocess.call().  Um, WTH?

message ("Installing ${llvmmath_NAME} into FlyEM build area: ${BUILDEM_DIR} ...")
ExternalProject_Add(${llvmmath_NAME}
    DEPENDS             ${python_NAME} ${llvmpy_NAME}
    PREFIX              ${BUILDEM_DIR}
    #URL                 ${llvmmath_URL}
    #URL_MD5             ${llvmmath_MD5}
    GIT_REPOSITORY      ${llvmmath_URL}
    GIT_TAG             ${llvmmath_TAG}
    UPDATE_COMMAND      ""
    PATCH_COMMAND       ""
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ${BUILDEM_ENV_STRING} ${PYTHON_EXE} setup.py install
    BUILD_IN_SOURCE     1
    #TEST_COMMAND        ${BUILDEM_ENV_STRING} ${PYTHON_EXE} 
    INSTALL_COMMAND     ""
)

set_target_properties(${llvmmath_NAME} PROPERTIES EXCLUDE_FROM_ALL ON)

endif (NOT llvmmath_NAME)
