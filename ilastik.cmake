#
# Install ilastik headless (non-GUI) from source
#
# Ilastik is composed of 3 git repos, 2 of which are necessary for headless mode.
#
# lazyflow
# ilastik
# volumina (for gui builds)
#
# Also, you must build lazyflow/lazyflow/drtile with CMake to produce drtile.so shared library.
# This is done in the CONFIGURE_COMMAND below and the shared library is saved in the
# drtile source directory.

if (NOT ilastik_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (ExternalSource)
include (BuildSupport)
include (TemplateSupport)

include (vigra)
include (h5py)
include (psutil)
include (blist)
include (greenlet)
include (cylemon)
include (yapsy)
#include (pgmlink)
include (scikit-learn)

# select the desired ilastik commit
set(DEFAULT_ILASTIK_VERSION "flyem-20130702")
IF(NOT DEFINED ILASTIK_VERSION)
    SET(ILASTIK_VERSION "${DEFAULT_ILASTIK_VERSION}")
ENDIF()
SET(ILASTIK_VERSION ${ILASTIK_VERSION}
    CACHE STRING "Specify ilastik branch/tag/commit to be used (default: ${DEFAULT_ILASTIK_VERSION})"
    FORCE)
    
external_git_repo (ilastik
    ${ILASTIK_VERSION}
    http://github.com/janelia-flyem/flyem-ilastik
    ilastik) # Override ilastik_NAME and ilastik_SRC_DIR variables by providing this extra arg
    
set(lazyflow_SRC_DIR "${ilastik_SRC_DIR}/lazyflow")

if("${ILASTIK_VERSION}" STREQUAL "master")

    set(ILASTIK_UPDATE_COMMAND cd lazyflow && git checkout master && git pull && cd .. && cd volumina && git checkout master && git pull && cd .. && cd ilastik && git checkout master && git pull && cd ..)

else()

    set(ILASTIK_UPDATE_COMMAND git checkout ${ILASTIK_VERSION} && git submodule update)
    
endif()
    
message ("Installing ${ilastik_NAME}/${ILASTIK_VERSION} into FlyEM build area: ${BUILDEM_DIR} ...")

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    # On Mac OS X, building drtile requires explicitly setting several cmake cache variables
    ExternalProject_Add(${ilastik_NAME}
        DEPENDS             ${vigra_NAME} ${h5py_NAME} ${psutil_NAME} 
                            ${blist_NAME} ${greenlet_NAME} ${yapsy_NAME}
                            ${cylemon_NAME} ${scikit-learn_NAME}
        SOURCE_DIR          ${ilastik_SRC_DIR}
        GIT_REPOSITORY      ${ilastik_URL}
        UPDATE_COMMAND      ${ILASTIK_UPDATE_COMMAND}
        PATCH_COMMAND       ""
        CONFIGURE_COMMAND   ${BUILDEM_ENV_STRING} ${CMAKE_COMMAND}
            -DLIBRARY_OUTPUT_PATH=${lazyflow_SRC_DIR}/lazyflow/drtile
            -DCMAKE_PREFIX_PATH=${BUILDEM_DIR}
            -DPYTHON_EXECUTABLE=${PYTHON_EXE}
            -DPYTHON_INCLUDE_DIR=${PYTHON_PREFIX}/include/python2.7
            "-DPYTHON_LIBRARY=${PYTHON_PREFIX}/lib/libpython2.7.${BUILDEM_PLATFORM_DYLIB_EXTENSION}"
            -DPYTHON_NUMPY_INCLUDE_DIR=${PYTHON_PREFIX}/lib/python2.7/site-packages/numpy/core/include
            -DVIGRA_NUMPY_CORE_LIBRARY=${PYTHON_PREFIX}/lib/python2.7/site-packages/vigra/vigranumpycore.so
            ${lazyflow_SRC_DIR}/lazyflow/drtile
        BUILD_COMMAND       ${BUILDEM_ENV_STRING} make
        TEST_COMMAND        ${BUILDEM_DIR}/bin/ilastik_headless_test
        INSTALL_COMMAND     ""
    )
else()
    # On Linux, building drtile requires less explicit configuration
    # The explicit configuration above would probably work, but let's keep this simple...
    ExternalProject_Add(${ilastik_NAME}
        DEPENDS             ${vigra_NAME} ${h5py_NAME} ${psutil_NAME} 
                            ${blist_NAME} ${greenlet_NAME} ${yapsy_NAME}
                            ${cylemon_NAME} ${scikit-learn_NAME}
        SOURCE_DIR          ${ilastik_SRC_DIR}
        GIT_REPOSITORY      ${ilastik_URL}
        UPDATE_COMMAND      ${ILASTIK_UPDATE_COMMAND}
        PATCH_COMMAND       ""
        CONFIGURE_COMMAND   ${BUILDEM_ENV_STRING} ${CMAKE_COMMAND}
            -DLIBRARY_OUTPUT_PATH=${lazyflow_SRC_DIR}/lazyflow/drtile
#            -DCMAKE_PREFIX_PATH=${BUILDEM_DIR}
#            -DVIGRA_ROOT=${BUILDEM_DIR}
            ${lazyflow_SRC_DIR}/lazyflow/drtile
        BUILD_COMMAND       ${BUILDEM_ENV_STRING} make
        TEST_COMMAND        ${BUILDEM_DIR}/bin/ilastik_headless_test
        INSTALL_COMMAND     ""
    )
endif()

file(RELATIVE_PATH ILASTIK_DIR_RELATIVE ${BUILDEM_DIR} ${ilastik_SRC_DIR})
file(RELATIVE_PATH PYTHON_PREFIX_RELATIVE ${BUILDEM_DIR} ${PYTHON_PREFIX})

##############################
### Generate setenv script ###
##############################

set(SETENV_ILASTIK_HEADLESS setenv_ilastik_headless)

# Create a cmake helper script to execute at build-time
set( ilastik_setenv_script_creation_helper
	 "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/generate_ilastik_setenv.cmake" )
file( WRITE ${ilastik_setenv_script_creation_helper}
		    "configure_file(${TEMPLATE_DIR}/${SETENV_ILASTIK_HEADLESS}.in ${BUILDEM_DIR}/bin/${SETENV_ILASTIK_HEADLESS}.sh @ONLY)" )

# Generate environment setting script at build time using the helper cmake-script
ExternalProject_add_step( ${ilastik_NAME} ilastik_headless_setenv
	DEPENDEES   download
	COMMAND ${CMAKE_COMMAND} 
			-DSETENV_ILASTIK=${SETENV_ILASTIK_HEADLESS}
			-DILASTIK_DIR_RELATIVE=${ILASTIK_DIR_RELATIVE}
			-DPYTHON_PREFIX_RELATIVE=${PYTHON_PREFIX_RELATIVE}
			-DBUILDEM_LD_LIBRARY_VAR=${BUILDEM_LD_LIBRARY_VAR}
			-P ${ilastik_setenv_script_creation_helper}
	COMMENT "Creating ${SETENV_ILASTIK_HEADLESS}.sh" )

#######################################
### Generate headless launch script ###
#######################################

# Create a cmake helper script to execute at build-time
set( ilastik_headless_launch_creation_helper
	 "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/generate_ilastik_headless_launch.cmake" )
file( WRITE ${ilastik_headless_launch_creation_helper}
		    "configure_file(${TEMPLATE_DIR}/ilastik_script.template ${BUILDEM_DIR}/bin/ilastik_headless @ONLY)" )

# Generate environment setting script at build time using the helper cmake-script
ExternalProject_add_step( ${ilastik_NAME} ilastik_headless
	DEPENDEES   ilastik_headless_setenv
	COMMAND ${CMAKE_COMMAND} 
			-DSETENV_ILASTIK=${SETENV_ILASTIK_HEADLESS}
			-DLAUNCH_ILASTIK="ilastik/ilastik/workflows/pixelClassification/pixelClassificationWorkflowMainHeadless.py"
			-P ${ilastik_headless_launch_creation_helper}
	COMMENT "Creating launch script: ilastik_headless" )

#####################################
### Generate headless test script ###
#####################################

# Create a cmake helper script to execute at build-time
set( ilastik_headless_test_creation_helper
	 "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/generate_ilastik_headless_test.cmake" )
file( WRITE ${ilastik_headless_test_creation_helper}
		    "configure_file(${TEMPLATE_DIR}/ilastik_script.template ${BUILDEM_DIR}/bin/ilastik_headless_test @ONLY)" )

# Generate environment setting script at build time using the helper cmake-script
ExternalProject_add_step( ${ilastik_NAME} ilastik_headless_test
	DEPENDEES   ilastik_headless
	DEPENDERS   test
	COMMAND ${CMAKE_COMMAND} 
			-DSETENV_ILASTIK=${SETENV_ILASTIK_HEADLESS}
			-DLAUNCH_ILASTIK="ilastik/tests/test_applets/pixelClassification/testPixelClassificationHeadless.py"
			-P ${ilastik_headless_test_creation_helper}
	COMMENT "Creating ilastik headless test script" )

##########################################
### Generate clusterized launch script ###
##########################################

# Create a cmake helper script to execute at build-time
set( ilastik_clusterized_creation_helper
	 "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/generate_ilastik_clusterized_launch.cmake" )
file( WRITE ${ilastik_clusterized_creation_helper}
		    "configure_file(${TEMPLATE_DIR}/ilastik_script.template ${BUILDEM_DIR}/bin/ilastik_clusterized @ONLY)" )

# Generate environment setting script at build time using the helper cmake-script
ExternalProject_add_step( ${ilastik_NAME} ilastik_clusterized_launch
	DEPENDEES   download
	COMMAND ${CMAKE_COMMAND} 
			-DSETENV_ILASTIK=${SETENV_ILASTIK_HEADLESS}
			-DLAUNCH_ILASTIK="ilastik/ilastik/workflows/pixelClassification/pixelClassificationClusterized.py"
			-P ${ilastik_clusterized_creation_helper}
	COMMENT "Creating ilastik clusterized launch" )

set_target_properties(${ilastik_NAME} PROPERTIES EXCLUDE_FROM_ALL ON)

endif (NOT ilastik_NAME)

