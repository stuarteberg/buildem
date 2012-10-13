#
# Install h5py library from source
#

if (NOT h5py_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (ExternalSource)
include (BuildSupport)

include (python)
include (hdf5)
include (numpy)

external_source (h5py
    2.1.0
    h5py-2.1.0.tar.gz
    a6f0d15cc5e51c322479822f5cc6c1d6
    http://h5py.googlecode.com/files/h5py-2.1.0.tar.gz)

message ("Installing ${h5py_NAME} into FlyEM build area: ${FLYEM_BUILD_DIR} ...")
ExternalProject_Add(${h5py_NAME}
    DEPENDS             ${APP_DEPENDENCIES}
    PREFIX              ${FLYEM_BUILD_DIR}
    URL                 ${h5py_URL}
    URL_MD5             ${h5py_MD5}
    UPDATE_COMMAND      ""
    PATCH_COMMAND       ""
    CONFIGURE_COMMAND   ""
    BUILD_COMMAND       ${FLYEM_ENV_STRING} ${PYTHON_EXE} setup.py build --hdf5=${hdf5_SRC_DIR}
    TEST_COMMAND        ${FLYEM_ENV_STRING} ${PYTHON_EXE} setup.py test
    INSTALL_COMMAND     ${FLYEM_ENV_STRING} ${PYTHON_EXE} setup.py install
)

endif (NOT h5py_NAME)