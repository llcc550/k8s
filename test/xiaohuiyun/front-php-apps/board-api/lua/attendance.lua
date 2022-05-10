local redis_ip = "redis.xiaohuiyun.svc.cluster.local"
local redis_port = 6379
local redis_db_index = 7
local redis_password = ""
local redis_timeout = 2000
local redis_keepalive = 60000
local redis_pool_size = 100

local wechatapi_ip = 'wechat-web-api.xiaohuiyun.svc.cluster.local'
local wechatapi_port = 8099

local _M = {}
_M._VERSION = "1.0"

local json = require "cjson"
local redis = require "redis-util"
local md5 = require 'md5'

json.encode_empty_table_as_object(false)

local successResponse = json.encode({
    status = 1,
    message = "",
    data = {},
})

local csSuccessResponse = [[
                <SOAP-ENV:Envelope
                  xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
                  SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                  <SOAP-ENV:Body>
                    <m:GetEndorsingBoarderResponse xmlns:m="http://board-api.dinghaotech.com/service/WebServiceNoWsdl">
                      <endorsingBoarder>
                        {"returnCode":"000","insertKqInfo":[{"COLNUM":"1"}]}
                      </endorsingBoarder>
                    </m:GetEndorsingBoarderResponse>
                  </SOAP-ENV:Body>
                </SOAP-ENV:Envelope>
            ]]

local function expire_time()
    local now_time = os.time()
    local tab = os.date("*t", now_time)
    tab.hour = 0
    tab.min = 0
    tab.sec = 0
    local today_end_time = tonumber(os.time(tab) + 86400)
    return today_end_time - now_time
end

local function write_to_redis(data_type, data, response)

    -- 连接redis
    local red = redis:new({
        host = redis_ip,
        port = redis_port,
        db_index = redis_db_index,
        password = redis_password,
        timeout = redis_timeout,
        keepalive = redis_keepalive,
        pool_size = redis_pool_size,
    })

    -- 数据json序列化
    local valueString = json.encode({
        type = data_type,
        data = data,
    })

    local key = "lua#student#attendance#" .. md5.sumhexa(valueString)

    local checkValue = red:get(key)
    if checkValue and #checkValue ~= 0 then
        ngx.say(response)
        return false
    end
    local redisStatus,err = red:set(key, valueString)
    if not redisStatus then
        ngx.log(ngx.ERR, "lua cannot insert into redis: ", err)
        ngx.say(json.encode({
            status = 0,
            message = "数据写入失败",
            data = {},
        }))
        return false
    end
    red:expire(key, expire_time())
    return key
end

local function send_to_rpc(key)
    local sock = ngx.socket.tcp()
    local socketTcpStatus = sock:connect(wechatapi_ip, wechatapi_port)
    if not socketTcpStatus then
        ngx.log(ngx.ERR, "lua cannot push to wechat rpc:", os.time())
        ngx.say(json.encode({
            status = 0,
            message = "数据推送失败",
            data = {},
        }))
        return false
    end

    sock:send(json.encode({
        interface = "App\\Lib\\StudentAttendanceInterface",
        method = "punchOriginalData",
        version = "2.0.0",
        params = { key },
        logid = "",
        spanid = 0,
    }))
    sock:close()
    return true
end

function _M.new()
    -- 获取request body
    ngx.req.read_body()

    -- 默认成功返回值  默认数据 默认考勤类型
    local response = successResponse
    local data = ngx.req.get_body_data()
    local data_type = 1

    -- 确保获取body的值
    if nil == data then
        local file_name = ngx.req.get_body_file()
        if file_name then
            local f = assert(io.open(file_name, 'r'))
            data = f:read("*all")
            f:close()
        end
    end

    if nil == data then
        ngx.log(ngx.ERR, "lua cannot get request body:", os.time())
        return false
    end

    --  根据不同路由处理数据
    local uri = string.lower(ngx.var.request_uri)
    if uri == "/board2/students/attendance" then
        -- 班牌
        data_type = 1
    elseif uri == "/smartcard/receive" then
        -- 苏州闸机
        data_type = 2
    elseif uri == "/smartcard/checkin" then
        -- 南湖闸机
        data_type = 3
    elseif uri == "/service/webservicenowsdl" then
        -- 长沙闸机
        data_type = 4
        if not (string.match(data, "insertKqInfoService")) then
            return ngx.exec('/index.php/service/WebServiceNoWsdl')
        end
        data = string.match(data, '<param2 xsi:type="xsd:string">(.+)</param2>')
        response = csSuccessResponse
    elseif uri == "/gate/receive" then
        -- 灌灌闸机
        data_type = 5
    else
        ngx.say(json.encode({
            status = 0,
            message = "不支持的路由",
            data = {},
        }))
        return false
    end
    local redisKey = write_to_redis(data_type, data, response)
    if not (redisKey) then
        return false
    end
    if not (send_to_rpc(redisKey)) then
        return false
    end
    ngx.say(response)
    return true
end

return _M