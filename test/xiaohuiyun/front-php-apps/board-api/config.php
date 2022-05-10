<?php
$http_type = (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') ? 'https://' : 'http://';
$config['base_url'] = $http_type . ($_SERVER['HTTP_HOST'] ?? '');
$config['base_url'] .= preg_replace('@/+$@', '', dirname($_SERVER['SCRIPT_NAME'])) . '/';
$config['index_page'] = '';
$config['uri_protocol'] = 'REQUEST_URI';
$config['url_suffix'] = '';
$config['language'] = 'english';
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
$config['log_threshold'] = 0;
$config['log_path'] = '';
$config['log_file_extension'] = '';
$config['log_file_permissions'] = 0644;
$config['log_date_format'] = 'Y-m-d H:i:s';
$config['error_views_path'] = '';
$config['cache_path'] = '';
$config['cache_query_string'] = FALSE;
$config['encryption_key'] = '6c32586331ac32aad8f2c725f050d13d';
$config['cookie_prefix'] = '';
$config['cookie_domain'] = '';
$config['cookie_path'] = '/';
$config['cookie_secure'] = FALSE;
$config['cookie_httponly'] = FALSE;
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
date_default_timezone_set('Asia/ShangHai');
$config['time_zone'] = date_default_timezone_get();

// 微信rpc服务地址
$config['rpc'] = 'tcp://wechat-web-api.xiaohuiyun.svc.cluster.local:8099';
// redis
$config['redis_host'] = 'redis.xiaohuiyun.svc.cluster.local';
$config['redis_port'] = '6379';
$config['redis_password'] = '';
// beanstalkd
$config['beanstalkd_queue'] = ['host' => 'beanstalkd.xiaohuiyun.svc.cluster.local', 'port' => 11300];
// golang apis
$config['login_url'] = 'http://auth-api.xiaohuiyun.svc.cluster.local:2000/board/quick-login';
$config['app_login_url'] = 'http://auth-api.xiaohuiyun.svc.cluster.local:2000/app/login-no-passwd';
$config['zuy_course_api'] = 'http://zuy-api.xiaohuiyun.svc.cluster.local:2000/course';
// session
$config['sess_driver'] = 'redis';
$config['sess_save_path'] = 'tcp://redis.xiaohuiyun.svc.cluster.local:6379?database=1';
$config['sess_cookie_name'] = 'ujy_session';
$config['sess_expiration'] = 3600 * 24;
$config['sess_match_ip'] = FALSE;
$config['sess_time_to_update'] = 0;
$config['sess_regenerate_destroy'] = FALSE;

// 自动加载
spl_autoload_register(function () {
    require_once APPPATH . '/libraries/REST_Controller.php';
    require_once APPPATH . '/controllers/AppBaseController.php';
});