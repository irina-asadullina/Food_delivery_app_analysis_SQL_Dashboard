-- Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитаем число новых пользователей, число новых курьеров, общее число пользователей на текущий день и общее число курьеров на текущий день, прирост числа новых пользователей и курьеров, прирост общего числа пользователей и курьеров.

WITH new_couriers_and_users AS
(
SELECT
    c.date, c.new_couriers, u.new_users
FROM
    (SELECT
        date,
        COUNT(DISTINCT courier_id) AS new_couriers
    FROM
        (SELECT 
            courier_id,
            order_id, 
            MIN(time) OVER(PARTITION BY courier_id)::DATE AS date
        FROM courier_actions) t1
    GROUP BY date) c
JOIN
    (SELECT
        date,
        COUNT(DISTINCT user_id) AS new_users
    FROM
        (SELECT 
            user_id,
            order_id, 
            MIN(time) OVER(PARTITION BY user_id)::DATE AS date
        FROM user_actions) t2
    GROUP BY date) u USING(date)
)

SELECT 
    date, new_users, new_couriers, total_users, total_couriers,
    ROUND((new_users - LAG(new_users) OVER()) / LAG(new_users) OVER()::DECIMAL*100, 2) AS new_users_change,
    ROUND((new_couriers - LAG(new_couriers) OVER()) / LAG(new_couriers) OVER()::DECIMAL*100, 2) AS new_couriers_change,
    ROUND((total_users - LAG(total_users) OVER()) / LAG(total_users) OVER()::DECIMAL*100, 2) AS total_users_growth,
    ROUND((total_couriers - LAG(total_couriers) OVER()) / LAG(total_couriers) OVER()::DECIMAL*100, 2) AS total_couriers_growth
FROM
    (SELECT 
        date, new_users, new_couriers,
        SUM(new_users) OVER(ORDER BY date)::INT AS total_users,
        SUM(new_couriers) OVER(ORDER BY date)::INT AS total_couriers
     FROM new_couriers_and_users) t1


-- Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитаем число платящих пользователей, число активных курьеров и их доли в общем числе пользователей/курьеров, соответственно.

SELECT 
    date, paying_users, active_couriers,
    ROUND(paying_users*100/total_users::DECIMAL, 2) AS paying_users_share,
    ROUND(active_couriers*100/total_couriers::DECIMAL, 2) AS active_couriers_share
FROM
    (SELECT *
    FROM
    (SELECT 
        time::DATE AS date, 
        COUNT(DISTINCT user_id) FILTER(WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS paying_users
    FROM user_actions
    GROUP BY date) t1
JOIN 
    (SELECT 
        time::DATE AS date, 
        COUNT(DISTINCT courier_id) FILTER(WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS active_couriers
    FROM courier_actions
    GROUP BY date) t2 USING(date)) table1
JOIN
    (SELECT 
        start_date as date,
        (sum(new_users) OVER (ORDER BY start_date))::int as total_users,
        (sum(new_couriers) OVER (ORDER BY start_date))::int as total_couriers
    FROM (SELECT start_date,
                 count(courier_id) as new_couriers
          FROM   (SELECT courier_id,
                         min(time::date) as start_date
                  FROM   courier_actions
                  GROUP BY courier_id) t3
          GROUP BY start_date) t4
    LEFT JOIN 
        (SELECT start_date,
                count(user_id) as new_users
        FROM   (SELECT user_id,
                       min(time::date) as start_date
                FROM   user_actions
                GROUP BY user_id) t5
        GROUP BY start_date) t6 USING(start_date)) table2
USING(date)
ORDER BY date