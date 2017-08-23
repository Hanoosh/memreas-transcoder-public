<?php
namespace Application\Model;

class MemreasConstants {
	const MEMREAS_ENV = "YOUR_ENVIRONMENT_NAME"; //i.e. DEV, PROD, etc.
	const AWS_APPKEY = 'YOUR_S3_APP_KEY';  
	const AWS_APPSEC = 'YOUR_S3_APP_SECRET';
	const AWS_APPREG = 'us-east-1';
	const MEMREAS_TRANSCODER_FFMPEG = '/var/www/memreas_ffmpeg_install/bin/ffmpeg';
	const MEMREAS_TRANSCODER_FFPROBE = '/var/www/memreas_ffmpeg_install/bin/ffprobe';
	const MEMREAS_TRANSCODER_FFMPEG_LOCAL = '/usr/local/bin/ffmpeg';
	const MEMREAS_TRANSCODER_FFPROBE_LOCAL = '/usr/local/bin/ffprobe';
	const SIGNURLS = false;
	const EXPIRES = 3600;
	const SIZE_5MB = 5000000;
	const SIZE_10MB = 10000000;
	const SIZE_100MB = 100000000;
	const MEMREASDB = 'YOUR_LOCALPHPFILE_DB_NAME';
	const MEMREASBEDB = 'YOUR_LOCALPHPFILE_DB_NAME';
	const S3BUCKET = "YOUR_S3_BUCKET_NAME";
	const S3HLSBUCKET = "YOUR_S3_BUCKET_NAME"; 
	const CLOUDFRONT_HLSSTREAMING_HOST = 'YOUR_CLOUDFRONT_URL'; //optional
	
	// Redis section v3.0.7 *for auto-scaling a separate Redis instance should be used
	const REDIS_SERVER_ENDPOINT = "REDIS_IP_ADDRESS"; //i.e. 10.0.0.1 
	const REDIS_SERVER_USE = true;
	const REDIS_SERVER_SESSION_ONLY = true;
	const REDIS_SERVER_PORT = "6379";
	
	// 12hour handle for process
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
