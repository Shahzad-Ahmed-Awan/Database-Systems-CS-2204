-- ============================================================
--  REPORTING QUERIES
-- ============================================================
 
-- -------------------------------------------------------
-- Report 1: Full order summary with customer and status
-- -------------------------------------------------------
SELECT
    o.order_id,
    u.name          AS customer_name,
    u.email         AS customer_email,
    os.status_name  AS order_status,
    d.discount_code AS applied_discount,
    o.order_date,
    o.total_amount
FROM orders o
JOIN users        u  ON o.user_id    = u.user_id
JOIN order_status os ON o.status_id  = os.status_id
LEFT JOIN discounts d ON o.discount_id = d.discount_id
ORDER BY o.order_date DESC;
 
-- -------------------------------------------------------
-- Report 2: Itemised receipt — products per order
-- -------------------------------------------------------
SELECT
    o.order_id,
    u.name          AS customer,
    p.name          AS product,
    oi.quantity,
    oi.price_at_purchase,
    oi.subtotal
FROM order_items oi
JOIN orders   o ON oi.order_id   = o.order_id
JOIN users    u ON o.user_id     = u.user_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id, p.name;
 
-- -------------------------------------------------------
-- Report 3: Total revenue per customer
-- -------------------------------------------------------
SELECT
    u.user_id,
    u.name                        AS customer_name,
    COUNT(DISTINCT o.order_id)    AS total_orders,
    SUM(o.total_amount)           AS total_spent
FROM users  u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name
ORDER BY total_spent DESC;
 
-- -------------------------------------------------------
-- Report 4: Revenue by product category
-- -------------------------------------------------------
SELECT
    c.category_name,
    COUNT(oi.order_item_id)  AS items_sold,
    SUM(oi.subtotal)         AS category_revenue
FROM order_items oi
JOIN products   p ON oi.product_id  = p.product_id
JOIN categories c ON p.category_id  = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY category_revenue DESC;
 
-- -------------------------------------------------------
-- Report 5: Current inventory status
-- -------------------------------------------------------
SELECT
    p.product_id,
    p.name                    AS product_name,
    i.quantity_on_hand,
    i.reserved_quantity,
    i.available_stock,
    ss.status                 AS stock_status
FROM inventory i
JOIN products     p  ON i.product_id      = p.product_id
JOIN stock_status ss ON i.stock_status_id = ss.stock_status_id
ORDER BY i.available_stock ASC;
 
-- -------------------------------------------------------
-- Report 6: Payment summary per order
-- -------------------------------------------------------
SELECT
    o.order_id,
    u.name                   AS customer,
    o.total_amount           AS order_total,
    SUM(py.amount_paid)      AS total_paid,
    o.total_amount - SUM(py.amount_paid) AS balance_due,
    GROUP_CONCAT(pm.method_name ORDER BY py.payment_id SEPARATOR ', ')
                             AS payment_methods_used
FROM orders o
JOIN users          u  ON o.user_id          = u.user_id
JOIN payments       py ON o.order_id         = py.order_id
JOIN payment_methods pm ON py.payment_method_id = pm.method_id
GROUP BY o.order_id, u.name, o.total_amount
ORDER BY o.order_id;
 
-- -------------------------------------------------------
-- Report 7: Active discounts overview
-- -------------------------------------------------------
SELECT
    d.discount_code,
    d.description,
    d.discount_type,
    d.discount_value,
    d.min_order_amount,
    COALESCE(p.name, 'All Products')          AS applies_to_product,
    COALESCE(c.category_name, 'All Categories') AS applies_to_category,
    d.start_date,
    d.end_date
FROM discounts d
LEFT JOIN products   p ON d.product_id  = p.product_id
LEFT JOIN categories c ON d.category_id = c.category_id
WHERE d.is_active = 1
ORDER BY d.end_date ASC;
 
-- -------------------------------------------------------
-- Report 8: Best-selling products by quantity sold
-- -------------------------------------------------------
SELECT
    p.product_id,
    p.name              AS product_name,
    c.category_name,
    SUM(oi.quantity)    AS total_units_sold,
    SUM(oi.subtotal)    AS total_revenue
FROM order_items oi
JOIN products   p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_id, p.name, c.category_name
ORDER BY total_units_sold DESC;
 