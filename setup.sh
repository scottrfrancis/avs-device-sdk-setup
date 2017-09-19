#!/bin/bash

### script from https://github.com/alexa/avs-device-sdk/wiki/Raspberry-Pi-Quick-Start-Guide

# env setup
echo "export SOURCE_FOLDER=$HOME/sources" >> $HOME/.bash_aliases
echo "export LOCAL_BUILD=$HOME/local-builds" >> $HOME/.bash_aliases
echo "export LD_LIBRARY_PATH=$HOME/local-builds/lib:$LD_LIBRARY_PATH" >> $HOME/.bash_aliases
echo "export PATH=$HOME/local-builds/bin:$PATH" >> $HOME/.bash_aliases
echo "export PKG_CONFIG_PATH=$HOME/local-builds/lib/pkgconfig:$PKG_CONFIG_PATH" >> $HOME/.bash_aliases
source $HOME/.bashrc
mkdir $SOURCE_FOLDER

# dev tools
sudo apt-get install git vim gcc cmake build-essential -y

# my flavors
git clone https://github.com/scottrfrancis/dotfiles.git
cp dotfiles/.vimrc ~/

# build nghttp2
cd $SOURCE_FOLDER
wget https://github.com/nghttp2/nghttp2/releases/download/v1.25.0/nghttp2-1.25.0.tar.gz
tar zxvf nghttp2-1.25.0.tar.gz
cd nghttp2-1.25.0.tar.gz
./configure --prefix=$LOCAL_BUILD --disable-app
make -j3
sudo make install

# and openssl
cd $SOURCE_FOLDER
wget https://www.openssl.org/source/old/1.1.0/openssl-1.1.0f.tar.gz
tar xzf openssl-1.1.0f.tar.gz
cd openssl-1.1.0f.tar.gz
./config --prefix=$LOCAL_BUILD --openssldir=$LOCAL_BUILD shared
make -j3
sudo make install

# sql-lite
sudo apt-get install sqlite3 libsqlite3-dev -y

# gstreamer
sudo apt-get install bison flex libglib2.0-dev libasound2-dev pulseaudio libpulse-dev -y
sudo apt-get install libfaad-dev libsoup2.4-dev libgcrypt20-dev -y

cd $SOURCE_FOLDER
wget https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.12.3.tar.xz
tar xf gstreamer-1.12.3.tar.xz
cd *gstreamer*/
./configure --prefix=$LOCAL_BUILD
make -j3
sudo make install

cd $SOURCE_FOLDER
wget https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.12.3.tar.xz
tar xf gst-plugins-base-1.12.3.tar.xz
cd *gst-plugins-base*/
./configure --prefix=$LOCAL_BUILD
make -j3
sudo make install

cd $SOURCE_FOLDER
wget https://gstreamer.freedesktop.org/src/gst-libav/gst-libav-1.12.3.tar.xz
tar xf gst-libav-1.12.3.tar.xz
cd *gst-libav*/
./configure --prefix=$LOCAL_BUILD
make -j3
sudo make install

cd $SOURCE_FOLDER
wget https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.12.3.tar.xz
tar xf gst-plugins-good-1.12.3.tar.xz
cd *gst-plugins-good*/
./configure --prefix=$LOCAL_BUILD
make -j3
sudo make install

cd $SOURCE_FOLDER
wget https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-1.12.3.tar.xz
tar xf gst-plugins-bad-1.12.3.tar.xz
cd *gst-plugins-bad*/
./configure --prefix=$LOCAL_BUILD
make -j3
sudo make install

# portaudio
cd $SOURCE_FOLDER
wget http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz
tar xf pa_stable_v190600_20161030.tgz
cd *portaudio*/
./configure --prefix=$LOCAL_BUILD
make -j3
sudo make install

# sensory WWE
sudo apt-get -y install libasound2-dev
sudo apt-get -y install libatlas-base-dev
sudo ldconfig

cd $SOURCE_FOLDER
git clone git://github.com/Sensory/alexa-rpi.git

bash alexa-rpi/bin/license.sh

cp alexa-rpi/lib/libsnsr.a $LOCAL_BUILD/lib
cp alexa-rpi/include/snsr.h $LOCAL_BUILD/include
mkdir $LOCAL_BUILD/models
cp alexa-rpi/models/spot-alexa-rpi-31000.snsr $LOCAL_BUILD/models

# failsafe update
sudo apt update

# now the AVS SDK
cd $HOME
mkdir AVS_SDK
cd AVS_SDK
git clone git://github.com/alexa/avs-device-sdk.git
echo "export SDK_SRC=$HOME/AVS_SDK/avs-device-sdk" >> $HOME/.bash_aliases
source $HOME/.bashrc

cd $HOME
mkdir BUILD
cd BUILD

cmake $SDK_SRC -DSENSORY_KEY_WORD_DETECTOR=ON -DSENSORY_KEY_WORD_DETECTOR_LIB_PATH=$LOCAL_BUILD/lib/libsnsr.a -DSENSORY_KEY_WORD_DETECTOR_INCLUDE_DIR=$LOCAL_BUILD/include -DGSTREAMER_MEDIA_PLAYER=ON -DPORTAUDIO=ON -DPORTAUDIO_LIB_PATH=$LOCAL_BUILD/lib/libportaudio.a -DPORTAUDIO_INCLUDE_DIR=$LOCAL_BUILD/include -DCMAKE_PREFIX_PATH=$LOCAL_BUILD -DCMAKE_INSTALL_PREFIX=$LOCAL_BUILD
