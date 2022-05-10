<?php
return [
    'rpc' => 'tcp://wechat-web-api.xiaohuiyun.svc.cluster.local:8099',
    'debug' => true,
    'app_h5_base_url' => 'http://www.dinghaotech.com/mp/app_h5',
    'queue_host' => 'beanstalkd.xiaohuiyun.svc.cluster.local',
    'queue_port' => 11300,
    'oss' => 2, // 1:aliyun，2:minio
];
