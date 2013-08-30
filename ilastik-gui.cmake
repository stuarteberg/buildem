#
# Install ilastik GUI from source
#
# Ilastik is composed of 3 git repos, 2 of which are necessary for headless mode.
# The GUI build supplements the ilastik headless build with a number of components
# and also adds some environment setting, launch, and test scripts to the bin
# directory.

if (NOT ilastik-gui_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (ExternalSource)
include (BuildSupport)
include (TemplateSupport)

include (ilastik)
include (qt4)
include (pyqt4)
include (qimage2ndarray)
include (vtk)

set (ilastik-gui_NAME ${ilastik_NAME}-gui)

# Add a few dependencies to GUI ilastik build
add_dependencies( ${ilastik_NAME} ${qt4_NAME} ${pyqt4_NAME} ${qimage2ndarray_NAME} ${vtk_NAME} ) 

add_custom_target (${ilastik-gui_NAME} ALL 
    DEPENDS     ${ilastik_NAME}
    COMMENT     "Building ilastik gui and all dependencies...")

##############################
### Generate setenv script ###
##############################

set(SETENV_ILASTIK_GUI setenv_ilastik_gui)

# Create a cmake helper script to execute at build-time
set( ilastik_setenv_gui_script_creation_helper
	 "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/generate_ilastik_setenv_gui.cmake" )
file( WRITE ${ilastik_setenv_gui_script_creation_helper}
		    "configure_file(${TEMPLATE_DIR}/${SETENV_ILASTIK_GUI}.in ${BUILDEM_DIR}/bin/${SETENV_ILASTIK_GUI}.sh @ONLY)" )

# Generate environment setting script at build time using the helper cmake-script
ExternalProject_add_step( ${ilastik_NAME} ilastik_setenv
	DEPENDEES   test
	COMMAND ${CMAKE_COMMAND} 
			-DSETENV_ILASTIK=${SETENV_ILASTIK_GUI}
			-DILASTIK_DIR_RELATIVE=${ILASTIK_DIR_RELATIVE}
			-DPYTHON_PREFIX_RELATIVE=${PYTHON_PREFIX_RELATIVE}
			-DBUILDEM_LD_LIBRARY_VAR=${BUILDEM_LD_LIBRARY_VAR}
			-P ${ilastik_setenv_gui_script_creation_helper}
	COMMENT "Creating ${SETENV_ILASTIK_GUI}.sh" )

##################################
### Generate gui launch script ###
##################################

# Create a cmake helper script to execute at build-time
set( ilastik_gui_launch_creation_helper
	 "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/generate_ilastik_gui_launch.cmake" )
file( WRITE ${ilastik_gui_launch_creation_helper}
		    "configure_file(${TEMPLATE_DIR}/ilastik_script.template ${BUILDEM_DIR}/bin/ilastik_gui @ONLY)" )

# Generate environment setting script at build time using the helper cmake-script
ExternalProject_add_step( ${ilastik_NAME} install_ilastik_gui
	DEPENDEES   ilastik_setenv
	COMMAND ${CMAKE_COMMAND} 
			-DSETENV_ILASTIK=${SETENV_ILASTIK_GUI}
			-DLAUNCH_ILASTIK="ilastik/ilastik.py"
			-P ${ilastik_gui_launch_creation_helper}
	COMMENT "Creating launch script: ilastik_gui" )

################################
### Generate gui test script ###
################################

# Create a cmake helper script to execute at build-time
set( ilastik_gui_test_creation_helper
	 "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/generate_ilastik_gui_test.cmake" )
file( WRITE ${ilastik_gui_test_creation_helper}
		    "configure_file(${TEMPLATE_DIR}/ilastik_script.template ${BUILDEM_DIR}/bin/ilastik_gui_test @ONLY)" )

# Generate environment setting script at build time using the helper cmake-script
ExternalProject_add_step( ${ilastik_NAME} generate_ilastik_gui_test
	DEPENDEES   install_ilastik_gui
	COMMAND ${CMAKE_COMMAND} 
			-DSETENV_ILASTIK=${SETENV_ILASTIK_GUI}
			-DLAUNCH_ILASTIK="ilastik/tests/test_applets/pixelClassification/testPixelClassificationGui.py"
			-P ${ilastik_gui_test_creation_helper}
	COMMENT "Creating ilastik_gui_test" )

###########################
# Run the gui test script #
###########################

ExternalProject_add_step(${ilastik_NAME} test_ilastik_gui
	DEPENDEES   generate_ilastik_gui_test
    COMMAND     ${BUILDEM_ENV_STRING} ${BUILDEM_DIR}/bin/ilastik_gui_test
    COMMENT     "Ran ilastik gui test"
)

endif (NOT ilastik-gui_NAME)

