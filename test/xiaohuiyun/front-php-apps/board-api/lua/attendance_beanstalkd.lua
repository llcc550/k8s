local beanstalkd_ip = "beanstalkd.xiaohuiyun.svc.cluster.local"
local beanstalkd_port = 11300
local beanstalkd_tube = "studentattendance"
local beanstalkd_keepalive = 60000
local beanstalkd_pool_size = 100

local db_host = "mysql.xiaohuiyun.svc.cluster.local"
local db_port = 3306
local db_database = "ujy_release"
local db_user = "64b7xdry"
local db_password = "OqXr4siPQa8Uekul"
local db_set_timeout = 2000
local db_keepalive = 60000
local db_pool_size = 200

local _M = {}
_M._VERSION = "1.0"

local beanstalkd = require "beanstalkd"
local json = require "cjson"
local mysql = require "resty.mysql"

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
                    <m:GetEndorsingBoarderResponse xmlns:m="https://api.u-jy.cn/service/WebServiceNoWsdl">
                      <endorsingBoarder>
                        {"returnCode":"000","insertKqInfo":[{"COLNUM":"1"}]}
                      </endorsingBoarder>
                    </m:GetEndorsingBoarderResponse>
                  </SOAP-ENV:Body>
                </SOAP-ENV:Envelope>
            ]]


local function write_log(data_type, data)
    local db, err = mysql:new()
    if not db then
        ngx.log(ngx.ERR, "failed to instantiate mysql: ", err)
        return
    end
    db:set_timeout(db_set_timeout)
    local ok, connectErr, errCode, sqlstate = db:connect {
        host = db_host,
        port = db_port,
        database = db_database,
        user = db_user,
        password = db_password,
        charset = "utf8mb4",
        max_packet_size = 1024 * 1024,
    }
    if not ok then
        ngx.log(ngx.ERR, "failed to connect mysql: ", connectErr, ": ", errCode, " ", sqlstate)
        return
    end
    local logSql = "INSERT INTO punch_log (from_type, data) VALUES (" .. data_type .. ", '" .. data .. "')"
    db:query(logSql)
    db:set_keepalive(db_keepalive, db_pool_size)
end

local function write_to_beanstalkd(data_type, data)
    local valueString = json.encode({
        type = data_type,
        data = data,
    })
    local bean, err1 = beanstalkd:new()
    if not bean then
        ngx.log(ngx.ERR, "cannot new beanstalkd:", err1)
        return false
    end

    local ok2, err2 = bean:connect(beanstalkd_ip, beanstalkd_port)
    if not ok2 then
        ngx.log(ngx.ERR, "cannot connect beanstalkd:", err2)
        return false
    end

    local ok, err = bean:use(beanstalkd_tube)
    if not ok then
        ngx.log(ngx.ERR, "cannot use beanstalkd tube:", err)
        return false
    end

    local id, err3 = bean:put(valueString)
    if not id then
        ngx.log(ngx.ERR, "cannot insert into beanstalkd:", err3)
        return false
    end
    bean:set_keepalive(beanstalkd_keepalive, beanstalkd_pool_size)
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
    if uri == "/board2/students/attendance" then -- 班牌
        data_type = 1
    elseif uri == "/smartcard/receive" then -- 苏州十中闸机
        data_type = 2
    elseif uri == "/gate/receive" then -- 通用闸机
        data_type = 5
    elseif uri == "/service/webservicenowsdl" then -- 长沙闸机
        data_type = 4
        if not (string.match(data, "insertKqInfoService")) then
            return ngx.exec('/index.php/service/WebServiceNoWsdl')
        end
        data = string.match(data, '<param2 xsi:type="xsd:string">(.+)</param2>')
        response = csSuccessResponse
    else
        ngx.say(json.encode({
            status = 0,
            message = "不支持的路由",
            data = {},
        }))
        return false
    end
    write_log(data_type, data)
    write_to_beanstalkd(data_type, data)

    ngx.say(response)
    return true
end

return _M