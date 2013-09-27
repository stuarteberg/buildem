#
# Install numba/Meta fork of the python Meta library from source
#

if (NOT numba_meta_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (ExternalSource)
include (BuildSupport)

include (python)

external_git_repo (numba_meta
    HEAD
    http://github.com/numba/Meta)

message ("Installing ${numba_meta_NAME} into FlyEM build area: ${BUILDEM_DIR} ...")
ExternalProject_Add( ${numba_meta_NAME}
    DEPENDS             ${python_NAME}
    PREFIX              ${BUILDEM_DIR}
    #URL                 ${numba_meta_URL}
    #URL_MD5             ${numba_meta_MD5}
    GIT_REPOSITORY      ${numba_meta_URL}
    GIT_TAG             ${numba_meta_TAG}
    UPDATE_COMMAND      ""
    PATCH_COMMAND       ""
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ${BUILDEM_ENV_STRING} ${PYTHON_EXE} setup.py install
    BUILD_IN_SOURCE     1
    #TEST_COMMAND        ${BUILDEM_ENV_STRING} ${PYTHON_EXE} 
    INSTALL_COMMAND     ""
)

set_target_properties(${numba_meta_NAME} PROPERTIES EXCLUDE_FROM_ALL ON)

endif (NOT numba_meta_NAME)
