memreas-transcoder-public
=======================

Introduction
------------
memreas transcoder is a php web based application the uses ffmpeg as a media transcoders.  Video input files such as (.avi, .mp4, etc.) can be transcoded to mp4, vp9 (webm), and hls including 4k support for Apple, GoPro, and standard 4k videos. Images can be resized for thumbnails and stored as needed.

The transcoder is built to use Amazon Web Services (AWS) as it's backend but can be ported to other Cloud based services based on your needs.

The transcoder works as such

1 - Video or image should be already stored in your S3 Bucket
2 - Web request is made with appropriate parameters
3 - For videos the transcoder will work on transcoding a single video at a time but will also allow for images to be resized
4 - Upon completion the transcoder will store your transcoded video or images to your S3 bucket
5 - Optional: In the event auto-scaling is setup a new server will be deployed as needed based on your requirements

The transcoder is also equipped to handle auto-scaling and will process input video files sequentially based on a priority system in a single threaded fashion.  Images are processed even if the transcoder is processing a video so as not to create a backlog for smaller files.

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
- Ubuntu shown as example.  Other Linux instances may be used.

Installation
------------

#High Level Steps

1 - Launch Ubuntu instance 
2 - ssh into your new instance
3 - Install Apache, PHP, MySQL, and Redis
4 - Install FFmpeg
5 - Clone project and configure
6 - Test

#Low Level 


1 - Launch Ubuntu instance - hardware sizing is dependent on your requirements
	Add security access for http for 0.0.0.0 *for testing install only
	Allow instance to be created with public IP
2 - ssh into new instance
	ssh -i PATH_TO_YOUR_PEM.pem ubuntu@EC2_PUBLIC_IP
3 - Install Apache, PHP, MySQL


https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-16-04


Apache
```
sudo apt-get update
sudo apt-get install apache2
sudo apache2ctl configtest
sudo nano /etc/apache2/apache2.conf
//add servername directive
```

	
Youshould be able to access http://YOUR_IP_ADDRESS and see the default ubuntu apache page
Note: you can skip firewall section and use AWS security

Install MySQL **should be setup on separate server for auto scaling
```
sudo apt-get install mysql-server
//set root password
```

Create a user
https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql

```
mysql -u root -p

USE mysql;
CREATE USER 'memreas'@'localhost' IDENTIFIED BY 'memreas';
GRANT ALL PRIVILEGES ON * . * TO 'memreas'@'localhost';
GRANT ALL PRIVILEGES ON * . * TO 'memreas'@'localhost';
CREATE SCHEMA transcoder;
USE transcoder;
	
//create the transcode_transaction table from mysql_install_schema_table.sql
```
//
// Update AWS permissions
// - MySQL Server - allow access from transcoder




Install PHP (5.6)
https://askubuntu.com/questions/756181/installing-php-5-6-on-xenial-16-04

```
sudo add-apt-repository ppa:ondrej/php
sudo apt-get install software-properties-common
sudo apt-get update
sudo apt-get install php5.6
sudo apt-get install php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-xml php5.6-curl
sudo nano /etc/apache2/mods-enabled/dir.conf
//move index.php to front 
	<IfModule mod_dir.c>
    	DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
	</IfModule>
sudo systemctl restart apache2
sudo systemctl status apache2
//ctrl-c to exit
//test php for apache
sudo nano /var/www/html/info.php
	<?php
		phpinfo();
	?>
//save and check http://YOUR_IP/info.php
```

3 - Install Redis **should be setup on separate server for auto scaling

https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-redis-on-ubuntu-16-04
```	
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
	supervised systemd
sudo nano /etc/systemd/system/redis.service
    [Unit]
	Description=Redis In-Memory Data Store
	After=network.target

	[Service]
	User=redis
	Group=redis
	ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
	ExecStop=/usr/local/bin/redis-cli shutdown
	Restart=always

	[Install]
	WantedBy=multi-user.target
sudo adduser --system --group --no-create-home redis
sudo mkdir /var/lib/redis
sudo chown redis:redis /var/lib/redis
sudo chmod 770 /var/lib/redis
sudo systemctl start redis
sudo systemctl status redis
redis-cli
	ping
	quit 
//cleanup /tmp
sudo rm -rf /tmp/redis-stable.tar.gz 
sudo rm -rf /tmp/redis-stable
```	

//
// Update AWS permissions
// - Redis Server - allow access from transcoder
	
4 - Install ffmpeg
	https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu

```
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
PATH="$HOME/bin:$PATH" 
make
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
```
	
5 - Check for errors and test your ffmpeg install.  Ensure you are compliant from a license perspective.
	https://ffmpeg.org/ffmpeg.html
	https://www.ffmpeg.org/legal.html
	ffmpeg and ffprobe should work from the command line
	
6 - Setup for memreas transcoder site

```
cd /var/www
//create a user for Apache to allow you to su to this user
sudo adduser memreas

//add this user to www-data
sudo usermod -ag www-data memreas

//change the run user of Apache - this user will need to execute ffmpeg
sudo vi /etc/apache2/envvars
	//make the change as below
	export APACHE_RUN_USER=memreas

//change ownership of www to memreas:www-data
cd /var
sudo chown -R memreas:www-data www

//now change to memreas 
cd /var/www
sudo su memreas

//create the work directory and ffmpeg directories
mkdir ephemeral0
mkdir memreas_ffmpeg_install

//copy bin to memreas_ffmpeg_install
//note check ffmpeg_build/bin to ensure all binaries are copied
cp -R /home/ubuntu/bin /var/www/memreas_ffmpeg_install/bin
cp /home/ubuntu/ffmpeg_build/bin/* /var/www/memreas_ffmpeg_install/bin

// set ownership and permissions
chown -R memreas:www-data /var/www/memreas_ffmpeg_install/bin
chmod -R 755 /var/www/memreas_ffmpeg_install
chmod -R 755 /var/www/ephemeral0

//use git to clone the project 
cd /var/www
git clone git@github.com:memreas/memreas-transcoder-public.git

//next change the default docroot and enable mod_rewrite - exit back to ubuntu user
sudo vi /etc/apache2/sites-available/000-default.conf
	//change docroot per below
	DocumentRoot /var/www/memreas-transcoder-public/app
	    <Directory /var/www/memreas-transcoder-public>
	        Options Indexes FollowSymLinks MultiViews
	        AllowOverride All
	        Require all granted
	    </Directory>

//alternatively you can setup a virtual host
https://www.digitalocean.com/community/tutorials/how-to-set-up-apache-virtual-hosts-on-ubuntu-16-04

//next enable mod_rewrite for .htaccess
sudo a2enmod rewrite
sudo systemctl restart apache2

//alternatively you can setup a virtual host
https://www.digitalocean.com/community/tutorials/how-to-set-up-apache-virtual-hosts-on-ubuntu-16-04
```

//next create a local.php for your db connection - for auto-scaling MySQL should be a separate server
```
<?php
/**
 * Local Configuration Override
 *
 * This configuration override file is for overriding environment-specific and
 * security-sensitive configuration information. Copy this file without the
 * .dist extension at the end and populate values as needed.
 *
 * @NOTE: This file is ignored from Git by default with the .gitignore included
 * in ZendSkeletonApplication. This is a good practice, as it prevents sensitive
 * credentials from accidentally being committed into version control.
 */

return array (
		// Whether or not to enable a configuration cache.
		// If enabled, the merged configuration will be cached and used in
		// subsequent requests.
		// 'config_cache_enabled' => false,
		// The key used to create the configuration cache file name.
		// 'config_cache_key' => 'module_config_cache',
		// The path in which to cache merged configuration.
		// 'cache_dir' => './data/cache',
		// ...

		'db' => array (
				'adapters' => array (
						'YOUR_DB_NAME' => array (
								'dsn' => 'mysql:dbname=YOUR_DB_NAME;host=YOUR_DB_HOSTNAME',
								'username' => 'YOUR_DB_USER',
								'password' => 'YOUR_DB_PASSWORD 
						)
				) 
		),

		'doctrine' => array (
				'connection' => array (
						'orm_default' => array (
								'doctrine_type_mappings' => array (
										'enum' => 'string',
										'bit' => 'string' 
								),
								// memreasbackenddb
								'driverClass' => 'Doctrine\DBAL\Driver\PDOMySql\Driver',
								'params' => array (
										'host' => 'YOUR_DB_HOSTNAME',
										'port' => '3306',
										'dbname' => 'YOUR_DB_NAME',
										'user' => 'YOUR_DB_USER',
										'password' => 'YOUR_DB_PASSWORD' 
								) 
						) 
				) 
		) 
);
```

//
// Configure transcoder
// - update memreasconstants.php for your AWS, Redis, and MySQL config data
//

```
<?php
namespace Application\Model;

class MemreasConstants {
	const MEMREAS_ENV = "YOUR_ENVIRONMENT_NAME"; //i.e. DEV, PROD, etc. * this is used for email notifications

	// AWS section 
	const AWS_APPKEY = 'YOUR_S3_APP_KEY';  
	const AWS_APPSEC = 'YOUR_S3_APP_SECRET';
	const AWS_APPREG = 'YOUR_AWS_REGION'; //i.e. us-east-1
	const S3BUCKET = "YOUR_S3_BUCKET_NAME";
	const S3HLSBUCKET = "YOUR_S3_BUCKET_NAME"; 
	const CLOUDFRONT_HLSSTREAMING_HOST = 'YOUR_CLOUDFRONT_URL'; //optional

	// MySQL section *for auto-scaling a separate Redis instance should be used
	const MEMREASDB = 'YOUR_DB_NAME';
	const MEMREASBEDB = 'YOUR_DB_NAME';


	// Redis section v3.0.7 *for auto-scaling a separate Redis instance should be used
	const REDIS_SERVER_ENDPOINT = "YOUR_REDIS_IP_ADDRESS"; //i.e. 10.0.0.1 
	const REDIS_SERVER_USE = true;
	const REDIS_SERVER_SESSION_ONLY = true;
	const REDIS_SERVER_PORT = "6379";

	//constants for processing
	const MEMREAS_TRANSCODER_FFMPEG = '/var/www/memreas_ffmpeg_install/bin/ffmpeg';
	const MEMREAS_TRANSCODER_FFPROBE = '/var/www/memreas_ffmpeg_install/bin/ffprobe';
	const MEMREAS_TRANSCODER_FFMPEG_LOCAL = '/usr/local/bin/ffmpeg';
	const MEMREAS_TRANSCODER_FFPROBE_LOCAL = '/usr/local/bin/ffprobe';
	const SIGNURLS = false;
	const EXPIRES = 3600;
	const SIZE_5MB = 5000000;
	const SIZE_10MB = 10000000;
	const SIZE_100MB = 100000000;
	
	
	// 12 hour handle for processing
	const REDIS_CACHE_TTL = 43200;
	const URL = "/index";
	const DATA_PATH = "/data/";
	const MEDIA_PATH = "/media/";
	const IMAGES_PATH = "/images/";
	const THUMBNAILS_PATH = "/images/thumbnails/";
	const USERIMAGE_PATH = "/media/userimage/";
	const FOLDER_PATH = "/data/media/";
	const FOLDER_AUDIO = "upload_audio";
	const FOLDER_VIDEO = "uploadVideo";
	const VIDEO = "/data/media/uploadVideo";
	const AUDIO = "/data/media/upload_audio";
	
	//below creates a 
	public static function fetchAWS() {
		$sharedConfig = [ 
				'region' => self::AWS_APPREG,
				'version' => 'latest',
				'credentials' => [ 
						'key' => self::AWS_APPKEY,
						'secret' => self::AWS_APPSEC 
				] 
		];
		
		return new \Aws\Sdk ( $sharedConfig );
	}
}
```

//
// Configure transcoder
// - setup git
//Optional - use built in deploy Deploy code to server
//Note: git pull is built in and setup is shown here

//Setup an ssh key for your repo as memreas user
https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

```
cd ~
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

//add the ssh key to your github account...
https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/
```
cat /home/memreas/.ssh/id_rsa.pub
```

//
// Setup startup_worker.sh - used to pull latest code and start worker on new process
// - add startup_worker.sh to rc.local
//
```
sudo vi /etc/rc.local
	/var/www/memreas-transcoder-public/startup_worker.sh
```

//
// Server should be setup and ready to test
// - reboot the server and check the php_errors.log file to see check for errors
//
