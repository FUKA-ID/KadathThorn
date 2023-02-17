#! /bin/bash

################################################################################
# Prepare
################################################################################

# Set up shell
if [ "$(echo ${VERBOSE} | tr '[:upper:]' '[:lower:]')" = 'yes' ]; then
    set -x                      # Output commands
fi
set -e                          # Abort on errors

################################################################################
# Search
################################################################################

if [ -z "${KADATH_DIR}" ]; then
    echo "BEGIN MESSAGE"
    echo "KADATH selected, but KADATH_DIR not set."
    echo "END MESSAGE"
else
    echo "BEGIN MESSAGE"
    echo "Using KADATH in ${KADATH_DIR}"
    echo "END MESSAGE"
fi

THORN=KadathThorn

################################################################################
# Build
################################################################################

if [ -z "${KADATH_DIR}"                                                 \
     -o "$(echo "${KADATH_DIR}" | tr '[a-z]' '[A-Z]')" = 'BUILD' ]
then
    echo "BEGIN MESSAGE"
    echo "Building Frankfurt University/KADATH from git repo..."
    echo "END MESSAGE"

    # Set locations
    NAME=Kadath
    SRCDIR="$(dirname $0)"
    BUILD_DIR=${SCRATCH_BUILD}/build/${THORN}
    if [ -z "${KADATH_INSTALL_DIR}" ]; then
        INSTALL_DIR=${SCRATCH_BUILD}/external/${THORN}
    else
        echo "BEGIN MESSAGE"
        echo "Installing Frankfurt University/KADATH into ${KADATH_INSTALL_DIR}"
        echo "END MESSAGE"
        INSTALL_DIR=${KADATH_INSTALL_DIR}
    fi
    KADATH_BUILD=1
    KADATH_DIR=${INSTALL_DIR}
else
    KADATH_BUILD=
    DONE_FILE=${SCRATCH_BUILD}/done/${THORN}
    if [ ! -e ${DONE_FILE} ]; then
        mkdir ${SCRATCH_BUILD}/done 2> /dev/null || true
        date > ${DONE_FILE}
    fi
fi

################################################################################
# Configure Cactus
################################################################################

# Pass configuration options to build script
echo "BEGIN MAKE_DEFINITION"
echo "KADATH_BUILD          = ${KADATH_BUILD}"
echo "KADATH_INSTALL_DIR    = ${KADATH_INSTALL_DIR}"
echo "END MAKE_DEFINITION"

# Set options
KADATH_INC_DIRS="${KADATH_DIR}/include ${KADATH_DIR}/include/Kadath_point_h"
KADATH_LIB_DIRS="${KADATH_DIR}/lib"
KADATH_LIBS="kadath"

#KADATH_INC_DIRS="$(${CCTK_HOME}/lib/sbin/strip-incdirs.sh ${KADATH_INC_DIRS})"
#KADATH_LIB_DIRS="$(${CCTK_HOME}/lib/sbin/strip-libdirs.sh ${KADATH_LIB_DIRS})"

# Pass options to Cactus
echo "BEGIN MAKE_DEFINITION"
echo "KADATH_DIR      = ${KADATH_DIR}"
echo "KADATH_INC_DIRS = ${KADATH_INC_DIRS}"
echo "KADATH_LIB_DIRS = ${KADATH_LIB_DIRS}"
echo "KADATH_LIBS     = ${KADATH_LIBS}"
# echo "HOME_KADATH     = ${KADATH_DIR}"
echo "END MAKE_DEFINITION"

echo 'INCLUDE_DIRECTORY $(KADATH_INC_DIRS)'
echo 'LIBRARY_DIRECTORY $(KADATH_LIB_DIRS)'
echo 'LIBRARY           $(KADATH_LIBS)'
