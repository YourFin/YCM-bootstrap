#!/bin/env sh

## Attempts to bootstrap ycmd, and git, make, tar, and wget prior to that,
## using only netcat, gzip/xz/bz2, and gcc, with minimal permissions. There isn't
## really a good reason to be running ycmd if these tools aren't avalible.
## Totally POSIX compatable, should run anywhere that isn't running an
## old af korn shell implementation.

# install dir. Feel free to fork this if it needs to be changed
YCMDINSTALLDIR="$HOME/.emacs.d/frameworks/ycmd"
mkdir -p $YCMDINSTALLDIR
CURDIR="$(pwd)"
USED_CC='cc'
USED_AR='ar'
USED_RANLIB='ranlib'
USED_NM='nm'
USED_CXX='c++'

# silently check if $1 exists
ycmd_command_exists () {
    command -v $1 >/dev/null 2>/dev/null
}

# Figure out which download utility to use, otherwise install GNU
# wget locally via ftp
if ycmd_command_exists 'wget'; then 
     # no proceeding "function" in definiton in order to be posix compliant
     ycmd_download_func_string='wget $1 -O $YCMDINSTALLDIR/$2'
elif ycmd_command_exists 'curl'; then
     ycmd_download_func_string='curl -L $1 > $YCMDINSTALLDIR/$2'
elif ycmd_command_exists 'lynx'; then
     ycmd_download_func_string='lynx -dump $1 > $YCMDINSTALLDIR/$2'
fi

#TODO: come up with a function that
# manually uses netcat to pull files for
# gnu make and wget and then pull down wget



# Disgusting, but I don't know any other way that
# correctly scopes in every shell.
#
# DO NOT ever call this function outside
# of this script, or mess with with the value of
# $ycmd_download_func_string later in the script
ycmd_download_func () {
    eval $ycmd_download_func_string
}

# Download and symlink osx gcc binary if not already installed.
# Allows this whole process to work on macs without root.
# Will definently cause issues if run on a weird ass darwin system.
if [ "$(uname)" = "Darwin" ] && ! ycmd_command_exists gcc ; then
    echo 'Downloading gcc...'
    mkdir -p $YCMDINSTALLDIR/gcc
    ycmd_download_func https://github.com/YourFin/gcc-osx-binary/blob/master/gcc-6.3.0.zip?raw=true $YCMDINSTALLDIR/gcc.zip
    unzip $YCMDINSTALLDIR/gcc.zip -d $YCMDINSTALLDIR/gcc
    #clean up zip file
    rm $YCMDINSTALLDIR/gcc.zip
    $GCC_BIN_LOCATION="$YCMDINSTALLDIR/gcc/gcc-6.3.0/bin"
    USED_CC="$GCC_BIN_LOCATION/gcc-6.3.0"
    USED_AR='$GCC_BIN_LOCATION/gcc-ar-6.3.0'
    USED_RANLIB='$GCC_BIN_LOCATION/gcc-ranlib-6.3.0'
    USED_NM='$GCC_BIN_LOCATION/gcc-nm-6.3.0'
    USED_CXX='$GCC_BIN_LOCATION/c++-6.3.0'
fi

MAKE_SUFFIX='cc="$USED_CC" ar="$USED_AR" ranlib="$USED_RANLIB" nm="$USED_NM" cxx="$USED_CXX"'

# bootstrap make if it doesn't exist
if ! ycmd_command_exists make ; then
    echo 'Downloading make...'
    $ycmd_download_func http://ftp.gnu.org/gnu/make/make-4.2.tar.gz $YCMDINSTALLDIR/make.tar.gz
    tar -xzf $YCMDINSTALLDIR/make.tar.gz -C $YCMDINSTALLDIR
    rm -f $YCMDINSTALLDIR/make.tar.gz
    echo 'Building make...'
    cd $YCMDINSTALLDIR/make
    echo '  Running configure...'
    ./configure $MAKE_SUFFIX
    echo '  Building...'
    ./build.sh.in $MAKE_SUFFIX
fi
echo 'Make installed!'


# attempt to install git
if ! ycmd_command_exists git ; then
    

tar -xzf $YCMDINSTALLDIR/git.tar.xz -C $YCMDINSTALLDIR
