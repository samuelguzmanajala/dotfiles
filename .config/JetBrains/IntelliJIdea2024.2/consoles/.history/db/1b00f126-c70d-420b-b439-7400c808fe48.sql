SELECT * FROM brand_ian_update
where forecast_record_id in (
    SELECT id from brand_ian_forecast
    WHERE year = 2025 AND month = 9
    );
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM brand_ian_update
where forecast_record_id in (
    SELECT id from brand_ian_forecast
    WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9)
    );
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM brand_ian_update
where forecast_record_id in (
    SELECT id from brand_ian_forecast
    WHERE
        ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    AND updated_at > '2024-10-01'

    );
;-- -. . -..- - / . -. - .-. -.--
SELECT count(*) FROM brand_ian_update
where forecast_record_id in (
    SELECT id from brand_ian_forecast
    WHERE
        ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    AND updated_at > '2024-10-01'

    );
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM brand_ian_update
where forecast_record_id in (
    SELECT id from brand_ian_forecast
    WHERE
        ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    AND updated_at > '2024-10-01'

    )
order by updated_at;
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM brand_ian_update
where forecast_record_id in (
    SELECT id from brand_ian_forecast
    WHERE
        ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    AND updated_at > '2024-10-01'

    )
order by brand_ian_update.created_at;
;-- -. . -..- - / . -. - .-. -.--
SELECT count(*) FROM brand_ian_gross_margin_update
where gross_margin_id in (
    SELECT id from brand_ian_gross_margin
    WHERE
        ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    )
  and created_at > '2024-10-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM brand_ian_gross_margin_update
where gross_margin_id in (
    SELECT id from brand_ian_gross_margin
    WHERE
        ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    )
  and created_at > '2024-10-01'
order by brand_ian_gross_margin_update.created_at;
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM brand_ian_gross_margin
where id in (
    SELECT gross_margin_id FROM brand_ian_gross_margin_update
    where gross_margin_id in (
        SELECT id from brand_ian_gross_margin
        WHERE
            ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    )
      and created_at > '2024-10-01'
    );
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM brand_ian_gross_margin
where id in (
    SELECT gross_margin_id FROM brand_ian_gross_margin_update
    where gross_margin_id in (
        SELECT id from brand_ian_gross_margin
        WHERE
            ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    )
      and created_at > '2024-10-01'
    )
group by article_code;
;-- -. . -..- - / . -. - .-. -.--
SELECT article_code FROM brand_ian_gross_margin
where id in (
    SELECT gross_margin_id FROM brand_ian_gross_margin_update
    where gross_margin_id in (
        SELECT id from brand_ian_gross_margin
        WHERE
            ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    )
      and created_at > '2024-10-01'
    )
group by article_code;
;-- -. . -..- - / . -. - .-. -.--
SELECT count(*) FROM brand_ian_gross_margin
where id in (
    SELECT gross_margin_id FROM brand_ian_gross_margin_update
    where gross_margin_id in (
        SELECT id from brand_ian_gross_margin
        WHERE
            ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    )
      and created_at > '2024-10-01'
    )
group by article_code;
;-- -. . -..- - / . -. - .-. -.--
SELECT count(distinct article_code) FROM brand_ian_gross_margin
where id in (
    SELECT gross_margin_id FROM brand_ian_gross_margin_update
    where gross_margin_id in (
        SELECT id from brand_ian_gross_margin
        WHERE
            ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    )
      and created_at > '2024-10-01'
    );
;-- -. . -..- - / . -. - .-. -.--
SELECT u.*
    FROM brand_ian_gross_margin_update u
    JOIN brand_ian_gross_margin gm ON u.gross_margin_id = gm.id
    WHERE gm.year = 2025 AND gm.month = 9;
;-- -. . -..- - / . -. - .-. -.--
SELECT u.*
    FROM brand_ian_gross_margin_update u
    JOIN brand_ian_gross_margin gm ON u.gross_margin_id = gm.id
    WHERE gm.year = 2025 AND gm.month = 9 and created_at > '2024-10-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT u.*
    FROM brand_ian_gross_margin_update u
    JOIN brand_ian_gross_margin gm ON u.gross_margin_id = gm.id
    WHERE gm.year = 2025 AND gm.month = 9 and u.created_at > '2024-10-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT u.*
    FROM brand_ian_gross_margin_update u
    JOIN brand_ian_gross_margin gm ON u.gross_margin_id = gm.id
    WHERE gm.year = 2025 AND gm.month = 9 and u.created_at > '2024-10-01'
    ORDER BY u.created_at;
;-- -. . -..- - / . -. - .-. -.--
SELECT u.*
    FROM brand_ian_update u
             JOIN brand_ian_forecast f ON u.forecast_record_id = f.id
    WHERE f.year = 2025 AND f.month = 9 and u.created_at > '2024-10-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT u.*
    FROM brand_ian_gross_margin_update u
    JOIN brand_ian_gross_margin gm ON u.gross_margin_id = gm.id
    WHERE ((gm.year = 2025 AND gm.month = 8) or (gm.year = 2025 AND gm.month = 9)) and u.created_at > '2024-10-01'
    ORDER BY u.created_at;
;-- -. . -..- - / . -. - .-. -.--
SELECT u.*
    FROM brand_ian_update u
             JOIN brand_ian_forecast f ON u.forecast_record_id = f.id
    WHERE ((gm.year = 2025 AND gm.month = 8) or (gm.year = 2025 AND gm.month = 9)) and u.created_at > '2024-10-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT u.*
    FROM brand_ian_update u
    JOIN brand_ian_forecast f ON u.forecast_record_id = f.id
    WHERE ((gm.year = 2025 AND gm.month = 8) or (gm.year = 2025 AND gm.month = 9)) and u.created_at > '2024-10-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT u.*
    FROM brand_ian_update u
    JOIN brand_ian_forecast f ON u.forecast_record_id = f.id
    WHERE ((f.year = 2025 AND f.month = 8) or (f.year = 2025 AND f.month = 9)) and u.created_at > '2024-10-01';
;-- -. . -..- - / . -. - .-. -.--
SELECT gross_margin_id FROM brand_ian_gross_margin_update
where gross_margin_id in (
    SELECT id from brand_ian_gross_margin
    WHERE
        ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    )
  and created_at > '2024-10-01'
order by brand_ian_gross_margin_update.created_at;
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM brand_ian_update
where forecast_record_id in (
    SELECT id from brand_ian_forecast
    WHERE
        ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    )
and created_at > '2024-10-01'
order by brand_ian_update.created_at;
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM brand_ian_pending_gross_margin p
where p.forecast_id in (
    SELECT id from brand_ian_forecast
    WHERE
        ((year = 2025 AND month = 8) OR (year = 2025 AND month = 9))
    )
  and created_at > '2024-10-01';
;-- -. . -..- - / . -. - .-. -.--
WITH latest_forecast_updates AS (
    SELECT
        u.forecast_record_id,
        u.current_quantity,
        ROW_NUMBER() OVER (
            PARTITION BY u.forecast_record_id
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_update u
    WHERE u.created_at >= '2024-10-01'
),
     forecast_data AS (
         SELECT
             f.article_code,
             f.branch_id,
             f.client_code,
             f.year,
             f.month,
             u.current_quantity AS quantity
         FROM latest_forecast_updates u
                  JOIN brand_ian_forecast f ON u.forecast_record_id = f.id
         WHERE u.rn = 1
     )
SELECT * FROM forecast_data;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             -- Include similar lines for all concepts
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             -- Include similar lines for all concepts
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM margin_data;
;-- -. . -..- - / . -. - .-. -.--
SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )

SELECT * FROM pivoted_updates;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             pu.atypical,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM margin_data;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM pivoted_updates;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM pivoted_updates where atypical is not null;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM margin_data;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM latest_margin_updates;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM filtered_updates;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM filtered_updates where concept <> 'INVENTORY_COST_ADJUSTMENT';
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM filtered_updates where concept <> 'INVENTORY_COST_ADJUSTMENT' OR concept <> 'AUX_INVENTORY_ADJUSTMENTS';
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM filtered_updates where concept <> 'INVENTORY_COST_ADJUSTMENT' AND concept <> 'AUX_INVENTORY_ADJUSTMENTS';
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM filtered_updates where concept <> 'INVENTORY_COST_ADJUSTMENT' AND concept <> 'AUX_INVENTORY_ADJUSTMENTS' AND concept <> 'SELL_PRICE';
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
            pu.inventory_cost_adjustment,
            pu.aux_inventory_adjustments,
            pu.sell_price,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM margin_data;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value,
             MAX(CASE WHEN lu.concept = 'atypical' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'rappels' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'sell_commissions' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'returns' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'insurance_premium' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'various' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'sell_price' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'direct_cost' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'transport' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'distribution_commissions' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'green_point' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'transfers' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'other_sales_transport_expenses' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'aiem_cost' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'inventory_cost_adjustment' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'aux_inventory_adjustments' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'warehouse_labor' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id, lu.concept, lu.current_concept_value
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
            pu.inventory_cost_adjustment,
            pu.aux_inventory_adjustments,
            pu.sell_price,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM pivoted_updates;
;-- -. . -..- - / . -. - .-. -.--
SELECT distinct concept FROM brand_ian_gross_margin_update;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'ATYPICAL' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'RAPPELS' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'SELL_COMMISSIONS' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'RETURNS' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'INSURANCE_PREMIUMS' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'VARIOUS' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'SELL_PRICE' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'DIRECT_COST' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'TRANSPORT' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'DISTRIBUTION_COMMISSIONS' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'GREEN_POINT' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'TRANSFERS' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'OTHER_SALES_TRANSPORT_EXPENSES' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'AIEM_COST' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'INVENTORY_COST_ADJUSTMENT' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'AUX_INVENTORY_ADJUSTMENTS' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'WAREHOUSE_LABOR' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
            pu.inventory_cost_adjustment,
            pu.aux_inventory_adjustments,
            pu.sell_price,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM pivoted_updates;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'ATYPICAL' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'RAPPELS' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'SELL_COMMISSIONS' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'RETURNS' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'INSURANCE_PREMIUMS' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'VARIOUS' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'SELL_PRICE' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'DIRECT_COST' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'TRANSPORT' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'DISTRIBUTION_COMMISSIONS' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'GREEN_POINT' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'TRANSFERS' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'OTHER_SALES_TRANSPORT_EXPENSES' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'AIEM_COST' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'INVENTORY_COST_ADJUSTMENT' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'AUX_INVENTORY_ADJUSTMENTS' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'WAREHOUSE_LABOR' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
            pu.inventory_cost_adjustment,
            pu.aux_inventory_adjustments,
            pu.sell_price,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM margin_data;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'ATYPICAL' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'RAPPELS' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'SELL_COMMISSIONS' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'RETURNS' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'INSURANCE_PREMIUMS' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'VARIOUS' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'SELL_PRICE' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'DIRECT_COST' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'TRANSPORT' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'DISTRIBUTION_COMMISSIONS' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'GREEN_POINT' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'TRANSFERS' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'OTHER_SALES_TRANSPORT_EXPENSES' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'AIEM_COST' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'INVENTORY_COST_ADJUSTMENT' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'AUX_INVENTORY_ADJUSTMENTS' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'WAREHOUSE_LABOR' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
            pu.inventory_cost_adjustment,
            pu.aux_inventory_adjustments,
            pu.sell_price,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM filtered_updates fu where concept <> 'SELL_PRICE' AND concept <> 'AUX_INVENTORY_ADJUSTMENTS' AND concept <> 'INVENTORY_COST_ADJUSTMENT';
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'ATYPICAL' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'RAPPELS' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'SELL_COMMISSIONS' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'RETURNS' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'INSURANCE_PREMIUMS' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'VARIOUS' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'SELL_PRICE' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'DIRECT_COST' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'TRANSPORT' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'DISTRIBUTION_COMMISSIONS' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'GREEN_POINT' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'TRANSFERS' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'OTHER_SALES_TRANSPORT_EXPENSES' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'AIEM_COST' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'INVENTORY_COST_ADJUSTMENT' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'AUX_INVENTORY_ADJUSTMENTS' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'WAREHOUSE_LABOR' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
            pu.inventory_cost_adjustment,
            pu.aux_inventory_adjustments,
            pu.sell_price,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
SELECT * FROM filtered_updates fu where  concept <> 'AUX_INVENTORY_ADJUSTMENTS' AND concept <> 'INVENTORY_COST_ADJUSTMENT';
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'ATYPICAL' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'RAPPELS' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'SELL_COMMISSIONS' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'RETURNS' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'INSURANCE_PREMIUMS' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'VARIOUS' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'SELL_PRICE' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'DIRECT_COST' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'TRANSPORT' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'DISTRIBUTION_COMMISSIONS' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'GREEN_POINT' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'TRANSFERS' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'OTHER_SALES_TRANSPORT_EXPENSES' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'AIEM_COST' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'INVENTORY_COST_ADJUSTMENT' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'AUX_INVENTORY_ADJUSTMENTS' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'WAREHOUSE_LABOR' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
            pu.inventory_cost_adjustment,
            pu.aux_inventory_adjustments,
            pu.sell_price,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
-- SELECT * FROM filtered_updates fu where concept <> 'SELL_PRICE' AND concept <> 'AUX_INVENTORY_ADJUSTMENTS' AND concept <> 'INVENTORY_COST_ADJUSTMENT';
SELECT * FROM pivoted_updates;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'ATYPICAL' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'RAPPELS' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'SELL_COMMISSIONS' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'RETURNS' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'INSURANCE_PREMIUMS' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'VARIOUS' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'SELL_PRICE' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'DIRECT_COST' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'TRANSPORT' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'DISTRIBUTION_COMMISSIONS' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'GREEN_POINT' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'TRANSFERS' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'OTHER_SALES_TRANSPORT_EXPENSES' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'AIEM_COST' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'INVENTORY_COST_ADJUSTMENT' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'AUX_INVENTORY_ADJUSTMENTS' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'WAREHOUSE_LABOR' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
            pu.inventory_cost_adjustment,
            pu.aux_inventory_adjustments,
            pu.sell_price,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
-- SELECT * FROM filtered_updates fu where concept <> 'SELL_PRICE' AND concept <> 'AUX_INVENTORY_ADJUSTMENTS' AND concept <> 'INVENTORY_COST_ADJUSTMENT';
SELECT * FROM pivoted_updates where sell_price is not null;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'ATYPICAL' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'RAPPELS' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'SELL_COMMISSIONS' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'RETURNS' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'INSURANCE_PREMIUMS' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'VARIOUS' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'SELL_PRICE' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'DIRECT_COST' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'TRANSPORT' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'DISTRIBUTION_COMMISSIONS' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'GREEN_POINT' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'TRANSFERS' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'OTHER_SALES_TRANSPORT_EXPENSES' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'AIEM_COST' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'INVENTORY_COST_ADJUSTMENT' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'AUX_INVENTORY_ADJUSTMENTS' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'WAREHOUSE_LABOR' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
            pu.inventory_cost_adjustment,
            pu.aux_inventory_adjustments,
            pu.sell_price,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
-- SELECT * FROM filtered_updates fu where concept <> 'SELL_PRICE' AND concept <> 'AUX_INVENTORY_ADJUSTMENTS' AND concept <> 'INVENTORY_COST_ADJUSTMENT';
SELECT * FROM pivoted_updates where inventory_cost_adjustment is not null and inventory_cost_adjustment <> 0;
;-- -. . -..- - / . -. - .-. -.--
WITH latest_margin_updates AS (
    SELECT
        u.gross_margin_id,
        u.concept,
        u.current_concept_value,
        ROW_NUMBER() OVER (
            PARTITION BY u.gross_margin_id, u.concept
            ORDER BY u.created_at DESC
            ) AS rn
    FROM brand_ian_gross_margin_update u
    WHERE u.created_at >= '2024-10-01'
),
     filtered_updates AS (
         SELECT
             lu.gross_margin_id,
             lu.concept,
             lu.current_concept_value
         FROM latest_margin_updates lu
         WHERE lu.rn = 1
     ),
     pivoted_updates AS (
         SELECT
             lu.gross_margin_id,
             MAX(CASE WHEN lu.concept = 'ATYPICAL' THEN lu.current_concept_value END) AS atypical,
             MAX(CASE WHEN lu.concept = 'RAPPELS' THEN lu.current_concept_value END) AS rappels,
             MAX(CASE WHEN lu.concept = 'SELL_COMMISSIONS' THEN lu.current_concept_value END) AS sell_commissions,
             MAX(CASE WHEN lu.concept = 'RETURNS' THEN lu.current_concept_value END) AS returns,
             MAX(CASE WHEN lu.concept = 'INSURANCE_PREMIUMS' THEN lu.current_concept_value END) AS insurance_premium,
             MAX(CASE WHEN lu.concept = 'VARIOUS' THEN lu.current_concept_value END) AS various,
             MAX(CASE WHEN lu.concept = 'SELL_PRICE' THEN lu.current_concept_value END) AS sell_price,
             MAX(CASE WHEN lu.concept = 'DIRECT_COST' THEN lu.current_concept_value END) AS direct_cost,
             MAX(CASE WHEN lu.concept = 'TRANSPORT' THEN lu.current_concept_value END) AS transport,
             MAX(CASE WHEN lu.concept = 'DISTRIBUTION_COMMISSIONS' THEN lu.current_concept_value END) AS distribution_commissions,
             MAX(CASE WHEN lu.concept = 'GREEN_POINT' THEN lu.current_concept_value END) AS green_point,
             MAX(CASE WHEN lu.concept = 'TRANSFERS' THEN lu.current_concept_value END) AS transfers,
             MAX(CASE WHEN lu.concept = 'OTHER_SALES_TRANSPORT_EXPENSES' THEN lu.current_concept_value END) AS other_sales_transport_expenses,
             MAX(CASE WHEN lu.concept = 'AIEM_COST' THEN lu.current_concept_value END) AS aiem_cost,
             MAX(CASE WHEN lu.concept = 'INVENTORY_COST_ADJUSTMENT' THEN lu.current_concept_value END) AS inventory_cost_adjustment,
             MAX(CASE WHEN lu.concept = 'AUX_INVENTORY_ADJUSTMENTS' THEN lu.current_concept_value END) AS aux_inventory_adjustments,
             MAX(CASE WHEN lu.concept = 'WAREHOUSE_LABOR' THEN lu.current_concept_value END) AS warehouse_labor
         FROM filtered_updates lu
         GROUP BY lu.gross_margin_id
     ),
     margin_data AS (
         SELECT
             gm.article_code,
             gm.branch_id,
             gm.client_code,
             gm.year,
             gm.month,
            pu.inventory_cost_adjustment,
            pu.aux_inventory_adjustments,
            pu.sell_price,
             COALESCE(pu.atypical, gm.atypical) AS atypical,
             COALESCE(pu.rappels, gm.rappels) AS rappels,
             COALESCE(pu.sell_commissions, gm.sell_commissions) AS sell_commissions,
            COALESCE(pu.returns, gm.returns) AS returns,
            COALESCE(pu.insurance_premium, gm.insurance_premium) AS insurance_premium,
            COALESCE(pu.various, gm.various) AS various,
            COALESCE(pu.sell_price, gm.sell_price) AS sell_price,
            COALESCE(pu.direct_cost, gm.direct_cost) AS direct_cost,
            COALESCE(pu.transport, gm.transport) AS transport,
            COALESCE(pu.distribution_commissions, gm.distribution_commissions) AS distribution_commissions,
            COALESCE(pu.green_point, gm.green_point) AS green_point,
            COALESCE(pu.transfers, gm.transfers) AS transfers,
            COALESCE(pu.other_sales_transport_expenses, gm.other_sales_transport_expenses) AS other_sales_transport_expenses,
            COALESCE(pu.aiem_cost, gm.aiem_cost) AS aiem_cost,
            COALESCE(pu.inventory_cost_adjustment, gm.inventory_cost_adjustment) AS inventory_cost_adjustment,
            COALESCE(pu.aux_inventory_adjustments, gm.aux_inventory_adjustments) AS aux_inventory_adjustments,
             COALESCE(pu.warehouse_labor, gm.warehouse_labor) AS warehouse_labor
         FROM pivoted_updates pu
                  JOIN brand_ian_gross_margin gm ON pu.gross_margin_id = gm.id
     )
-- SELECT * FROM filtered_updates fu where concept <> 'SELL_PRICE' AND concept <> 'AUX_INVENTORY_ADJUSTMENTS' AND concept <> 'INVENTORY_COST_ADJUSTMENT';
SELECT * FROM pivoted_updates where inventory_cost_adjustment is not null and aux_inventory_adjustments <> 0;
;-- -. . -..- - / . -. - .-. -.--
SELECT
            u.forecast_record_id,
            u.current_quantity,
            ROW_NUMBER() OVER (
                PARTITION BY u.forecast_record_id
                ORDER BY u.created_at DESC
            ) AS rn
        FROM brand_ian_update u
        WHERE u.created_at >= '2024-10-01';
;-- -. . -..- - / . -. - .-. -.--
select * from brand_ian_update
where created_at >= '2024-10-01';
;-- -. . -..- - / . -. - .-. -.--
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
DELETE FROM brand_ian_forecast
WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9);
;-- -. . -..- - / . -. - .-. -.--
DO $$
    DECLARE
        v_deleted_count INT;
    BEGIN
        LOOP
            DELETE FROM brand_ian_forecast
            WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9)
                LIMIT 1000;  -- Elimina en lotes de 1000 registros

            GET DIAGNOSTICS v_deleted_count = ROW_COUNT; -- Guarda cuántos registros se eliminaron

            RAISE NOTICE 'Eliminados % registros en brand_ian_forecast', v_deleted_count; -- Imprime el número de registros eliminados

            IF v_deleted_count = 0 THEN
                EXIT;  -- Salir del loop si no quedan más registros
            END IF;
        END LOOP;
END $$;
;-- -. . -..- - / . -. - .-. -.--
DO $$
    DECLARE
        v_deleted_count INT;
    BEGIN
        LOOP
            WITH deleted_rows AS (
                DELETE FROM brand_ian_forecast
                    WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9)
                    RETURNING *
            )
            SELECT COUNT(*) INTO v_deleted_count FROM deleted_rows;

            RAISE NOTICE 'Eliminados % registros en brand_ian_forecast', v_deleted_count;

            IF v_deleted_count = 0 THEN
                EXIT;  -- Salir del loop si no quedan más registros
            END IF;
        END LOOP;
    END $$;
;-- -. . -..- - / . -. - .-. -.--
DELETE FROM brand_ian_forecast
WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9)
LIMIT 100;
;-- -. . -..- - / . -. - .-. -.--
SELECT COUNT(*)
FROM brand_ian_forecast
WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9);
;-- -. . -..- - / . -. - .-. -.--
WITH rows_to_delete AS (
    SELECT id
    FROM brand_ian_forecast
    WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9)
    LIMIT 100  -- Elimina en lotes de 100 registros
)
DELETE FROM brand_ian_forecast
WHERE id IN (SELECT id FROM rows_to_delete);
;-- -. . -..- - / . -. - .-. -.--
WITH rows_to_delete AS (
    SELECT id
    FROM brand_ian_forecast
    WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9)
    LIMIT 1000
)
DELETE FROM brand_ian_forecast
WHERE id IN (SELECT id FROM rows_to_delete);
;-- -. . -..- - / . -. - .-. -.--
DO $$
    DECLARE
        v_deleted_count INT;
    BEGIN
        LOOP
            WITH rows_to_delete AS (
                SELECT id
                FROM brand_ian_forecast
                WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9)
                LIMIT 100  -- Elimina en lotes de 100 registros
            )
            DELETE FROM brand_ian_forecast
            WHERE id IN (SELECT id FROM rows_to_delete)
            RETURNING id;  -- Devuelve los IDs eliminados

            GET DIAGNOSTICS v_deleted_count = ROW_COUNT;  -- Captura el número de registros eliminados en este lote

            RAISE NOTICE 'Eliminados % registros en brand_ian_forecast', v_deleted_count;

            IF v_deleted_count = 0 THEN
                EXIT;  -- Salir del loop si no quedan más registros por eliminar
            END IF;
        END LOOP;
    END $$;
;-- -. . -..- - / . -. - .-. -.--
DO $$
    DECLARE
        v_deleted_count INT;
    BEGIN
        LOOP
            WITH rows_to_delete AS (
                SELECT id
                FROM brand_ian_forecast
                WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9)
                LIMIT 100  -- Elimina en lotes de 100 registros
            )
            DELETE FROM brand_ian_forecast
            WHERE id IN (SELECT id FROM rows_to_delete)
            RETURNING id;  -- Devuelve los IDs eliminados

            GET DIAGNOSTICS v_deleted_count = ROW_COUNT;  -- Captura el número de registros eliminados en este lote

--             RAISE NOTICE 'Eliminados % registros en brand_ian_forecast', v_deleted_count;

            IF v_deleted_count = 0 THEN
                EXIT;  -- Salir del loop si no quedan más registros por eliminar
            END IF;
        END LOOP;
    END $$;
;-- -. . -..- - / . -. - .-. -.--
DO $$
    DECLARE
        v_deleted_count INT;
    BEGIN
        LOOP
            WITH rows_to_delete AS (
                SELECT id
                FROM brand_ian_forecast
                WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9)
                LIMIT 100  -- Elimina en lotes de 100 registros
            )
            DELETE FROM brand_ian_forecast
            WHERE id IN (SELECT id FROM rows_to_delete);

            GET DIAGNOSTICS v_deleted_count = ROW_COUNT;  -- Captura el número de registros eliminados en este lote

            RAISE NOTICE 'Eliminados % registros en brand_ian_forecast', v_deleted_count;

            IF v_deleted_count = 0 THEN
                EXIT;  -- Salir del loop si no quedan más registros por eliminar
            END IF;
        END LOOP;
    END $$;
;-- -. . -..- - / . -. - .-. -.--
DO $$
    DECLARE
        v_deleted_count INT;
    BEGIN
        LOOP
            WITH rows_to_delete AS (
                SELECT id
                FROM brand_ian_gross_margin
                WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9)
                LIMIT 500  -- Elimina en lotes de 100 registros
            )
            DELETE FROM brand_ian_gross_margin
            WHERE id IN (SELECT id FROM rows_to_delete);

            GET DIAGNOSTICS v_deleted_count = ROW_COUNT;  -- Captura el número de registros eliminados en este lote

            RAISE NOTICE 'Eliminados % registros en brand_ian_gross_margin', v_deleted_count;

            IF v_deleted_count = 0 THEN
                EXIT;  -- Salir del loop si no quedan más registros por eliminar
            END IF;
        END LOOP;
    END $$;
;-- -. . -..- - / . -. - .-. -.--
update brand_ian_gross_margin
set forecast_id = f.id from brand_ian_forecast f
where brand_ian_gross_margin.article_code = f.article_code
  and brand_ian_gross_margin.branch_id = f.branch_id
  and brand_ian_gross_margin.client_code = f.client_code
  and brand_ian_gross_margin.year = f.year
  and brand_ian_gross_margin.month = f.month;