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

local mysql = require "resty.mysql"
local json = require "cjson"
local md5 = require 'md5'
json.encode_empty_table_as_object(false)

function _M.new()
    local db, err = mysql:new()
    if not db then
        ngx.say("failed to instantiate mysql: ", err)
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
        ngx.log(ngx.ERR, "failed to connect: ", connectErr, ": ", errCode, " ", sqlstate)
        return false
    end
    local xhb_token = ""
    local arg = ngx.req.get_uri_args()
    for k, v in pairs(arg) do
        if "xhb_token" == k then
            xhb_token = v
            break
        end
    end
    if #xhb_token == 0 or "phone.error" == xhb_token then
        ngx.say(json.encode({
            status = 0,
            message = "参数错误",
            data = {},
        }))
        return
    end

    local sql1 = [[
    SELECT
        u.user_id,
        u.username,
        u.last_login_role,
        u.auth_level,
        om.id AS member_id,
        u.token
    FROM
        users u
        LEFT JOIN organization_members om ON u.user_id = om.user_id
    WHERE
        u.xhb_user_token = ']] .. xhb_token .. [['
        AND u.banned = '0'
        AND om.`status` = 1
        LIMIT 1
    ]]
    local res = db:query(sql1)
    if not res or table.getn(res) == 0 then
        ngx.say(json.encode({
            status = 0,
            message = "用户信息不存在",
            data = {},
        }))
        return
    end
    local userInfo = {}
    for _, v in pairs(res) do
        userInfo = v
        break
    end

    local memberId = userInfo.member_id

    local sql2 = [[
    SELECT
        a.id as object_id,
        a.user_id,
        u.username,
        a.truename,
        a.avatar,
        a.mobile,
        a.organization_id,
        a.vacationTime,
        IFNULL(GROUP_CONCAT(DISTINCT teach.class_id),'') AS class_ids,
        IFNULL(GROUP_CONCAT(DISTINCT class.id),'') AS head_class_ids,
        IFNULL(GROUP_CONCAT(DISTINCT teach.subject_id),'') AS subject_ids,
        oc.terms,
        ot.term_year,
        ot.term_semester,
        o.title AS organization_title,
        o.type,
        IFNULL(dm.department_id, 0) as major_department_id,
        IFNULL(b.title, '') AS major_department,
        IFNULL(sm.subject_id, 0) AS major_subject_id,
        IFNULL(c.title, '') as major_subject
    FROM
        organization_members a
        LEFT JOIN users u ON u.user_id = a.user_id
        LEFT JOIN organization_classes class ON class.head_id = a.id AND a.organization_id = class.organization_id
        LEFT JOIN organizations o ON o.id = a.organization_id
        LEFT JOIN organization_configs oc ON oc.organization_id = a.organization_id
        LEFT JOIN organization_teachings teach ON teach.member_id = a.id AND teach.terms = oc.terms AND a.organization_id = teach.organization_id
        LEFT JOIN organization_terms ot ON oc.terms = ot.id AND ot.status = 1
        LEFT JOIN department_members dm ON dm.member_id=a.id AND dm.main = 1
        LEFT JOIN organization_departments b ON dm.department_id = b.id AND a.organization_id = b.organization_id
        LEFT JOIN subject_members sm ON sm.member_id=a.id AND sm.main = 1
        LEFT JOIN organization_subjects c ON sm.subject_id = c.id AND a.organization_id = c.organization_id
    WHERE
        a.id = ]] .. memberId .. [[
        AND o.`status` <> -1
        AND o.id IS NOT NULL
    GROUP BY
        a.id
    ]]
    local res2, err2, code2, sqlstate2 = db:query(sql2)
    if not res2 or table.getn(res2) == 0 then
        ngx.say(json.encode({
            status = 0,
            message = "数据库错误1",
            data = {},
        }))
        ngx.log(ngx.ERR, "failed to get org info by member_id: ", err2, ": ", code2, " ", sqlstate2)
        return
    end
    local memberInfo = {}
    for _, v in pairs(res2) do
        memberInfo = v
        break
    end

    local orgId = memberInfo.organization_id
    local sql3 = [[
    SELECT
        m.id
    FROM
        acl a
        LEFT JOIN acl_actions aa ON aa.action_id = a.action_id
        LEFT JOIN modules m ON m.acl_category_id = aa.category_id
    WHERE
        a.member_id = ]] .. memberId .. [[
        AND a.organization_id = ]] .. orgId .. [[
        AND m.id IS NOT NULL
    ]]
    local res3, err3, code3, sqlstate3 = db:query(sql3)
    if not res3 then
        ngx.say(json.encode({
            status = 0,
            message = "数据库错误",
            data = {},
        }))
        ngx.log(ngx.ERR, "failed to get manager module info: ", err3, ": ", code3, " ", sqlstate3)
        return
    end
    local myModules = {}
    for k, v in pairs(res3) do
        myModules[k] = v.id
    end

    local sql4 = "select terms from organization_configs where organization_id = " .. orgId
    local res4, err4, code4, sqlstate4 = db:query(sql4)
    if not res4 or table.getn(res4) == 0 then
        ngx.say(json.encode({
            status = 0,
            message = "数据库错误",
            data = {},
        }))
        ngx.log(ngx.ERR, "failed to get org config info: ", err4, ": ", code4, " ", sqlstate4)
        return
    end
    local terms = 0
    for _, v in pairs(res4) do
        terms = v.terms
        break
    end

    local sql5 = "SELECT IFNULL(GROUP_CONCAT(DISTINCT id),'') AS ids FROM organization_classes oc WHERE organization_id = " .. orgId .. " AND terms=" .. terms .. " AND head_id=" .. memberId .. " AND `status`=1";
    local res5, err5, code5, sqlstate5 = db:query(sql5)
    if not res5 then
        ngx.say(json.encode({
            status = 0,
            message = "数据库错误",
            data = {},
        }))
        ngx.log(ngx.ERR, "failed to get org config info: ", err5, ": ", code5, " ", sqlstate5)
        return
    end
    local headClassIds = {}
    for k, v in pairs(res5) do
        headClassIds[k] = v.id
    end

    local sql6 = [[
        SELECT
            IFNULL(GROUP_CONCAT( category_code ),"") AS codes
        FROM
            acl
            LEFT JOIN acl_actions a ON acl.action_id = a.action_id
            LEFT JOIN acl_categories ac ON ac.category_id = a.category_id 
        WHERE
            acl.member_id = ]] .. memberId .. [[
            AND acl.organization_id =
    ]] .. orgId
    local res6, err6, code6, sqlstate6 = db:query(sql6)
    if not res6 or table.getn(res6) == 0 then
        ngx.say(json.encode({
            status = 0,
            message = "数据库错误",
            data = {},
        }))
        ngx.log(ngx.ERR, "failed to get org config info: ", err6, ": ", code6, " ", sqlstate6)
        return
    end
    local modulePermissions = ""
    for _, v in pairs(res6) do
        modulePermissions = v.codes
        break
    end
    local userToken = md5.sumhexa(tostring(userInfo.user_id))
    if userToken ~= userInfo.token then
        db:query("update users set token = '" .. userToken .. "' where user_id = " .. userInfo.user_id)
    end

    db:set_keepalive(db_keepalive, db_pool_size)

    memberInfo.modules = myModules
    memberInfo.head_classes = headClassIds
    memberInfo.module_permissions = modulePermissions

    local successResponse = json.encode({
        status = 1,
        message = "",
        data = {
            user_info = memberInfo,
            user_token = userToken,
            username = userInfo.username,
        },
    })
    ngx.say(successResponse)
    return
end

return _M
