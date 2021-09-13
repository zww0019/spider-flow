FROM openjdk:8-jdk
LABEL maintainer="zww 1103193859@qq.com"
RUN apk add --no-cache tzdata \
    && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone
ENV TZ Asia/Shanghai

ADD target/spider-flow.jar /app.jar


ENTRYPOINT ["sh","-c","java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/usr/local/app/oom -jar /app.jar"]
