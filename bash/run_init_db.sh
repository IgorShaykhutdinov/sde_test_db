#!/bin/bash

# скачать docker образ postgres
sudo docker pull postgres:latest

# запустить образ postgres с параметрами
sudo docker run --name mypost \
-e POSTGRES_PASSWORD=@sde_password012 \
-e POSTGRES_USER=test_sde \
-e POSTGRES_DB=demo \
-e PGDATA=/var/lib/postgresql/pgdata \
-p 5432:5432 \
-v "$(pwd)/school/sde_test_db/sql/init_db":/var/lib/postgresql/data -d postgres

# ждем, пока база развернется в контейнере
sleep 5

# заполнить БД данными через выполнение скрипта ./sql/init_db/demo.sql
docker exec -it mypost psql -d demo -U test_sde -f /var/lib/postgresql/data/demo.sql
