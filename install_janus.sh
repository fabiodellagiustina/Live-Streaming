apt install libnice-dev libmicrohttpd-dev libjansson-dev libssl-dev libsofia-sip-ua-dev libglib2.0-dev libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev libconfig-dev pkg-config gengetopt libtool automake meson make cmake

# git clone https://gitlab.freedesktop.org/libnice/libnice
# cd libnice
# meson --prefix=/usr build && ninja -C build && sudo ninja -C build install
# export PKG_CONFIG_PATH=/root/libnice/build/meson-private/

wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz
tar xfv v2.2.0.tar.gz
cd libsrtp-2.2.0
./configure --prefix=/usr --enable-openssl
make shared_library && sudo make install

git clone https://github.com/sctplab/usrsctp
cd usrsctp
./bootstrap
./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6
make && sudo make install

git clone https://libwebsockets.org/repo/libwebsockets
cd libwebsockets
# If you want the stable version of libwebsockets, uncomment the next line
git checkout v3.2-stable
mkdir build
cd build
# See https://github.com/meetecho/janus-gateway/issues/732 re: LWS_MAX_SMP
cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..
make && sudo make install

git clone https://github.com/meetecho/janus-gateway.git
cd janus-gateway
sh autogen.sh
./configure --prefix=/opt/janus
make
make install
make configs
