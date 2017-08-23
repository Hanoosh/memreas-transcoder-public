memreas-transcoder-public
=======================

Introduction
------------
memreas transcoder is a php web based application the uses ffmpeg to transcode video and image formats.  For video input files such as (.avi, .mp4, etc.) can be transcoded to mp4, vp9 (webm), and hls including 4k support for Apple, GoPro, and standard 4k videos.

The transcoder is built to use Amazon Web Services (AWS) as it's backend but can be port to other Cloud based services based on your needs.

The transcoder is also equipped to handle auto-scaling and will process input video files sequentially based on a priority system in a single threaded fashion.  Images are processed even if the transcoder is processing a video so as not to create a backlog

Requirements
------------
- Amazon EC2 Instance 
- Amzaon Web Servies S3 Bucket
- Amzaon Web Servies SES to receive notification emails
- Github account to store/fetch your latest updates for new worker servers
- Redis installation: used to manage multiple workers

Caveats
------------
- Security aspects shown here are for sample purposes.  Security and Server hardening are outside of the scope of this project.
- Error logging messages are for debugging purposes only (e.g. Mlog)

Installation
------------
1 - Launch Ubuntu instance - hardware sizing is dependent on your requirements
	Add security access for http for 0.0.0.0 *for testing install only
	Allow instance to be created with public IP
2 - ssh into new instance
	ssh -i PATH_TO_YOUR_PEM.pem ubuntu@EC2_PUBLIC_IP
3 - Install Apache, PHP, MySQL
	
	https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-16-04
	
	Apache
	sudo apt-get update
	sudo apt-get install apache2
	sudo apache2ctl configtest
	sudo nano /etc/apache2/apache2.conf
	*add servername directive
	
	Youshould be able to access http://YOUR_IP_ADDRESS and see the default ubuntu apache page
	*you can skip firewall section given AWS security
	
	Install MySQL
	sudo apt-get install mysql-server
	*create a user
	https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql
		CREATE USER 'memreas'@'localhost' IDENTIFIED BY 'memreas';
		GRANT ALL PRIVILEGES ON * . * TO 'memreas'@'localhost';
		GRANT ALL PRIVILEGES ON * . * TO 'memreas'@'localhost';
		CREATE SCHEMA transcoder;
		USE transcoder;
		
	*create the transcode_transaction table from mysql_install_schema_table.sql
	
	
	Install PHP
	sudo apt-get install php libapache2-mod-php php-mcrypt php-mysql
	sudo nano /etc/apache2/mods-enabled/dir.conf
	...
	sudo systemctl restart apache2
	sudo systemctl status apache2
	

3 - Install Redis
	https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-redis-on-ubuntu-16-04
	sudo apt-get update
	sudo apt-get install build-essential tcl
	cd /tmp
	curl -O http://download.redis.io/redis-stable.tar.gz
	tar xzvf redis-stable.tar.gz
	cd redis-stable
	make
	make test
	sudo make install
	sudo mkdir /etc/redis
	sudo cp /tmp/redis-stable/redis.conf /etc/redis
	sudo nano /etc/redis/redis.conf
	...
	sudo nano /etc/systemd/system/redis.service
	...
	sudo adduser --system --group --no-create-home redis
	sudo mkdir /var/lib/redis
	sudo chown redis:redis /var/lib/redis
	sudo chmod 770 /var/lib/redis
	sudo systemctl start redis
	sudo systemctl status redis
	*test redis
	redis-cli
	ping 
	*redis should be installed and return PONG
	*cleanup /tmp
	sudo rm -rf /tmp/redis-stable.tar.gz 
	sudo rm -rf /tmp/redis-stable
	
4 - Install ffmpeg
	https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
cd ~
sudo apt-get update
sudo apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev \
libsdl2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
libxcb-xfixes0-dev pkg-config texinfo wget zlib1g-dev

mkdir ~/ffmpeg_sources

sudo apt-get install yasm
cd ~/ffmpeg_sources
wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install	

cd ~/ffmpeg_sources
wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.bz2
tar xjvf nasm-2.13.01.tar.bz2
cd nasm-2.13.01
./autogen.sh
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
PATH="$HOME/bin:$PATH" make
make install

sudo apt-get install libx264-dev
cd ~/ffmpeg_sources
wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar xjvf last_x264.tar.bz2
cd x264-snapshot*
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --disable-opencl
PATH="$HOME/bin:$PATH" make
make install

sudo apt-get install libx265-dev
sudo apt-get install cmake mercurial
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make
make install

sudo apt-get install libfdk-aac-dev
cd ~/ffmpeg_sources
wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master
tar xzvf fdk-aac.tar.gz
cd mstorsjo-fdk-aac*
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install

sudo apt-get install libmp3lame-dev
cd ~/ffmpeg_sources
wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared
make
make install

sudo apt-get install libopus-dev
cd ~/ffmpeg_sources
wget https://archive.mozilla.org/pub/opus/opus-1.1.5.tar.gz
tar xzvf opus-1.1.5.tar.gz
cd opus-1.1.5
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install	

sudo apt-get install libvpx-dev
sudo apt-get install git

cd ~/ffmpeg_sources
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth
PATH="$HOME/bin:$PATH" make
make install

cd ~/ffmpeg_sources
wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree
PATH="$HOME/bin:$PATH" make
make install
hash -r
	
5 - Check for errors and test your ffmpeg install.  Ensure you are compliant from a license perspective.
	https://www.ffmpeg.org/legal.html
	ffmpeg and ffprobe should work from the command line
	
6 - Setup for memreas transcoder

cd /var/www
#create a user for Apache to allow you to su to this user
sudo adduser memreas

#add this user to www-data
sudo usermod -aG www-data memreas

#change the run user of Apache - this user will need to execute ffmpeg
sudo vi /etc/apache2/envvars

#make the change as below
#export APACHE_RUN_USER=www-data
export APACHE_RUN_USER=memreas

#change ownership of www to memreas:www-data
sudo chown -R memreas:www-data www

#now change to memreas 
sudo su memreas

#create the work directory and ffmpeg directories
cd /var/www
mkdir ephemeral0
mkdir memreas_ffmpeg_install

#copy bin to memreas_ffmpeg_install
#note check ffmpeg_build/bin to ensure all binaries are copied
cp /home/ubuntu/bin/* /var/www/memreas_ffmpeg_install/bin/*
cp /home/ubuntu/ffmpeg_build/bin/* /var/www/memreas_ffmpeg_install/bin/*

# set ownership and permissions
sudo chown -R memreas:www-data /var/www
chmod -R 755 /var/www/memreas_ffmpeg_install
chmod -R 755 /var/www/ephemeral0




