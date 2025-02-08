-- limpieza producción
DELETE FROM brand_ian_gross_margin_update
    USING brand_ian_gross_margin
WHERE brand_ian_gross_margin_update.gross_margin_id = brand_ian_gross_margin.id
  AND ((brand_ian_gross_margin.year = 2025 AND brand_ian_gross_margin.month = 8) OR (brand_ian_gross_margin.year = 2025 AND brand_ian_gross_margin.month = 9));

DELETE FROM brand_ian_update
    USING brand_ian_forecast
WHERE brand_ian_update.forecast_record_id = brand_ian_forecast.id
  AND ((brand_ian_forecast.year = 2025 AND brand_ian_forecast.month = 8) OR (brand_ian_forecast.year = 2025 AND brand_ian_forecast.month = 9));


DELETE FROM brand_ian_gross_margin
WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9);

DELETE FROM brand_ian_forecast
WHERE (year = 2025 AND month = 8) OR (year = 2025 AND month = 9);

-- importar datos de backup

\COPY brand_ian_forecast (id, year, month, article_code, client_code, branch, quantity, budget, sale, checked, created_at, updated_at, branch_id, inter_company)
FROM '/home/samuelg/forecast_august_and_september_2025.csv' WITH (FORMAT CSV, HEADER);

\COPY brand_ian_gross_margin (id, year, month, branch_id, article_code, client_code, atypical, rappels, sell_commissions, returns, insurance_premium, various, sell_price, direct_cost, transport, distribution_commissions, green_point, generated, from_hana, checked, margin, created_at, updated_at, updated_concept_at, transfers, other_sales_transport_expenses, aiem_cost, inventory_cost_adjustment, aux_inventory_adjustments, forecast_id, warehouse_labor)
FROM '/home/samuelg/gross_margin_august_and_september_2025.csv' WITH (FORMAT CSV, HEADER);

\COPY brand_ian_update (id, forecast_record_id, past_quantity, current_quantity, created_at, created_by_user_id)
FROM '/home/samuelg/forecast_backup_update_august_and_september_2025.csv' WITH (FORMAT CSV, HEADER);

\COPY brand_ian_gross_margin_update (id, gross_margin_id, concept, past_concept_value, current_concept_value, created_at, created_by_user_id)
FROM '/home/samuelg/gross_margin_aux_backup_update_august_and_september_2025.csv' WITH (FORMAT CSV, HEADER);

--- crear tabla temporal
BEGIN;

CREATE TEMP TABLE temp_forecast_data (
                                         article_code TEXT,
                                         branch_id BIGINT,
                                         branch TEXT,
                                         client_code TEXT,
                                         year INTEGER,
                                         month INTEGER,
                                         quantity NUMERIC
);

\COPY temp_forecast_data FROM '/home/samuelg/forecastss_update_for_insert_latests_update_august_and_september_2025.csv' WITH (FORMAT CSV, HEADER);


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

\COPY temp_margin_data FROM '/home/samuelg/gm_update_for_insert_latests_update_august_and_september_2025.csv' WITH (FORMAT CSV, HEADER);

-- Inserción de datos
INSERT INTO brand_ian_forecast (
    article_code,
    branch_id,
    branch,
    client_code,
    year,
    month,
    quantity,
    inter_company
)
SELECT
    tf.article_code,
    tf.branch_id,
    tf.branch,
    tf.client_code,
    tf.year,
    tf.month,
    tf.quantity,
    FALSE
FROM temp_forecast_data tf
ON CONFLICT (year, month, article_code, branch, client_code) DO UPDATE
    SET
        quantity = EXCLUDED.quantity,
        updated_at = CURRENT_TIMESTAMP,
        checked = FALSE;


INSERT INTO brand_ian_gross_margin (
    article_code,
    branch_id,
    client_code,
    year,
    month,
    atypical,
    rappels,
    sell_commissions,
    returns,
    insurance_premium,
    various,
    sell_price,
    direct_cost,
    transport,
    distribution_commissions,
    green_point,
    transfers,
    other_sales_transport_expenses,
    aiem_cost,
    inventory_cost_adjustment,
    aux_inventory_adjustments,
    warehouse_labor
)
SELECT
    tm.article_code,
    tm.branch_id,
    tm.client_code,
    tm.year,
    tm.month,
    tm.atypical,
    tm.rappels,
    tm.sell_commissions,
    tm.returns,
    tm.insurance_premium,
    tm.various,
    tm.sell_price,
    tm.direct_cost,
    tm.transport,
    tm.distribution_commissions,
    tm.green_point,
    tm.transfers,
    tm.other_sales_transport_expenses,
    tm.aiem_cost,
    tm.inventory_cost_adjustment,
    tm.aux_inventory_adjustments,
    tm.warehouse_labor
FROM temp_margin_data tm
ON CONFLICT (year, month, article_code, branch_id, client_code) DO UPDATE
    SET
        atypical = EXCLUDED.atypical,
        rappels = EXCLUDED.rappels,
        sell_commissions = EXCLUDED.sell_commissions,
        returns = EXCLUDED.returns,
        insurance_premium = EXCLUDED.insurance_premium,
        various = EXCLUDED.various,
        sell_price = EXCLUDED.sell_price,
        direct_cost = EXCLUDED.direct_cost,
        transport = EXCLUDED.transport,
        distribution_commissions = EXCLUDED.distribution_commissions,
        green_point = EXCLUDED.green_point,
        transfers = EXCLUDED.transfers,
        other_sales_transport_expenses = EXCLUDED.other_sales_transport_expenses,
        aiem_cost = EXCLUDED.aiem_cost,
        inventory_cost_adjustment = EXCLUDED.inventory_cost_adjustment,
        aux_inventory_adjustments = EXCLUDED.aux_inventory_adjustments,
        warehouse_labor = EXCLUDED.warehouse_labor,
        updated_at = CURRENT_TIMESTAMP;

-- tabla temporal de actualizaciones

-- Paso 2: Crear tablas temporales
CREATE TEMP TABLE temp_forecast_updates (
                                            article_code TEXT,
                                            branch_id BIGINT,
                                            branch TEXT,
                                            client_code TEXT,
                                            year INTEGER,
                                            month INTEGER,
                                            past_quantity NUMERIC,
                                            current_quantity NUMERIC,
                                            created_at TIMESTAMPTZ,
                                            created_by_user_id BIGINT
);


CREATE TEMP TABLE temp_gross_margin_updates (
                                                article_code TEXT,
                                                branch_id BIGINT,
                                                client_code TEXT,
                                                year INTEGER,
                                                month INTEGER,
                                                concept VARCHAR,
                                                past_concept_value NUMERIC,
                                                current_concept_value NUMERIC,
                                                created_at TIMESTAMPTZ,
                                                created_by_user_id BIGINT
);

-- Paso 2.2: Importar datos desde CSV
\COPY temp_forecast_updates FROM '/home/samuelg/forecast_updates_2024_10_01.csv' WITH (FORMAT CSV, HEADER);
\COPY temp_gross_margin_updates FROM '/home/samuelg/gross_margin_updates_2024_10_01.csv' WITH (FORMAT CSV, HEADER);

-- Paso 2.3: Crear tablas de mapeo
CREATE TEMP TABLE temp_forecast_map AS
SELECT
    tfu.article_code,
    tfu.branch_id,
    tfu.client_code,
    tfu.year,
    tfu.month,
    f.id AS new_forecast_id
FROM temp_forecast_updates tfu
         JOIN brand_ian_forecast f
              ON f.article_code = tfu.article_code
                  AND f.branch_id = tfu.branch_id
                  AND f.client_code = tfu.client_code
                  AND f.year = tfu.year
                  AND f.month = tfu.month;

CREATE TEMP TABLE temp_gross_margin_map AS
SELECT
    tmu.article_code,
    tmu.branch_id,
    tmu.client_code,
    tmu.year,
    tmu.month,
    gm.id AS new_gross_margin_id
FROM temp_gross_margin_updates tmu
         JOIN brand_ian_gross_margin gm
              ON gm.article_code = tmu.article_code
                  AND gm.branch_id = tmu.branch_id
                  AND gm.client_code = tmu.client_code
                  AND gm.year = tmu.year
                  AND gm.month = tmu.month;

-- Paso 2.4: Insertar en tablas de actualización
-- Insertar en brand_ian_update
INSERT INTO brand_ian_update (
    forecast_record_id,
    past_quantity,
    current_quantity,
    created_at,
    created_by_user_id
)
SELECT
    tfm.new_forecast_id,
    tfu.past_quantity,
    tfu.current_quantity,
    tfu.created_at,
    tfu.created_by_user_id
FROM temp_forecast_updates tfu
         JOIN temp_forecast_map tfm
              ON tfu.article_code = tfm.article_code
                  AND tfu.branch_id = tfm.branch_id
                  AND tfu.client_code = tfm.client_code
                  AND tfu.year = tfm.year
                  AND tfu.month = tfm.month;

-- Insertar en brand_ian_gross_margin_update
INSERT INTO brand_ian_gross_margin_update (
    gross_margin_id,
    concept,
    past_concept_value,
    current_concept_value,
    created_at,
    created_by_user_id
)
SELECT
    tmm.new_gross_margin_id,
    tmu.concept,
    tmu.past_concept_value,
    tmu.current_concept_value,
    tmu.created_at,
    tmu.created_by_user_id
FROM temp_gross_margin_updates tmu
         JOIN temp_gross_margin_map tmm
              ON tmu.article_code = tmm.article_code
                  AND tmu.branch_id = tmm.branch_id
                  AND tmu.client_code = tmm.client_code
                  AND tmu.year = tmm.year
                  AND tmu.month = tmm.month;

-- Paso 2.5: Ajustar secuencias
SELECT setval('brand_ian_forecast_id_seq', (SELECT MAX(id) FROM brand_ian_forecast));
SELECT setval('brand_ian_costs_id_seq', (SELECT MAX(id) FROM brand_ian_gross_margin));

COMMIT;
