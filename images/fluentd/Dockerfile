FROM swr.cn-east-3.myhuaweicloud.com/wx-xiaoyang-public/fluentd:v1.14-1
USER root
RUN ["gem", "install", "fluent-plugin-elasticsearch"]
RUN ["gem", "install", "fluent-plugin-detect-exceptions"]
RUN ["gem", "install", "fluent-plugin-concat"]
RUN ["gem", "install", "fluent-plugin-multi-format-parser"]
USER fluent
