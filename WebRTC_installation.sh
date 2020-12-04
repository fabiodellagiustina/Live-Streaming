## Reference: https://github.com/meetecho/janus-gateway

# install dependecies
aptitude install libmicrohttpd-dev libjansson-dev \
	libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev \
	libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
	libconfig-dev pkg-config gengetopt libtool automake

git clone https://gitlab.freedesktop.org/libnice/libnice
cd libnice
meson --prefix=/usr build && ninja -C build && sudo ninja -C build install

# compile Janus WebRTC
git clone https://github.com/meetecho/janus-gateway.git
cd janus-gateway

sh autogen.sh

./configure --prefix=/opt/janus
make
make install

make configs

# configure Janus WebRTC
# options passed through the command line have the precedence on those specified in the configuration file
<installdir>/etc/janus/janus.jcfg     # modify here
                                      # or
<installdir>/bin/janus --help         # through CLI

# start server
<installdir>/bin/janus
