# Как проверить

1. Включаем публичный ip
2. Заходим по ssh на тачку: `ssh -i ycvm yc-user@<PUBLIC_IP>`
3. Смотрим `docker ps`, видим наш контейнер
4. Идем `http://PUBLIC_IP/index.html`, видим наш сайт
