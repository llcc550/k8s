<?php
$http_type = (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') ? 'https://' : 'http://';
$config['base_url'] = $http_type . ($_SERVER['HTTP_HOST'] ?? '');
$config['base_url'] .= preg_replace('@/+$@', '', dirname($_SERVER['SCRIPT_NAME'])).'/';
$config['index_page'] = '';
$config['uri_protocol']	= 'REQUEST_URI';
$config['url_suffix'] = '';
$config['language']	= 'english';
$config['charset'] = 'UTF-8';
$config['enable_hooks'] = TRUE;
$config['subclass_prefix'] = 'MY_';
$config['composer_autoload'] = FALSE;
$config['permitted_uri_chars'] = 'a-z 0-9~%.:_\-\=';
$config['allow_get_array'] = TRUE;
$config['enable_query_strings'] = FALSE;
$config['controller_trigger'] = 'c';
$config['function_trigger'] = 'm';
$config['directory_trigger'] = 'd';
$config['log_threshold'] = 1;
$config['log_path'] = '';
$config['log_file_extension'] = '';
$config['log_file_permissions'] = 0644;
$config['log_date_format'] = 'Y-m-d H:i:s';
$config['error_views_path'] = '';
$config['cache_path'] = '';
$config['cache_query_string'] = FALSE;
$config['encryption_key'] = '';
$config['cookie_prefix']	= '';
$config['cookie_domain']	= '';
$config['cookie_path']		= '/';
$config['cookie_secure']	= FALSE;
$config['cookie_httponly'] 	= FALSE;
$config['standardize_newlines'] = FALSE;
$config['global_xss_filtering'] = FALSE;
$config['csrf_protection'] = FALSE;
$config['csrf_token_name'] = 'csrf_test_name';
$config['csrf_cookie_name'] = 'csrf_cookie_name';
$config['csrf_expire'] = 7200;
$config['csrf_regenerate'] = TRUE;
$config['csrf_exclude_uris'] = array();
$config['compress_output'] = FALSE;
$config['time_reference'] = 'local';
$config['rewrite_short_tags'] = FALSE;
$config['proxy_ips'] = '';
$config['debug']=true;

include APPPATH . '/config/public_config.php';

$config['sess_driver'] = 'redis';
$config['sess_save_path'] = 'tcp://redis.xiaohuiyun.svc.cluster.local:6379?database=9';
$config['sess_cookie_name'] = 'ujy_session';
$config['sess_expiration'] = 86400;
$config['sess_match_ip'] = FALSE;
$config['sess_time_to_update'] = 0;
$config['sess_regenerate_destroy'] = FALSE;

$config['rpc'] = 'tcp://wechat-web-api.xiaohuiyun.svc.cluster.local:8099';
$config['beanstalkd_queue'] = ['host' => 'beanstalkd.xiaohuiyun.svc.cluster.local', 'port' => 11300];
$config['top_module'] = 0;
$config['jpush_u_app_key']='';
$config['jpush_u_app_secret']='';

$config['oss_type'] = 2; // 1:aliyun-oss，2:minio，3:huawei-obs

$config['MINIO_REGION'] = 'region';
$config['MINIO_ENDPOINT'] = 'http://minio.dinghaotech.com';
$config['MINIO_ACCESS_KEY_ID'] = 'minio-user';
$config['MINIO_ACCESS_KEY_SECRET'] = 'minio-user-pass';
$config['MINIO_BUCKET'] = 'file';

$config['go_api_teacher_login_url'] = "http://auth-api.xiaohuiyun.svc.cluster.local:2000/login-no-passwd";
$config['go_api_admin_login_url'] = "http://auth-api.xiaohuiyun.svc.cluster.local:2000/tenant/login-no-passwd";
$config['homework_sms_api'] = 'http://homework-api.xiaohuiyun.svc.cluster.local:2000/push-sms';
$config['openapi_ticket_api'] = 'http://openapi-api.xiaohuiyun.svc.cluster.local:2000/ticket-add';
$config['pic_url_from_video_api'] = 'http://pdf-api.xiaohuiyun.svc.cluster.local:2000/pic-url-from-video';
$config['pic_url_from_video_api_callback'] = 'http://cloudscreennotice-api.xiaohuiyun.svc.cluster.local:2000/callback/update-media-pic-url';