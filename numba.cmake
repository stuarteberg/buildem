#
# Install numba library from source
#

if (NOT numba_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (ExternalSource)
include (BuildSupport)

include (python)

external_git_repo (numba
    HEAD
    http://github.com/numba/numba)

message ("Installing ${numba_NAME} into FlyEM build area: ${BUILDEM_DIR} ...")
ExternalProject_Add(${numba_NAME}
    DEPENDS             ${python_NAME} # FIXME: numba has lots of dependencies, including cffi, libffi, pycparser, llvmpy, llvm, llvmmath, numpy, Meta, cython, nose
    PREFIX              ${BUILDEM_DIR}
    #URL                 ${numba_URL}
    #URL_MD5             ${numba_MD5}
    GIT_REPOSITORY      ${numba_URL}
    GIT_TAG             ${numba_TAG}
    UPDATE_COMMAND      ""
    PATCH_COMMAND       ""
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ${BUILDEM_ENV_STRING} ${PYTHON_EXE} setup.py install
    BUILD_IN_SOURCE     1
    #TEST_COMMAND        ${BUILDEM_ENV_STRING} ${PYTHON_EXE} setup.py test
    INSTALL_COMMAND     ""
)

set_target_properties(${numba_NAME} PROPERTIES EXCLUDE_FROM_ALL ON)

endif (NOT numba_NAME)
