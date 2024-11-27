ARG NGINX_VERSION=1.17.6

FROM nginx:${NGINX_VERSION}

# Копируем шаблон конфигурации
COPY ./conf.d /etc/nginx/conf.d
# COPY nginx.conf.template /etc/nginx/nginx.conf.template

# Копируем скрипт запуска
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD [ "/start.sh" ]

# COPY ./conf.d /etc/nginx/conf.d
# EXPOSE 8080
