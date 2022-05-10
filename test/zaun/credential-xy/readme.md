1. mysql
   - DataSource: user:password@tcp(mysql-ip:mysql-port)/dbName?charset=utf8mb4&parseTime=true&loc=Asia%2FShanghai
2. redis
    - CacheRedis
3. minio
    - MinioConfig
    - 不会自动创建Bucket，对应的Bucket需手动创建
4. imagePullSecrets
5. 单点登录地址 
   - /#/sp/sso?