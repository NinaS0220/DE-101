# Задание для модуля 2

## Установка БД
Установлен Postgres.

## Загрузка данных в БД
Загружены данные скриптами orders.sql, people.sql, returns.sql (был исправлен во время загрузки).

## SQL запросы
Было написано 14 скриптов по основному списку аналитики плюс некоторые вариации.
1.Overview (обзор ключевых метрик)
Total Sales
Total Profit
Profit Ratio
Profit per Order
Sales per Customer
Avg. Discount
Monthly Sales by Segment ( табличка и график)
Monthly Sales by Product Category (табличка и график)

2.Product Dashboard (Продуктовые метрики)
Sales by Product Category over time (Продажи по категориям)

3.Customer Analysis
Sales and Profit by Customer
Customer Ranking
Sales per region

## Нарисовать модель данных в SQLdbm

Нарисованы Концептуальная, Логическая и Физическая в SqlDBM.
Создан DDL запрос через SqlDBM.
Заполены таблицы Dimensions и Sales fact через INSERT INTO. Скрипт приложен (DDL_Dimension.sql)