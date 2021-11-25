FROM openjdk:8-jdk
LABEL maintainer="zww 1103193859@qq.com"

ADD target/spider-flow.jar /app.jar

# 可映射的端口号
EXPOSE 8088
ENTRYPOINT ["sh","-c","java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/usr/local/app/oom -jar /app.jar"]
