#
# Install itk libraries from source
#

if (NOT itk_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (ExternalSource)
include (BuildSupport)
#include (PatchSupport)

include (python)
include (libpng)
include (libjpeg)
include (libtiff)
include (zlib)

external_source (itk
    4.5.2
    InsightToolkit-4.5.2.tar.gz
    268aa2dec667211c2e07b6f8111a7ee8
    http://downloads.sourceforge.net/project/itk/itk/4.5/)

message ("Installing ${itk_NAME} into FlyEM build area: ${BUILDEM_DIR} ...")

# update paths if a new version of itk is used!
#set (itk_LIBPATH ${BUILDEM_DIR}/lib/itk-4.5)
#include_directories (${BUILDEM_DIR}/include/itk-4.5)

ExternalProject_Add(${itk_NAME}
    DEPENDS             ${python_NAME} ${libpng_NAME} ${libjpeg_NAME} ${libtiff_NAME} ${zlib_NAME}
    PREFIX              ${BUILDEM_DIR}
    URL                 ${itk_URL}
    URL_MD5             ${itk_MD5}
    UPDATE_COMMAND      ""
    PATCH_COMMAND       ""
    CONFIGURE_COMMAND   ${BUILDEM_ENV_STRING} ${CMAKE_COMMAND} ${itk_SRC_DIR}
        -DCMAKE_INSTALL_PREFIX=${BUILDEM_DIR}
        -DBUILD_SHARED_LIBS:BOOL=ON
        -DCMAKE_EXE_LINKER_FLAGS=-L${BUILDEM_LIB_DIR}
        -DCMAKE_MODULE_LINKER_FLAGS=-L${BUILDEM_LIB_DIR}
        -DCMAKE_SHARED_LINKER_FLAGS=-L${BUILDEM_LIB_DIR}
        # These python settings must be manually specified for the mac build (maybe not for linux, but it shouldn't hurt)
        -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_PATH}
        -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARY_FILE}
        -DPY_SITE_PACKAGES_PATH=${PYTHON_PREFIX}/lib/python2.7/site-packages
        -DITK_WRAP_PYTHON:BOOL=ON
        # libpng
        -DITK_USE_SYSTEM_PNG=ON
        -DPNG_PNG_INCLUDE_DIR=${BUILDEM_INCLUDE_DIR} # PNG_PNG looks wrong, but that's what the variable is named.
        -DPNG_LIBRARY=${BUILDEM_LIB_DIR}/libpng.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
        # libjpeg
        -DITK_USE_SYSTEM_JPEG=ON
        -DJPEG_INCLUDE_DIR=${BUILDEM_INCLUDE_DIR}
        -DJPEG_LIBRARY=${BUILDEM_LIB_DIR}/libjpeg.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
        # libtiff
        -DITK_USE_SYSTEM_TIFF=ON
        -DTIFF_INCLUDE_DIR=${BUILDEM_INCLUDE_DIR}
        -DTIFF_LIBRARY=${BUILDEM_LIB_DIR}/libtiff.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
        # zlib
        -DITK_USE_SYSTEM_ZLIB=ON
        -DZLIB_INCLUDE_DIR=${BUILDEM_INCLUDE_DIR}
        -DZLIB_LIBRARY=${BUILDEM_LIB_DIR}/libz.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
    
	# We want itk to be built in parallel if possible.
	# Therefore we use $(MAKE) instead of 'make', which somehow enables sub-make files to use the jobserver correctly.
	# See: http://stackoverflow.com/questions/2942465/cmake-and-parallel-building-with-make-jn
	# And: http://www.cmake.org/pipermail/cmake/2011-April/043720.html
    BUILD_COMMAND       ${BUILDEM_ENV_STRING} $(MAKE)
    #TEST_COMMAND        ${BUILDEM_ENV_STRING} $(MAKE) check
    INSTALL_COMMAND     ${BUILDEM_ENV_STRING} $(MAKE) install
)

set_target_properties(${itk_NAME} PROPERTIES EXCLUDE_FROM_ALL ON)

endif (NOT itk_NAME)
