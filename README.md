# Комплексный анализ данных сервиса по доставке продуктов

**Цель:** написание SQL-запросов для анализа динамики роста аудитории сервиса и ключевых продуктовых метрик, а также сравнение результатов двух рекламных кампаний продукта  
**Стэк:** SQL, PostgreSQL, Redash

В данном проекте реализованы сложные SQL-запросы к базе данных food delivery-сервиса с применением оконных функций, cte и подзапросов. Запросы написаны в интерфейсе платформы Redash, там же собирался финальный дашборд.
Таблицы, представленные в данных: `courier_actions` - действия курьеров, `user_actions` - действия пользователей, `users` - данные пользователей, `couriers` - данные курьеров, `products` - перечень сведений о товарах и их цене, `orders` - логи с заказами.
Схема представлена ниже:

<img width="250" alt="Снимок экрана 2025-02-03 в 14 51 16" src="https://github.com/user-attachments/assets/aed41514-81d1-447b-ad72-c744c949c2cb" />

<p>

С текстом запросов можно ознакомиться в соответствущих .sql файлах.  

**Результаты:**  
### *NB: с полным результирующим дашбордом можно ознакомиться по <a href="https://redash.public.karpov.courses/public/dashboards/SHqgx2Wj8aA0MNHbroRKl3uGAdDG6DYz3ESGsmg0?org_slug=default" target="_blank">ссылке</a>*

1) Построены графики с динамикой ежедневного прироста пользователей и курьеров в абсолютных и относительных величинах

New users and couriers dynamic / change 

<img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/New%20users%3Acouriers%20dynamic.png" width="500"> <img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/New%20users%3Acouriers%20change.png" width="500">  

Total users and couriers dynamic / change 

<img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/Total%20users%3Acouriers%20dynamic.png" width="500"> <img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/Total%20users%3Acouriers%20growth.png" width="500">

2) Проанализирована динамика заказов

First orders dynamic  

<img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/First%20orders%20dynamic.png">

Cancel rate per hour dynamic  

<img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/Cancel%20rate%20per%20hour%20dynamic.png">

3) Проанализирована динамика основных метрик: revenue, ARPU, ARPPU, AOV (текущие и накопленные)

Daily revenue  

<img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/Daily%20revenue.png">

Main metrics / Running metrics  

<img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/Main%20metrics.png" width="500"> <img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/Running%20metrics.png" width="500">

4) Проанализированы результаты двух рекламных кампаний по метрикам: CAC, ROI, Retention, AOV

CAC

<img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/Customer%20Acquisition%20Cost_Ads%20campain.png" width="500">

ROI  

<img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/Return%20of%20Investments_Ads%20campain.png" width="500">  

AOV

<img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/Average%20Check%20Ads%20campain.png" height="100">

Retention 1st day and 7th day 

<img src="https://github.com/irina-asadullina/Food_delivery_app_analysis_SQL_Dashboard/blob/main/images/Retention_Ads_campain.png" width="500">

## Итоги:

Несмотря на то, что вторая кампания оказалась дешевле в плане затрат на привлечение одного пользователя, её рентабельность в полтора десятка раз ниже, чем у первой рекламной капмании. Пользователи из обоих рекламных каналов практически не различаются по среднему чеку, но Retention первого и седьмого дня почти в два раза выше у первой группы. Это и приводит к тому, что пользователи из первой группы приносят в сервис больше денег.
