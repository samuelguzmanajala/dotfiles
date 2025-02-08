DELETE FROM brand_ian_gross_margin_update
    USING brand_ian_gross_margin
WHERE brand_ian_gross_margin_update.gross_margin_id = brand_ian_gross_margin.id
  AND ((brand_ian_gross_margin.year = 2025 AND brand_ian_gross_margin.month = 8) OR (brand_ian_gross_margin.year = 2025 AND brand_ian_gross_margin.month = 9));
;-- -. . -..- - / . -. - .-. -.--
DELETE FROM brand_ian_update
    USING brand_ian_forecast
WHERE brand_ian_update.forecast_record_id = brand_ian_forecast.id
  AND ((brand_ian_forecast.year = 2025 AND brand_ian_forecast.month = 8) OR (brand_ian_forecast.year = 2025 AND brand_ian_forecast.month = 9));
;-- -. . -..- - / . -. - .-. -.--
DELETE FROM brand_ian_gross_margin
WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9);
;-- -. . -..- - / . -. - .-. -.--
DELETE FROM brand_ian_forecast
WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9);
;-- -. . -..- - / . -. - .-. -.--
CREATE TEMP TABLE temp_margin_data (
                                       article_code TEXT,
                                       branch_id BIGINT,
                                       client_code TEXT,
                                       year INTEGER,
                                       month INTEGER,
                                       atypical NUMERIC,
                                       rappels NUMERIC,
                                       sell_commissions NUMERIC,
                                       returns NUMERIC,
                                       insurance_premium NUMERIC,
                                       various NUMERIC,
                                       sell_price NUMERIC,
                                       direct_cost NUMERIC,
                                       transport NUMERIC,
                                       distribution_commissions NUMERIC,
                                       green_point NUMERIC,
                                       transfers NUMERIC,
                                       other_sales_transport_expenses NUMERIC,
                                       aiem_cost NUMERIC,
                                       inventory_cost_adjustment NUMERIC,
                                       aux_inventory_adjustments NUMERIC,
                                       warehouse_labor NUMERIC
);
;-- -. . -..- - / . -. - .-. -.--
select * from brand_ian_gross_margin gm
where (gm.year = 2025 AND gm.month = 8) OR (gm.year = 2025 AND gm.month = 9);
;-- -. . -..- - / . -. - .-. -.--
CREATE TEMP TABLE temp_forecast_data (
                                         article_code TEXT,
                                         branch_id BIGINT,
                                         client_code TEXT,
                                         year INTEGER,
                                         month INTEGER,
                                         quantity NUMERIC
);
;-- -. . -..- - / . -. - .-. -.--
SELECT pg_get_serial_sequence('public.brand_ian_gross_margin', 'id');
;-- -. . -..- - / . -. - .-. -.--
BEGIN;
;-- -. . -..- - / . -. - .-. -.--
CREATE TEMP TABLE temp_forecast_data (
                                         article_code TEXT,
                                         branch_id BIGINT,
                                         branch TEXT,
                                         client_code TEXT,
                                         year INTEGER,
                                         month INTEGER,
                                         quantity NUMERIC
);