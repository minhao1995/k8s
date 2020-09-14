FROM frolvlad/alpine-java:jdk8-slim
ARG profile
ENV SPRING_PROFILES_ACTIVE=${profile}
EXPOSE 80
WORKDIR /mnt

#修改时区
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* $HOME/.cache

COPY ./target/k8sDemo.jar ./app.jar
ENTRYPOINT ["java", "-jar", "/mnt/app.jar"]
