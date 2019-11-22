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
# Configure Cactus
################################################################################

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
