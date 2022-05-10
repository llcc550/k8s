-- 以下参数为
-- 60s内请求超过3000次，列入黑名单60秒
local access_period = 60
local access_times = 3000
local access_expire = 60

-- 以下为redis参数
local redis_ip = "redis.xiaohuiyun.svc.cluster.local"
local redis_port = 6379
local redis_db_index = 10
local redis_password = ""
local redis_timeout = 2000
local redis_keepalive = 60000
local redis_pool_size = 100

local redis = require "redis-util"

local redis_cli = redis:new({
    host = redis_ip,
    port = redis_port,
    db_index = redis_db_index,
    password = redis_password,
    timeout = redis_timeout,
    keepalive = redis_keepalive,
    pool_size = redis_pool_size,
})

local now = os.date("%Y-%m-%d  %H:%M:%S",os.time())

local clientIP = ngx.var.http_x_forwarded_for

local incrKey = "request#" .. clientIP
local blackKey = "black#" .. clientIP
local blackHistoryKey = "black-history#" .. clientIP .. "#" .. now

local is_black, _ = redis_cli:get(blackKey)
if tonumber(is_black) == 1 then
    ngx.exit(403)
end

inc = redis_cli:incr(incrKey)

if inc == 1 then
    redis_cli:expire(incrKey, access_period)
end

if inc >= access_times then
    redis_cli:set(blackKey, 1)
    redis_cli:expire(blackKey, access_expire)

    redis_cli:set(blackHistoryKey, 1)
    redis_cli:expire(blackHistoryKey, 86400)
end

local maxKey = "max"
local maxIpKey = "max-ip"
local max, _ = redis_cli:get(maxKey)
if not max or tonumber(max) < inc then
   redis_cli:set(maxKey, inc)
   redis_cli:set(maxIpKey, clientIP)
   redis_cli:expire(maxKey, 86400)
   redis_cli:expire(maxIpKey, 86400)
end