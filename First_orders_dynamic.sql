-- Для каждого дня, представленного в таблице user_actions, рассчитаем общее число заказов, число первых заказов (заказов, сделанных пользователями впервые, число заказов новых пользователей (заказов, сделанных пользователями в тот же день, когда они впервые воспользовались сервисом), долю первых заказов в общем числе заказов и долю заказов новых пользователей в общем числе заказов.

WITH not_cancelled_orders_cte AS 
(
SELECT 
    time, 
    user_id, 
    order_id
FROM user_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
),
first_orders_cte AS
(
SELECT
    time::DATE AS date,
    COUNT(order_id) AS orders,
    COUNT(order_id) FILTER(WHERE order_id IN (SELECT order_id
                                              FROM (SELECT *, MIN(time) OVER(PARTITION BY user_id ORDER BY time) 
                                                    FROM not_cancelled_orders_cte) t
                                              WHERE time = min)) AS first_orders
FROM not_cancelled_orders_cte
GROUP BY date
ORDER BY date
),
new_users_orders_cte AS
(
SELECT 
    first_action_date AS date, 
    SUM(orders_count)::INT AS new_users_orders
FROM
    (SELECT
        t1.user_id, first_action_date, orders_count
    FROM
        (SELECT user_id, MIN(time)::DATE as first_action_date
        FROM user_actions
        GROUP BY user_id) t1
        LEFT JOIN
            (SELECT time::DATE AS date, user_id, COUNT(order_id) AS orders_count
            FROM user_actions
            WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
            GROUP BY date, user_id
            ORDER BY date) t2
        ON t1.user_id = t2.user_id AND t1.first_action_date = t2.date) t3
GROUP BY date
ORDER BY date
)

SELECT 
    date, orders, first_orders, new_users_orders,
    ROUND(first_orders/orders::DECIMAL*100, 2) AS first_orders_share,
    ROUND(new_users_orders/orders::DECIMAL*100, 2) AS new_users_orders_share
FROM first_orders_cte
JOIN new_users_orders_cte USING(date)