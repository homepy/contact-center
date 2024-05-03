# docker pull centos:centos7.9.2009
# docker run -t -i centos:centos7.9.2009 /bin/bash

echo "signalwire" > /etc/yum/vars/signalwireusername
echo "TOKEN" > /etc/yum/vars/signalwiretoken

yum install -y wget
yum install -y yum-utils

# centos-release-scl for devtoolset-9
yum install -y centos-release-scl
# centos mirror
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/Centos-altarch.repo http://mirrors.aliyun.com/repo/Centos-altarch-7.repo

# freeswitch yum repo
yum install -y https://$(< /etc/yum/vars/signalwireusername):$(< /etc/yum/vars/signalwiretoken)@freeswitch.signalwire.com/repo/yum/centos-release/freeswitch-release-repo-0-1.noarch.rpm epel-release

yum clean all 
yum makecache 

# deps for freeswitch
yum install -y devtoolset-9 devtoolset-9-gcc*
yum install -y yum-plugin-ovl rpmdevtools yum-utils git

# yum-builddep -y --skip-broken freeswitch
# yum remove -y spandsp spandsp-devel libks
# yum install -y spandsp3 spandsp3-devel libks2  sofia-sip sofia-sip-devel

# deps from base updates epel repo
yum install -y alsa-lib-devel autoconf automake bison bzip2 codec2-devel e2fsprogs-devel erlang gcc-c++ gdbm-devel gnutls-devel lame-devel ldns-devel libcurl-devel libdb4-devel libedit-devel libjpeg-turbo-devel libmemcached-devel libogg-devel libshout-devel libsndfile-devel libtheora-devel libtiff-devel libtool libvorbis-devel libxml2-devel lua-devel mongo-c-driver-devel mpg123-devel ncurses-devel net-snmp-devel openssl-devel opusfile-devel pcre-devel perl perl-ExtUtils-Embed perl-devel portaudio-devel postgresql-devel python-devel speex-devel sqlite-devel unixODBC-devel which yasm zlib-devel 
yum install -y python python-devel python3 python3-devel
yum install -y cmake cmake3


# deps from freeswitch repo
yum install -y broadvoice-devel flite-devel g722_1-devel ilbc2-devel libsilk-devel libyuv-devel mariadb-connector-c-devel opus-devel soundtouch-devel 

## deps from freeswitch repo, but also could build form source.
# yum install -y spandsp3 spandsp3-devel libks2 signalwire-client-c2 sofia-sip sofia-sip-devel
yum install -y spandsp3 spandsp3-devel libks2 signalwire-client-c2


scl enable devtoolset-9 'bash'
# git clone -b 'v2.0.4'   https://github.com/signalwire/libks /usr/local/src/libs/libks
# git clone -b 'v2.0.0'   https://github.com/signalwire/signalwire-c /usr/local/src/libs/signalwire-c
# git clone https://github.com/freeswitch/spandsp /usr/local/src/libs/spandsp && cd /usr/local/src/libs/spandsp  &&  git  checkout  0d2e6ac


git clone -b 'v1.13.17' https://github.com/freeswitch/sofia-sip /usr/local/src/libs/sofia-sip
mkdir -p /usr/local/sofia-sip
cd /usr/local/src/libs/sofia-sip

./bootstrap.sh 
./configure --prefix=/usr/local/sofia-sip
make
make install

export PKG_CONFIG_PATH=/usr/local/sofia-sip/lib/pkgconfig:$PKG_CONFIG_PATH


## deps for mod
# ffmpeg-3.4.13 for mod_av
# yum localinstall -y --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm
yum localinstall -y --nogpgcheck https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/free/el/rpmfusion-free-release-7.noarch.rpm https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm
yum install -y ffmpeg ffmpeg-devel

# deps for mod_mp4v2
yum install -y libmp4v2-devel libmp4v2


# deps for mod_v8 
# see  https://github.com/freeswitch/libv8-packaging.git  https://github.com/v8/v8.git
# yum install http://repo.okay.com.mx/centos/7/x86_64/release/okay-release-1-1.noarch.rpm
yum install -y libicu libicu-devel
yum install -y http://repo.okay.com.mx/centos/7/x86_64/release/libicu57-57.1-12.el7.x86_64.rpm http://repo.okay.com.mx/centos/7/x86_64/release/v8-6.2.91-7.el7.x86_64.rpm  http://repo.okay.com.mx/centos/7/x86_64/release/v8-devel-6.2.91-7.el7.x86_64.rpm  --skip-broken



# mod_tonedetect


mkdir -p /usr/local/src/libs
mkdir -p /usr/local/src/mod


ldconfig
scl enable devtoolset-9 'bash'
git clone -b 'v1.10.11' https://github.com/signalwire/freeswitch.git /usr/local/src/freeswitch
cd /usr/local/src/freeswitch
# vi /usr/local/src/freeswitch/build/modules.conf.in
sed -i 's/#applications\/mod_distributor/applications\/mod_distributor/g'  /usr/local/src/freeswitch/build/modules.conf.in
sed -i 's/#applications\/mod_http_cache/applications\/mod_http_cache/g'  /usr/local/src/freeswitch/build/modules.conf.in
sed -i 's/#applications\/mod_mp4v2/applications\/mod_mp4v2/g'  /usr/local/src/freeswitch/build/modules.conf.in
sed -i 's/#languages\/mod_python/languages\/mod_python/g'  /usr/local/src/freeswitch/build/modules.conf.in
sed -i 's/#languages\/mod_v8/languages\/mod_v8/g'  /usr/local/src/freeswitch/build/modules.conf.in


./bootstrap.sh
# ./configure  --enable-portable-binary --with-gnu-ld --with-python --with-erlang --with-openssl 
./configure
make
make install


#### mods after freeswitch build

# mod_bcg729 https://github.com/xadhoom/mod_bcg729
git clone https://github.com/xadhoom/mod_bcg729 /usr/local/src/mod/mod_bcg729
cd /usr/local/src/mod/mod_bcg729
# sed Makefile
# FS_INCLUDES=/usr/local/freeswitch/include/freeswitch
# FS_MODULES=/usr/local/freeswitch/mod
sed -i 's/FS_INCLUDES=\/usr\/include\/freeswitch/FS_INCLUDES=\/usr\/local\/freeswitch\/include\/freeswitch/g'  /usr/local/src/mod/mod_bcg729/Makefile
sed -i 's/FS_MODULES=\/usr\/lib\/freeswitch\/mod/FS_MODULES=\/usr\/local\/freeswitch\/mod/g'  /usr/local/src/mod/mod_bcg729/Makefile
sed -i 's/CMAKE := cmake/CMAKE := cmake3/g'  /usr/local/src/mod/mod_bcg729/Makefile
make
make install


# mod_unimrcp https://github.com/freeswitch/mod_unimrcp

yum install -y expat-devel sudo

wget -O  /usr/local/src/libs/unimrcp-deps-1.6.0.tar.gz https://www.unimrcp.org/project/component-view/unimrcp-deps-1-6-0-tar-gz/download
cd /usr/local/src/libs/
tar zxvf /usr/local/src/libs/unimrcp-deps-1.6.0.tar.gz 
cd /usr/local/src/libs/unimrcp-deps-1.6.0
./build-dep-libs.sh -s -n -a /usr/local/apr  -o /usr/local/sofia-sip

## make install apr and apr-util only, except sofia-sip
cd /usr/local/src/libs/unimrcp-deps-1.6.0/libs/apr
make install
cd /usr/local/src/libs/unimrcp-deps-1.6.0/libs/apr-util
make install



git clone -b 'unimrcp-1.7.0'  https://github.com/unispeech/unimrcp.git  /usr/local/src/libs/unimrcp
cd /usr/local/src/libs/unimrcp
./bootstrap
./configure --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr --with-sofia-sip=/usr/local/sofia-sip
make
make install

git clone https://github.com/freeswitch/mod_unimrcp.git /usr/local/src/mod/mod_unimrcp
cd /usr/local/src/mod/mod_unimrcp
export PKG_CONFIG_PATH=/usr/local/freeswitch/lib/pkgconfig:/usr/local/unimrcp/lib/pkgconfig:$PKG_CONFIG_PATH
./bootstrap.sh
./configure
make
make install

echo '<!-- <load module="mod_unimrcp"/>  -->' >> /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml 


yum clean all 