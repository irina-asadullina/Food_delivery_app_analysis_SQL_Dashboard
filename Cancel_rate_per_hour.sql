-- На основе данных в таблице orders для каждого часа в сутках рассчитаем число успешных (доставленных) заказов, число отменённых заказов и долю отменённых заказов в общем числе заказов (cancel rate).

SELECT 
    DATE_PART('hour', creation_time)::INT AS hour,
    COUNT(order_id) FILTER (WHERE order_id IN (SELECT order_id 
                                                 FROM courier_actions 
                                                WHERE action = 'deliver_order')) AS successful_orders,
    COUNT(order_id) FILTER (WHERE order_id IN (SELECT order_id 
                                                 FROM user_actions
                                                WHERE action = 'cancel_order')) AS canceled_orders,
    ROUND(COUNT(order_id) FILTER (WHERE order_id IN (SELECT order_id 
                                                       FROM user_actions 
                                                      WHERE action = 'cancel_order')) / COUNT(order_id)::DECIMAL, 3) AS cancel_rate 
 FROM orders
GROUP BY hour
ORDER BY hour