#! /bin/bash

################################################################################
# Prepare
################################################################################

# Set up shell
if [ "$(echo ${VERBOSE} | tr '[:upper:]' '[:lower:]')" = 'yes' ]; then
    set -x                      # Output commands
fi
set -e                          # Abort on errors



# Set locations
THORN=KadathThorn
NAME=Kadath
SRCDIR="$(dirname $0)"
BUILD_DIR=${SCRATCH_BUILD}/build/${THORN}
if [ -z "${KADATH_INSTALL_DIR}" ]; then
    INSTALL_DIR=${SCRATCH_BUILD}/external/${THORN}
else
    echo "BEGIN MESSAGE"
    echo "Installing FUKA into ${KADATH_INSTALL_DIR}"
    echo "END MESSAGE"
    INSTALL_DIR=${KADATH_INSTALL_DIR}
fi
DONE_FILE=${SCRATCH_BUILD}/done/${THORN}
KADATH_DIR=${INSTALL_DIR}

echo "KadathThorn: Preparing directory structure..."
cd ${SCRATCH_BUILD}
mkdir build external done 2> /dev/null || true
rm -rf ${BUILD_DIR} ${INSTALL_DIR}
mkdir ${BUILD_DIR} ${INSTALL_DIR}

echo "KadathThorn: Unpacking archive..."
pushd ${BUILD_DIR}
${TAR?} xf ${SRCDIR}/../dist/${NAME}.tar

echo "LORENE: Configuring..."
cd ${NAME}

if echo ${F77} | grep -i xlf > /dev/null 2>&1; then
    FIXEDF77FLAGS=-qfixed
fi
export HOME_LORENE=${BUILD_DIR}/${NAME}
cat > local_settings <<EOF
CXX = ${CXX}
CXXFLAGS = ${CXXFLAGS} ${CPPFLAGS} \$(addprefix -I,${SYS_INC_DIRS}) ${LDFLAGS}
CXXFLAGS_G = ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}
INC = -I\$(HOME_LORENE)/C++/Include -I\$(HOME_LORENE)/C++/Include_extra \$(addprefix -I,${GSL_INC_DIRS})
RANLIB = ${RANLIB}
# We don't need dependencies since we always build from scratch
#MAKEDEPEND = ${CXX_DEPEND} \$(INC) \$< ${CXX_DEPEND_OUT} && mv \$@ \$(df).d
MAKEDEPEND = : > \$(df).d
DEPDIR = .deps
FFT_DIR = FFT991
LIB_CXX = `echo -n ${LIBS} | perl -pe 's/(^| )([^-])/\1-l\2/g'`
LIB_LAPACK = `echo -n ${LAPACK_LIBS} ${BLAS_LIBS} | perl -pe 's/(^| )([^-])/\1-l\2/g'`
LIB_PGPLOT =
LIB_GSL = `echo -n ${GSL_LIBS} | perl -pe 's/(^| )([^-])/\1-l\2/g'` `echo -n ${GSL_LIB_DIRS} | perl -pe 's/(^| )([^-])/\1-L\2/g'`
DONTBUILDDEBUGLIB = yes
EOF
if [ -n "$XARGS" ]; then echo "XARGS = $XARGS" >> local_settings; fi
if [ -n "$FIND"  ]; then echo "FIND = $FIND"   >> local_settings; fi

echo "LORENE: Building..."
${MAKE} cpp fortran export
# build some utilities available with the Lorene library
cd Codes/Bin_star
${MAKE} coal init_bin
CONFIG_NAME=`echo "$EXE" | sed -e 's/^cactus_//g'`
UTIL_DIR=${EXEDIR}${DIRSEP}${CONFIG_NAME}
mkdir ${EXEDIR} 2> /dev/null || true
mkdir $UTIL_DIR 2> /dev/null || true
cp coal init_bin $UTIL_DIR
cd -

echo "LORENE: Installing main LORENE library..."
mv ${BUILD_DIR}/${NAME}/Lib                ${INSTALL_DIR}
mkdir ${INSTALL_DIR}/C++
mv ${BUILD_DIR}/${NAME}/C++/Include        ${INSTALL_DIR}/C++
mkdir ${INSTALL_DIR}/Export
mkdir ${INSTALL_DIR}/Export/C++
mv ${BUILD_DIR}/${NAME}/Export/C++/Include ${INSTALL_DIR}/Export/C++
popd
echo "LORENE: Installing LORENE utils..."

echo "LORENE: Cleaning up..."
rm -rf ${BUILD_DIR}

date > ${DONE_FILE}
echo "LORENE: Done."
