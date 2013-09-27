#
# Install llvmpy library from source
#

if (NOT llvmpy_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (ExternalSource)
include (BuildSupport)

include (python)
include (llvm)

external_git_repo (llvmpy
    HEAD
    http://github.com/llvmpy/llvmpy)

message ("Installing ${llvmpy_NAME} into FlyEM build area: ${BUILDEM_DIR} ...")
ExternalProject_Add(${llvmpy_NAME}
    DEPENDS             ${python_NAME} ${llvm_NAME}
    PREFIX              ${BUILDEM_DIR}
    #URL                 ${llvmpy_URL}
    #URL_MD5             ${llvmpy_MD5}
    GIT_REPOSITORY      ${llvmpy_URL}
    GIT_TAG             ${llvmpy_TAG}
    UPDATE_COMMAND      ""
    PATCH_COMMAND       ""
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ${BUILDEM_ENV_STRING} LLVM_CONFIG_PATH=${BUILDEM_DIR}/bin/llvm-config ${PYTHON_EXE} setup.py install
    BUILD_IN_SOURCE     1
    TEST_COMMAND        cd .. && ${BUILDEM_ENV_STRING} ${PYTHON_EXE} -c "import llvm; llvm.test()" # Apparently, the tests can't pass if we run them from the build directory (confused import statement)
    INSTALL_COMMAND     ""
)

set_target_properties(${llvmpy_NAME} PROPERTIES EXCLUDE_FROM_ALL ON)

endif (NOT llvmpy_NAME)
