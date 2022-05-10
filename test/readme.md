> ip 124.71.163.192

1. 测试环境基础服务

- [x] 数据库
    - postgres:dinghao8888@122.112.230.215:5432/demacia
- [x] websocket
    - 124.71.163.192:32301
    - 124.71.163.192:32302
    - 124.71.163.192:32303
- [x] socket
    - 124.71.163.192:32304
- [x] kafka
    - 124.71.163.192:32420
    - 124.71.163.192:32421
    - 124.71.163.192:32422
- [x] mongodb
    - 124.71.163.192:32500
- [x] redis
    - demacia
        - 124.71.163.192:32600
    - xiaohuiyun
        - 124.71.163.192:32601
    - zaun
        - 124.71.163.192:32602
- [x] beanstalkd
    - 124.71.163.192:32700
    - 124.71.163.192:32701
    - 124.71.163.192:32702
- [x] dtm:
    - 124.71.163.192:31790

2. 测试环境RPC端口列表

- demacia

| rpc             | port  |
|-----------------|-------|
| databus         | 32000 |
| organization    | 32001 |
| common          | 32002 |
| member          | 32003 |
| class           | 32004 |
| websocket       | 32005 |
| user            | 32006 |
| card            | 32007 |
| device          | 32008 |
| student         | 32009 |
| subject         | 32010 |
| position        | 32011 |
| department      | 32012 |
| coursetable-rpc | 32013 |
| tags-rpc        | 32014 |
| capacity-rpc    | 32015 |
| permission-rpc  | 32016 |
| face-rpc        | 32017 |
| socket-rpc      | 32018 |
| devicecontrol-rpc      | 32019 |

- xiaohuiyun

| rpc               | port  |
|-------------------|-------|
| acl               | 31001 |
| addressbook       | 31002 |
| apk               | 31003 |
| attachment        | 31004 |
| captcha           | 31005 |
| card              | 31006 |
| classes           | 31007 |
| cloudscreenmodule | 31008 |
| customboard       | 31009 |
| department        | 31010 |
| deviceposition    | 31011 |
| dorm              | 31012 |
| face              | 31013 |
| member            | 31014 |
| organization      | 31015 |
| pdf               | 31016 |
| reddot            | 31017 |
| sms               | 31018 |
| socketpush        | 31019 |
| studentparent     | 31020 |
| subject           | 31021 |
| tenant            | 31022 |
| timetable         | 31023 |
| trip              | 31024 |
| user              | 31025 |
| vacation          | 31026 |
| wechat            | 31027 |
