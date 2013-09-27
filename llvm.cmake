#
# Install llvm from source
#

if (NOT llvm_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (ExternalSource)
include (BuildSupport)

# Since this is a release, optimizations should be enabled by default.
# If we switch to using their svn repo, we'll have to pass --enable-optimzations
#  to the configure script, or figure out how to set that in their CMake variables.

external_source (llvm
    3.2
    llvm-3.2.src.tar.gz
    71610289bbc819e3e15fdd562809a2d7
    http://llvm.org/releases/3.2)

# llvmpy is not yet compatible with llvm-3.3
#external_source (llvm
#    3.3
#    llvm-3.3.src.tar.gz
#    40564e1dc390f9844f1711c08b08e391
#    http://llvm.org/releases/3.3)

message ("Installing ${llvm_NAME} into FlyEM build area: ${BUILDEM_DIR} ...")
ExternalProject_Add(${llvm_NAME}
    PREFIX              ${BUILDEM_DIR}
    URL                 ${llvm_URL}
    URL_MD5             ${llvm_MD5}
    UPDATE_COMMAND      ""
    PATCH_COMMAND       ""
    CONFIGURE_COMMAND   ${BUILDEM_ENV_STRING} ${CMAKE_COMMAND} ${llvm_SRC_DIR} 
        -DCMAKE_INSTALL_PREFIX=${BUILDEM_DIR}
        -DCMAKE_PREFIX_PATH=${BUILDEM_DIR}
        # Must explicitly enable rtti during make, since llvmpy requires it. The llvmpy documentation claims that adding REQUIRES_RTTI=1 
        #  to the make command will do this, but that doesn't seem to work when building from CMake.  Instead, we manually set the LLVM_REQUIRES_RTTI cache variable.
        -DLLVM_REQUIRES_RTTI=1
    BUILD_COMMAND       ${BUILDEM_ENV_STRING} REQUIRES_RTTI=1 make # See comment above.  REQUIRES_RTTI is being ignored here?
    TEST_COMMAND        ${BUILDEM_ENV_STRING} make check
    INSTALL_COMMAND     ${BUILDEM_ENV_STRING} make install
)

set_target_properties(${llvm_NAME} PROPERTIES EXCLUDE_FROM_ALL ON)

endif (NOT llvm_NAME)