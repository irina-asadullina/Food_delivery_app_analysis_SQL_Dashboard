-- 1. Для каждого дня в таблице orders рассчитаем выручку, полученную в этот день, суммарную выручку на текущий день и прирост выручки относительно значения за предыдущий день.

SELECT 
    date, 
    revenue::INT,
    SUM(revenue) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::INT AS total_revenue,
    ROUND((revenue - LAG(revenue) OVER()) / LAG(revenue) OVER()::DECIMAL * 100, 2) AS revenue_change
FROM
    (SELECT
        date,
        SUM(price) AS revenue
     FROM    
        (SELECT order_id, creation_time::DATE as date, SUM(price) AS price
         FROM
               (SELECT order_id, creation_time, UNNEST(product_ids) AS product_id
                FROM orders
                WHERE order_id NOT IN (SELECT order_id 
                                       FROM user_actions 
                                       WHERE action = 'cancel_order')) o
         JOIN products p USING(product_id)
         GROUP BY date, order_id) t
     GROUP BY date) t1
ORDER BY date

-- 2. Для каждого дня в таблицах orders и user_actions рассчитаем основные метрики: ARPU, ARPPU и AOV.

WITH cte1 AS ( --выручка за день
SELECT
    date, COUNT(DISTINCT order_id) AS orders, SUM(price) AS revenue
FROM
    (SELECT 
        creation_time::DATE as date,
        order_id,
        UNNEST(product_ids) AS product_id
    FROM orders
    WHERE order_id NOT IN(SELECT order_id FROM user_actions WHERE action = 'cancel_order')) o
JOIN products p USING(product_id)
GROUP BY date),

cte2 AS ( --количество юзеров в день
SELECT time::DATE as date, COUNT(DISTINCT user_id) AS users
FROM user_actions
GROUP BY date),

cte3 AS ( --количество платящих юзеров в день
SELECT 
    time::DATE as date, 
    COUNT(DISTINCT user_id) FILTER(WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS paying_users
FROM user_actions
GROUP BY date)


SELECT 
    date,
    ROUND(revenue/users, 2) AS arpu,
    ROUND(revenue/paying_users,2) AS arppu,
    ROUND(revenue/orders,2) AS aov
FROM cte1
JOIN cte2 USING(date)
JOIN cte3 USING(date)
ORDER BY date


-- 3. Теперь рассчитаем эти же метрики, но в виде накопленных: Running ARPU, Running ARPРU и Running AOV.

WITH cte1 AS ( -- накопленная выручка и к-во заказов за день
SELECT 
    date,
    SUM(orders) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_orders,
    SUM(revenue) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue
FROM
    (SELECT
        date, COUNT(DISTINCT order_id) AS orders, SUM(price) AS revenue
    FROM
        (SELECT 
            creation_time::DATE as date,
            order_id,
            UNNEST(product_ids) AS product_id
        FROM orders
        WHERE order_id NOT IN(SELECT order_id FROM user_actions WHERE action = 'cancel_order')) o
    JOIN products p USING(product_id)
    GROUP BY date) t
),

cte2 AS ( -- накопленное количество юзеров в день
SELECT date, SUM(new_users) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_users
FROM (
    SELECT date, count(distinct user_id) as new_users
    FROM
        (
        SELECT user_id, order_id,
            min(time) OVER(PARTITION BY user_id)::date as date
         FROM   user_actions
         ) t1
    GROUP BY date
    ) t2
),

cte3 AS ( -- накопленное количество платящих юзеров в день
SELECT date, SUM(new_users) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_paying_users
FROM
    (SELECT date, count(distinct user_id) as new_users
    FROM
        (
        SELECT user_id, order_id,
            min(time) OVER(PARTITION BY user_id)::date as date
         FROM   user_actions
         WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
         ) t1
    GROUP BY date) t3
)

SELECT 
    date,
    ROUND(running_revenue / running_users, 2) AS running_arpu,
    ROUND(running_revenue / running_paying_users,2) AS running_arppu,
    ROUND(running_revenue / running_orders,2) AS running_aov
FROM cte1
JOIN cte2 USING(date)
JOIN cte3 USING(date)
ORDER BY date

