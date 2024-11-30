# Как проверить

Важно, контейнерам подняться тоже надо время.

## Nginx

конфиг `configs/nginx.tpl...`

0. Нюанс: тут хз как указать PORT для контейнера, поэтому он должен уметь определять значение по умолчанию
1. Включаем публичный ip
2. Заходим по ssh на тачку: `ssh -i ycvm yc-user@<PUBLIC_IP>`
3. Смотрим `docker ps`, видим наши контейнеры
4. Идем `http://PUBLIC_IP:8081/index.html`, видим наш сайт
5. Идем `http://PUBLIC_IP:8082/index.html`, видим наш сайт

## Postgres

конфиг `configs/postgres.tpl...`

Поднимаем все то, что в compose. Проверяем через websql.yandex.cloud


