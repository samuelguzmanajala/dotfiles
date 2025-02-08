COPY (
    SELECT *
    FROM brand_ian_forecast
    WHERE year = 2025 AND month = 9
    ) TO '/path/to/forecast_september_2025.csv' WITH (FORMAT CSV, HEADER);
;-- -. . -..- - / . -. - .-. -.--
COPY (
    SELECT *
    FROM brand_ian_forecast
    WHERE year = 2025 AND month = 9
    ) TO '~/home/forecast_september_2025.csv' WITH (FORMAT CSV, HEADER);
;-- -. . -..- - / . -. - .-. -.--
COPY (
    SELECT *
    FROM brand_ian_forecast
    WHERE year = 2025 AND month = 9
    ) TO '/home/samuelg/forecast_september_2025.csv' WITH (FORMAT CSV, HEADER);
;-- -. . -..- - / . -. - .-. -.--
select * from brand_ian_gross_margin gm
where article_code = 'article_code' and to_date(gm.year || '-' || gm.month, 'YYYY-MM') > to_date('2024-12' ,'YYYY-MM');
;-- -. . -..- - / . -. - .-. -.--
select * from brand_ian_gross_margin gm
where to_date(gm.year || '-' || gm.month, 'YYYY-MM') > to_date('2024-12' ,'YYYY-MM');
;-- -. . -..- - / . -. - .-. -.--
select * from brand_ian_gross_margin gm
where to_date(gm.year || '-' || gm.month, 'YYYY-MM') > to_date('2024-12' ,'YYYY-MM')
order by gm.year, gm.month;
;-- -. . -..- - / . -. - .-. -.--
refresh materialized view daily_mean_forecast;
;-- -. . -..- - / . -. - .-. -.--
WITH
    date_range AS (
        SELECT generate_series(
                       CAST('2025-01-14' AS date),
                       CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day' - interval '1 day',
                       '1 day'
               ) AS target_date
    ),

    days_per_month AS (
        SELECT
            date_trunc('month', target_date)            AS month_start,
            CAST(COUNT(*) AS integer)                   AS days_in_range
        FROM date_range
        GROUP BY date_trunc('month', target_date)
    ),

    forecasts AS (
        SELECT
            branch_id,
            article_code,
            date_trunc('month', forecast_date) AS month_start,
            daily_forecast
        FROM public.daily_mean_forecast
        WHERE forecast_date >= CAST('2025-01-14' AS date)
          AND forecast_date <  CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day'
    ),

    monthly_forecast AS (
        SELECT
            dpm.month_start,
            f.branch_id,
            f.article_code,
            dpm.days_in_range,
            COALESCE(f.daily_forecast, 0) AS daily_forecast,
            COALESCE(dpm.days_in_range * f.daily_forecast, 0) AS monthly_forecast
        FROM days_per_month dpm
                 LEFT JOIN forecasts f
                           ON dpm.month_start = f.month_start
    ),

    final_sums AS (
        SELECT
            mf.branch_id,
            mf.article_code,
            SUM(mf.days_in_range)    AS total_days,
            SUM(mf.monthly_forecast) AS total_monthly_forecast
        FROM monthly_forecast mf
        GROUP BY mf.branch_id, mf.article_code
    ),

    final_intermediate AS (
        SELECT
            fs.branch_id,
            bm.article_code,
            fs.total_days,
            fs.total_monthly_forecast,
            bm.available_stock,
            CASE
                WHEN fs.total_days = 0 THEN 0
                ELSE fs.total_monthly_forecast / fs.total_days
                END AS daily_consumption
        FROM final_sums fs
                 LEFT JOIN brand_ian_master_stock bm
                           ON fs.article_code = bm.article_code
    ),

    weeks AS (
        SELECT
            generate_series(0, 7)                                                    AS week_offset,
            date_trunc('week', current_date) + (generate_series(0, 7) * interval '1 week') AS start_of_week,
            date_trunc('week', current_date) + ((generate_series(0, 7) + 1) * interval '1 week') - interval '1 second' AS end_of_week
    ),

    assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            SUM(b.manufacturing) AS total_manufacturing
        FROM brand_ian_po_po_week_detail_assigned b
                 JOIN weeks w
                      ON b.date >= w.start_of_week AND b.date < w.end_of_week
        GROUP BY w.week_offset, b.article_code
    ),

    not_assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            b.manufacturing AS manufacturing
        FROM brand_ian_po_po_week_detail_not_assigned b
                 JOIN weeks w
                      ON b.week_start_date = w.start_of_week
    ),

    combined AS (
        SELECT
            COALESCE(a.week, na.week)                 AS week,
            COALESCE(a.article_code, na.article_code) AS article_code,
            COALESCE(a.total_manufacturing, 0)
                + COALESCE(na.manufacturing, 0)       AS manufacturing
        FROM assigned a
                 FULL OUTER JOIN not_assigned na
                                 ON a.week = na.week
                                     AND a.article_code = na.article_code
    ),

    weeks_general_programming AS (
        SELECT
            article_code,
            MAX(CASE WHEN week = 0 THEN manufacturing END) AS week_0_programming,
            MAX(CASE WHEN week = 1 THEN manufacturing END) AS week_1_programming,
            MAX(CASE WHEN week = 2 THEN manufacturing END) AS week_2_programming,
            MAX(CASE WHEN week = 3 THEN manufacturing END) AS week_3_programming,
            MAX(CASE WHEN week = 4 THEN manufacturing END) AS week_4_programming,
            MAX(CASE WHEN week = 5 THEN manufacturing END) AS week_5_programming,
            MAX(CASE WHEN week = 6 THEN manufacturing END) AS week_6_programming,
            MAX(CASE WHEN week = 7 THEN manufacturing END) AS week_7_programming
        FROM combined
        GROUP BY article_code
    ),

    weeks_general_coverage AS (
        SELECT
            combined.article_code,
            final_intermediate.daily_consumption,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                ) / daily_consumption - 7                                    AS week_0_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                ) / daily_consumption - 14                                   AS week_1_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                ) / daily_consumption - 21                                   AS week_2_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                ) / daily_consumption - 28                                   AS week_3_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                ) / daily_consumption - 35                                   AS week_4_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                ) / daily_consumption - 42                                   AS week_5_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                ) / daily_consumption - 49                                   AS week_6_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                + COALESCE(week_7_programming, 0)
                ) / daily_consumption - 56                                   AS week_7_coverage
        FROM combined
                 JOIN final_intermediate
                      ON combined.article_code = final_intermediate.article_code
                 JOIN weeks_general_programming
                      ON combined.article_code = weeks_general_programming.article_code
        GROUP BY
            combined.article_code,
            final_intermediate.daily_consumption,
            available_stock,
            week_0_programming,
            week_1_programming,
            week_2_programming,
            week_3_programming,
            week_4_programming,
            week_5_programming,
            week_6_programming,
            week_7_programming
    ),

    weeks_general AS (
        SELECT
            wgc.article_code,
            wgp.week_0_programming
                + wgp.week_1_programming
                + wgp.week_2_programming
                + wgp.week_3_programming
                + wgp.week_4_programming
                + wgp.week_5_programming
                + wgp.week_6_programming
                + wgp.week_7_programming
                AS total_programming,

            wgc.week_0_coverage,
            wgp.week_0_programming,

            wgc.week_1_coverage,
            wgp.week_1_programming,

            wgc.week_2_coverage,
            wgp.week_2_programming,

            wgc.week_3_coverage,
            wgp.week_3_programming,

            wgc.week_4_coverage,
            wgp.week_4_programming,

            wgc.week_5_coverage,
            wgp.week_5_programming,

            wgc.week_6_coverage,
            wgp.week_6_programming,

            wgc.week_7_coverage,
            wgp.week_7_programming
        FROM weeks_general_coverage wgc
                 JOIN weeks_general_programming wgp
                      ON wgc.article_code = wgp.article_code
    ),

    final_calculations AS (
        SELECT
            branch_id,
            final_intermediate.article_code,
            total_monthly_forecast  AS mean_forecast,
            available_stock,
            daily_consumption,
            CASE
                WHEN daily_consumption = 0 THEN 0
                ELSE available_stock / daily_consumption
                END AS coverage_without_production,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) < 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_positive,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) > 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_negative,
            COALESCE(wg.total_programming, 0)             AS total_programming,

            COALESCE(wg.week_0_programming, 0)            AS week_0_programming,
            COALESCE(wg.week_0_coverage, 0)               AS week_0_coverage,

            COALESCE(wg.week_1_programming, 0)            AS week_1_programming,
            COALESCE(wg.week_1_coverage, 0)               AS week_1_coverage,

            COALESCE(wg.week_2_programming, 0)            AS week_2_programming,
            COALESCE(wg.week_2_coverage, 0)               AS week_2_coverage,

            COALESCE(wg.week_3_programming, 0)            AS week_3_programming,
            COALESCE(wg.week_3_coverage, 0)               AS week_3_coverage,

            COALESCE(wg.week_4_programming, 0)            AS week_4_programming,
            COALESCE(wg.week_4_coverage, 0)               AS week_4_coverage,

            COALESCE(wg.week_5_programming, 0)            AS week_5_programming,
            COALESCE(wg.week_5_coverage, 0)               AS week_5_coverage,

            COALESCE(wg.week_6_programming, 0)            AS week_6_programming,
            COALESCE(wg.week_6_coverage, 0)               AS week_6_coverage,

            COALESCE(wg.week_7_programming, 0)            AS week_7_programming,
            COALESCE(wg.week_7_coverage, 0)               AS week_7_coverage,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) > 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_positive_with_production,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) < 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_negative_with_production
        FROM final_intermediate
                 LEFT JOIN weeks_general wg
                           ON final_intermediate.article_code = wg.article_code
    )
SELECT
    a.article_code,
    a.article_name,
    a.formula_name,
    a.format_name,
    fc.mean_forecast,
    fc.available_stock,
    fc.coverage_without_production,
    fc.need_positive,
    fc.need_negative,
    total_programming,
    week_0_programming,
    week_0_coverage,
    week_1_programming,
    week_1_coverage,
    week_2_programming,
    week_2_coverage,
    week_3_programming,
    week_3_coverage,
    week_4_programming,
    week_4_coverage,
    week_5_programming,
    week_5_coverage,
    week_6_programming,
    week_6_coverage,
    week_7_programming,
    week_7_coverage,
    need_positive_with_production,
    need_negative_with_production
FROM final_calculations fc
         JOIN brand_ian_master_article a
              ON a.article_code = fc.article_code
LIMIT 30
                OFFSET 0;
;-- -. . -..- - / . -. - .-. -.--
WITH
    date_range AS (
        SELECT generate_series(
                       CAST('2025-01-14' AS date),
                       CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day' - interval '1 day',
                       '1 day'
               ) AS target_date
    ),

    days_per_month AS (
        SELECT
            date_trunc('month', target_date)            AS month_start,
            CAST(COUNT(*) AS integer)                   AS days_in_range
        FROM date_range
        GROUP BY date_trunc('month', target_date)
    ),

    forecasts AS (
        SELECT
            branch_id,
            article_code,
            date_trunc('month', forecast_date) AS month_start,
            daily_forecast
        FROM public.daily_mean_forecast
        WHERE forecast_date >= CAST('2025-01-14' AS date)
          AND forecast_date <  CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day'
    ),

    monthly_forecast AS (
        SELECT
            dpm.month_start,
            f.branch_id,
            f.article_code,
            dpm.days_in_range,
            COALESCE(f.daily_forecast, 0) AS daily_forecast,
            COALESCE(dpm.days_in_range * f.daily_forecast, 0) AS monthly_forecast
        FROM days_per_month dpm
                 LEFT JOIN forecasts f
                           ON dpm.month_start = f.month_start
    ),

    final_sums AS (
        SELECT
            mf.branch_id,
            mf.article_code,
            SUM(mf.days_in_range)    AS total_days,
            SUM(mf.monthly_forecast) AS total_monthly_forecast
        FROM monthly_forecast mf
        GROUP BY mf.branch_id, mf.article_code
    ),

    final_intermediate AS (
        SELECT
            fs.branch_id,
            bm.article_code,
            fs.total_days,
            fs.total_monthly_forecast,
            bm.available_stock,
            CASE
                WHEN fs.total_days = 0 THEN 0
                ELSE fs.total_monthly_forecast / fs.total_days
                END AS daily_consumption
        FROM final_sums fs
                 LEFT JOIN brand_ian_master_stock bm
                           ON fs.article_code = bm.article_code
    ),

    weeks AS (
        SELECT
            generate_series(0, 7)                                                    AS week_offset,
            date_trunc('week', current_date) + (generate_series(0, 7) * interval '1 week') AS start_of_week,
            date_trunc('week', current_date) + ((generate_series(0, 7) + 1) * interval '1 week') - interval '1 second' AS end_of_week
    ),

    assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            SUM(b.manufacturing) AS total_manufacturing
        FROM brand_ian_po_po_week_detail_assigned b
                 JOIN weeks w
                      ON b.date >= w.start_of_week AND b.date < w.end_of_week
        GROUP BY w.week_offset, b.article_code
    ),

    not_assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            b.manufacturing AS manufacturing
        FROM brand_ian_po_po_week_detail_not_assigned b
                 JOIN weeks w
                      ON b.week_start_date = w.start_of_week
    ),

    combined AS (
        SELECT
            COALESCE(a.week, na.week)                 AS week,
            COALESCE(a.article_code, na.article_code) AS article_code,
            COALESCE(a.total_manufacturing, 0)
                + COALESCE(na.manufacturing, 0)       AS manufacturing
        FROM assigned a
                 FULL OUTER JOIN not_assigned na
                                 ON a.week = na.week
                                     AND a.article_code = na.article_code
    ),

    weeks_general_programming AS (
        SELECT
            article_code,
            MAX(CASE WHEN week = 0 THEN manufacturing END) AS week_0_programming,
            MAX(CASE WHEN week = 1 THEN manufacturing END) AS week_1_programming,
            MAX(CASE WHEN week = 2 THEN manufacturing END) AS week_2_programming,
            MAX(CASE WHEN week = 3 THEN manufacturing END) AS week_3_programming,
            MAX(CASE WHEN week = 4 THEN manufacturing END) AS week_4_programming,
            MAX(CASE WHEN week = 5 THEN manufacturing END) AS week_5_programming,
            MAX(CASE WHEN week = 6 THEN manufacturing END) AS week_6_programming,
            MAX(CASE WHEN week = 7 THEN manufacturing END) AS week_7_programming
        FROM combined
        GROUP BY article_code
    ),

    weeks_general_coverage AS (
        SELECT
            combined.article_code,
            final_intermediate.daily_consumption,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                , daily_consumption) - 7                                    AS week_0_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                ) / daily_consumption - 14                                   AS week_1_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                ) / daily_consumption - 21                                   AS week_2_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                ) / daily_consumption - 28                                   AS week_3_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                ) / daily_consumption - 35                                   AS week_4_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                ) / daily_consumption - 42                                   AS week_5_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                ) / daily_consumption - 49                                   AS week_6_coverage,
            (COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                + COALESCE(week_7_programming, 0)
                ) / daily_consumption - 56                                   AS week_7_coverage
        FROM combined
                 JOIN final_intermediate
                      ON combined.article_code = final_intermediate.article_code
                 JOIN weeks_general_programming
                      ON combined.article_code = weeks_general_programming.article_code
        GROUP BY
            combined.article_code,
            final_intermediate.daily_consumption,
            available_stock,
            week_0_programming,
            week_1_programming,
            week_2_programming,
            week_3_programming,
            week_4_programming,
            week_5_programming,
            week_6_programming,
            week_7_programming
    ),

    weeks_general AS (
        SELECT
            wgc.article_code,
            wgp.week_0_programming
                + wgp.week_1_programming
                + wgp.week_2_programming
                + wgp.week_3_programming
                + wgp.week_4_programming
                + wgp.week_5_programming
                + wgp.week_6_programming
                + wgp.week_7_programming
                AS total_programming,

            wgc.week_0_coverage,
            wgp.week_0_programming,

            wgc.week_1_coverage,
            wgp.week_1_programming,

            wgc.week_2_coverage,
            wgp.week_2_programming,

            wgc.week_3_coverage,
            wgp.week_3_programming,

            wgc.week_4_coverage,
            wgp.week_4_programming,

            wgc.week_5_coverage,
            wgp.week_5_programming,

            wgc.week_6_coverage,
            wgp.week_6_programming,

            wgc.week_7_coverage,
            wgp.week_7_programming
        FROM weeks_general_coverage wgc
                 JOIN weeks_general_programming wgp
                      ON wgc.article_code = wgp.article_code
    ),

    final_calculations AS (
        SELECT
            branch_id,
            final_intermediate.article_code,
            total_monthly_forecast  AS mean_forecast,
            available_stock,
            daily_consumption,
            CASE
                WHEN daily_consumption = 0 THEN 0
                ELSE available_stock / daily_consumption
                END AS coverage_without_production,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) < 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_positive,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) > 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_negative,
            COALESCE(wg.total_programming, 0)             AS total_programming,

            COALESCE(wg.week_0_programming, 0)            AS week_0_programming,
            COALESCE(wg.week_0_coverage, 0)               AS week_0_coverage,

            COALESCE(wg.week_1_programming, 0)            AS week_1_programming,
            COALESCE(wg.week_1_coverage, 0)               AS week_1_coverage,

            COALESCE(wg.week_2_programming, 0)            AS week_2_programming,
            COALESCE(wg.week_2_coverage, 0)               AS week_2_coverage,

            COALESCE(wg.week_3_programming, 0)            AS week_3_programming,
            COALESCE(wg.week_3_coverage, 0)               AS week_3_coverage,

            COALESCE(wg.week_4_programming, 0)            AS week_4_programming,
            COALESCE(wg.week_4_coverage, 0)               AS week_4_coverage,

            COALESCE(wg.week_5_programming, 0)            AS week_5_programming,
            COALESCE(wg.week_5_coverage, 0)               AS week_5_coverage,

            COALESCE(wg.week_6_programming, 0)            AS week_6_programming,
            COALESCE(wg.week_6_coverage, 0)               AS week_6_coverage,

            COALESCE(wg.week_7_programming, 0)            AS week_7_programming,
            COALESCE(wg.week_7_coverage, 0)               AS week_7_coverage,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) > 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_positive_with_production,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) < 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_negative_with_production
        FROM final_intermediate
                 LEFT JOIN weeks_general wg
                           ON final_intermediate.article_code = wg.article_code
    )
SELECT
    a.article_code,
    a.article_name,
    a.formula_name,
    a.format_name,
    fc.mean_forecast,
    fc.available_stock,
    fc.coverage_without_production,
    fc.need_positive,
    fc.need_negative,
    total_programming,
    week_0_programming,
    week_0_coverage,
    week_1_programming,
    week_1_coverage,
    week_2_programming,
    week_2_coverage,
    week_3_programming,
    week_3_coverage,
    week_4_programming,
    week_4_coverage,
    week_5_programming,
    week_5_coverage,
    week_6_programming,
    week_6_coverage,
    week_7_programming,
    week_7_coverage,
    need_positive_with_production,
    need_negative_with_production
FROM final_calculations fc
         JOIN brand_ian_master_article a
              ON a.article_code = fc.article_code
LIMIT 30
                OFFSET 0;
;-- -. . -..- - / . -. - .-. -.--
WITH
    date_range AS (
        SELECT generate_series(
                       CAST('2025-01-14' AS date),
                       CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day' - interval '1 day',
                       '1 day'
               ) AS target_date
    ),

    days_per_month AS (
        SELECT
            date_trunc('month', target_date)            AS month_start,
            CAST(COUNT(*) AS integer)                   AS days_in_range
        FROM date_range
        GROUP BY date_trunc('month', target_date)
    ),

    forecasts AS (
        SELECT
            branch_id,
            article_code,
            date_trunc('month', forecast_date) AS month_start,
            daily_forecast
        FROM public.daily_mean_forecast
        WHERE forecast_date >= CAST('2025-01-14' AS date)
          AND forecast_date <  CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day'
    ),

    monthly_forecast AS (
        SELECT
            dpm.month_start,
            f.branch_id,
            f.article_code,
            dpm.days_in_range,
            COALESCE(f.daily_forecast, 0) AS daily_forecast,
            COALESCE(dpm.days_in_range * f.daily_forecast, 0) AS monthly_forecast
        FROM days_per_month dpm
                 LEFT JOIN forecasts f
                           ON dpm.month_start = f.month_start
    ),

    final_sums AS (
        SELECT
            mf.branch_id,
            mf.article_code,
            SUM(mf.days_in_range)    AS total_days,
            SUM(mf.monthly_forecast) AS total_monthly_forecast
        FROM monthly_forecast mf
        GROUP BY mf.branch_id, mf.article_code
    ),

    final_intermediate AS (
        SELECT
            fs.branch_id,
            bm.article_code,
            fs.total_days,
            fs.total_monthly_forecast,
            bm.available_stock,
            CASE
                WHEN fs.total_days = 0 THEN 0
                ELSE fs.total_monthly_forecast / fs.total_days
                END AS daily_consumption
        FROM final_sums fs
                 LEFT JOIN brand_ian_master_stock bm
                           ON fs.article_code = bm.article_code
    ),

    weeks AS (
        SELECT
            generate_series(0, 7)                                                    AS week_offset,
            date_trunc('week', current_date) + (generate_series(0, 7) * interval '1 week') AS start_of_week,
            date_trunc('week', current_date) + ((generate_series(0, 7) + 1) * interval '1 week') - interval '1 second' AS end_of_week
    ),

    assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            SUM(b.manufacturing) AS total_manufacturing
        FROM brand_ian_po_po_week_detail_assigned b
                 JOIN weeks w
                      ON b.date >= w.start_of_week AND b.date < w.end_of_week
        GROUP BY w.week_offset, b.article_code
    ),

    not_assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            b.manufacturing AS manufacturing
        FROM brand_ian_po_po_week_detail_not_assigned b
                 JOIN weeks w
                      ON b.week_start_date = w.start_of_week
    ),

    combined AS (
        SELECT
            COALESCE(a.week, na.week)                 AS week,
            COALESCE(a.article_code, na.article_code) AS article_code,
            COALESCE(a.total_manufacturing, 0)
                + COALESCE(na.manufacturing, 0)       AS manufacturing
        FROM assigned a
                 FULL OUTER JOIN not_assigned na
                                 ON a.week = na.week
                                     AND a.article_code = na.article_code
    ),

    weeks_general_programming AS (
        SELECT
            article_code,
            MAX(CASE WHEN week = 0 THEN manufacturing END) AS week_0_programming,
            MAX(CASE WHEN week = 1 THEN manufacturing END) AS week_1_programming,
            MAX(CASE WHEN week = 2 THEN manufacturing END) AS week_2_programming,
            MAX(CASE WHEN week = 3 THEN manufacturing END) AS week_3_programming,
            MAX(CASE WHEN week = 4 THEN manufacturing END) AS week_4_programming,
            MAX(CASE WHEN week = 5 THEN manufacturing END) AS week_5_programming,
            MAX(CASE WHEN week = 6 THEN manufacturing END) AS week_6_programming,
            MAX(CASE WHEN week = 7 THEN manufacturing END) AS week_7_programming
        FROM combined
        GROUP BY article_code
    ),

    weeks_general_coverage AS (
        SELECT
            combined.article_code,
            final_intermediate.daily_consumption,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                , daily_consumption) - 7                                    AS week_0_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                , daily_consumption) - 14                                   AS week_1_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                , daily_consumption) - 21                                   AS week_2_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                , daily_consumption) - 28                                   AS week_3_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                , daily_consumption) - 35                                   AS week_4_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                , daily_consumption) - 42                                   AS week_5_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                , daily_consumption) - 49                                   AS week_6_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                + COALESCE(week_7_programming, 0)
                , daily_consumption) - 56                                   AS week_7_coverage
        FROM combined
                 JOIN final_intermediate
                      ON combined.article_code = final_intermediate.article_code
                 JOIN weeks_general_programming
                      ON combined.article_code = weeks_general_programming.article_code
        GROUP BY
            combined.article_code,
            final_intermediate.daily_consumption,
            available_stock,
            week_0_programming,
            week_1_programming,
            week_2_programming,
            week_3_programming,
            week_4_programming,
            week_5_programming,
            week_6_programming,
            week_7_programming
    ),

    weeks_general AS (
        SELECT
            wgc.article_code,
            wgp.week_0_programming
                + wgp.week_1_programming
                + wgp.week_2_programming
                + wgp.week_3_programming
                + wgp.week_4_programming
                + wgp.week_5_programming
                + wgp.week_6_programming
                + wgp.week_7_programming
                AS total_programming,

            wgc.week_0_coverage,
            wgp.week_0_programming,

            wgc.week_1_coverage,
            wgp.week_1_programming,

            wgc.week_2_coverage,
            wgp.week_2_programming,

            wgc.week_3_coverage,
            wgp.week_3_programming,

            wgc.week_4_coverage,
            wgp.week_4_programming,

            wgc.week_5_coverage,
            wgp.week_5_programming,

            wgc.week_6_coverage,
            wgp.week_6_programming,

            wgc.week_7_coverage,
            wgp.week_7_programming
        FROM weeks_general_coverage wgc
                 JOIN weeks_general_programming wgp
                      ON wgc.article_code = wgp.article_code
    ),

    final_calculations AS (
        SELECT
            branch_id,
            final_intermediate.article_code,
            total_monthly_forecast  AS mean_forecast,
            available_stock,
            daily_consumption,
            CASE
                WHEN daily_consumption = 0 THEN 0
                ELSE available_stock / daily_consumption
                END AS coverage_without_production,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) < 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_positive,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) > 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_negative,
            COALESCE(wg.total_programming, 0)             AS total_programming,

            COALESCE(wg.week_0_programming, 0)            AS week_0_programming,
            COALESCE(wg.week_0_coverage, 0)               AS week_0_coverage,

            COALESCE(wg.week_1_programming, 0)            AS week_1_programming,
            COALESCE(wg.week_1_coverage, 0)               AS week_1_coverage,

            COALESCE(wg.week_2_programming, 0)            AS week_2_programming,
            COALESCE(wg.week_2_coverage, 0)               AS week_2_coverage,

            COALESCE(wg.week_3_programming, 0)            AS week_3_programming,
            COALESCE(wg.week_3_coverage, 0)               AS week_3_coverage,

            COALESCE(wg.week_4_programming, 0)            AS week_4_programming,
            COALESCE(wg.week_4_coverage, 0)               AS week_4_coverage,

            COALESCE(wg.week_5_programming, 0)            AS week_5_programming,
            COALESCE(wg.week_5_coverage, 0)               AS week_5_coverage,

            COALESCE(wg.week_6_programming, 0)            AS week_6_programming,
            COALESCE(wg.week_6_coverage, 0)               AS week_6_coverage,

            COALESCE(wg.week_7_programming, 0)            AS week_7_programming,
            COALESCE(wg.week_7_coverage, 0)               AS week_7_coverage,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) > 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_positive_with_production,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) < 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_negative_with_production
        FROM final_intermediate
                 LEFT JOIN weeks_general wg
                           ON final_intermediate.article_code = wg.article_code
    )
SELECT
    a.article_code,
    a.article_name,
    a.formula_name,
    a.format_name,
    fc.mean_forecast,
    fc.available_stock,
    fc.coverage_without_production,
    fc.need_positive,
    fc.need_negative,
    total_programming,
    week_0_programming,
    week_0_coverage,
    week_1_programming,
    week_1_coverage,
    week_2_programming,
    week_2_coverage,
    week_3_programming,
    week_3_coverage,
    week_4_programming,
    week_4_coverage,
    week_5_programming,
    week_5_coverage,
    week_6_programming,
    week_6_coverage,
    week_7_programming,
    week_7_coverage,
    need_positive_with_production,
    need_negative_with_production
FROM final_calculations fc
         JOIN brand_ian_master_article a
              ON a.article_code = fc.article_code
LIMIT 30
                OFFSET 0;
;-- -. . -..- - / . -. - .-. -.--
WITH
    date_range AS (
        SELECT generate_series(
                       CAST('2025-01-14' AS date),
                       CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day' - interval '1 day',
                       '1 day'
               ) AS target_date
    ),

    days_per_month AS (
        SELECT
            date_trunc('month', target_date)            AS month_start,
            CAST(COUNT(*) AS integer)                   AS days_in_range
        FROM date_range
        GROUP BY date_trunc('month', target_date)
    ),

    forecasts AS (
        SELECT
            branch_id,
            article_code,
            date_trunc('month', forecast_date) AS month_start,
            daily_forecast
        FROM public.daily_mean_forecast
        WHERE forecast_date >= CAST('2025-01-14' AS date)
          AND forecast_date <  CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day'
    ),

    monthly_forecast AS (
        SELECT
            dpm.month_start,
            f.branch_id,
            f.article_code,
            dpm.days_in_range,
            COALESCE(f.daily_forecast, 0) AS daily_forecast,
            COALESCE(dpm.days_in_range * f.daily_forecast, 0) AS monthly_forecast
        FROM days_per_month dpm
                 LEFT JOIN forecasts f
                           ON dpm.month_start = f.month_start
    ),

    final_sums AS (
        SELECT
            mf.branch_id,
            mf.article_code,
            SUM(mf.days_in_range)    AS total_days,
            SUM(mf.monthly_forecast) AS total_monthly_forecast
        FROM monthly_forecast mf
        GROUP BY mf.branch_id, mf.article_code
    ),

    final_intermediate AS (
        SELECT
            fs.branch_id,
            bm.article_code,
            fs.total_days,
            fs.total_monthly_forecast,
            bm.available_stock,
            CASE
                WHEN fs.total_days = 0 THEN 0
                ELSE fs.total_monthly_forecast / fs.total_days
                END AS daily_consumption
        FROM final_sums fs
                 LEFT JOIN brand_ian_master_stock bm
                           ON fs.article_code = bm.article_code
    ),

    weeks AS (
        SELECT
            generate_series(0, 7)                                                    AS week_offset,
            date_trunc('week', current_date) + (generate_series(0, 7) * interval '1 week') AS start_of_week,
            date_trunc('week', current_date) + ((generate_series(0, 7) + 1) * interval '1 week') - interval '1 second' AS end_of_week
    ),

    assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            SUM(b.manufacturing) AS total_manufacturing
        FROM brand_ian_po_po_week_detail_assigned b
                 JOIN weeks w
                      ON b.date >= w.start_of_week AND b.date < w.end_of_week
        GROUP BY w.week_offset, b.article_code
    ),

    not_assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            b.manufacturing AS manufacturing
        FROM brand_ian_po_po_week_detail_not_assigned b
                 JOIN weeks w
                      ON b.week_start_date = w.start_of_week
    ),

    combined AS (
        SELECT
            COALESCE(a.week, na.week)                 AS week,
            COALESCE(a.article_code, na.article_code) AS article_code,
            COALESCE(a.total_manufacturing, 0)
                + COALESCE(na.manufacturing, 0)       AS manufacturing
        FROM assigned a
                 FULL OUTER JOIN not_assigned na
                                 ON a.week = na.week
                                     AND a.article_code = na.article_code
    ),

    weeks_general_programming AS (
        SELECT
            article_code,
            MAX(CASE WHEN week = 0 THEN manufacturing END) AS week_0_programming,
            MAX(CASE WHEN week = 1 THEN manufacturing END) AS week_1_programming,
            MAX(CASE WHEN week = 2 THEN manufacturing END) AS week_2_programming,
            MAX(CASE WHEN week = 3 THEN manufacturing END) AS week_3_programming,
            MAX(CASE WHEN week = 4 THEN manufacturing END) AS week_4_programming,
            MAX(CASE WHEN week = 5 THEN manufacturing END) AS week_5_programming,
            MAX(CASE WHEN week = 6 THEN manufacturing END) AS week_6_programming,
            MAX(CASE WHEN week = 7 THEN manufacturing END) AS week_7_programming
        FROM combined
        GROUP BY article_code
    ),

    weeks_general_coverage AS (
        SELECT
            combined.article_code,
            final_intermediate.daily_consumption,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                , daily_consumption) - 7                                    AS week_0_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                , daily_consumption) - 14                                   AS week_1_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                , daily_consumption) - 21                                   AS week_2_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                , daily_consumption) - 28                                   AS week_3_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                , daily_consumption) - 35                                   AS week_4_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                , daily_consumption) - 42                                   AS week_5_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                , daily_consumption) - 49                                   AS week_6_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                + COALESCE(week_7_programming, 0)
                , daily_consumption) - 56                                   AS week_7_coverage
        FROM combined
                 JOIN final_intermediate
                      ON combined.article_code = final_intermediate.article_code
                 JOIN weeks_general_programming
                      ON combined.article_code = weeks_general_programming.article_code
        GROUP BY
            combined.article_code,
            final_intermediate.daily_consumption,
            available_stock,
            week_0_programming,
            week_1_programming,
            week_2_programming,
            week_3_programming,
            week_4_programming,
            week_5_programming,
            week_6_programming,
            week_7_programming
    ),

    weeks_general AS (
        SELECT
            wgc.article_code,
            wgp.week_0_programming
                + wgp.week_1_programming
                + wgp.week_2_programming
                + wgp.week_3_programming
                + wgp.week_4_programming
                + wgp.week_5_programming
                + wgp.week_6_programming
                + wgp.week_7_programming
                AS total_programming,

            wgc.week_0_coverage,
            wgp.week_0_programming,

            wgc.week_1_coverage,
            wgp.week_1_programming,

            wgc.week_2_coverage,
            wgp.week_2_programming,

            wgc.week_3_coverage,
            wgp.week_3_programming,

            wgc.week_4_coverage,
            wgp.week_4_programming,

            wgc.week_5_coverage,
            wgp.week_5_programming,

            wgc.week_6_coverage,
            wgp.week_6_programming,

            wgc.week_7_coverage,
            wgp.week_7_programming
        FROM weeks_general_coverage wgc
                 JOIN weeks_general_programming wgp
                      ON wgc.article_code = wgp.article_code
    ),

    final_calculations AS (
        SELECT
            branch_id,
            final_intermediate.article_code,
            total_monthly_forecast  AS mean_forecast,
            available_stock,
            daily_consumption,
            CASE
                WHEN daily_consumption = 0 THEN 0
                ELSE available_stock / daily_consumption
                END AS coverage_without_production,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) < 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_positive,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) > 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_negative,
            COALESCE(wg.total_programming, 0)             AS total_programming,

            COALESCE(wg.week_0_programming, 0)            AS week_0_programming,
            COALESCE(wg.week_0_coverage, 0)               AS week_0_coverage,

            COALESCE(wg.week_1_programming, 0)            AS week_1_programming,
            COALESCE(wg.week_1_coverage, 0)               AS week_1_coverage,

            COALESCE(wg.week_2_programming, 0)            AS week_2_programming,
            COALESCE(wg.week_2_coverage, 0)               AS week_2_coverage,

            COALESCE(wg.week_3_programming, 0)            AS week_3_programming,
            COALESCE(wg.week_3_coverage, 0)               AS week_3_coverage,

            COALESCE(wg.week_4_programming, 0)            AS week_4_programming,
            COALESCE(wg.week_4_coverage, 0)               AS week_4_coverage,

            COALESCE(wg.week_5_programming, 0)            AS week_5_programming,
            COALESCE(wg.week_5_coverage, 0)               AS week_5_coverage,

            COALESCE(wg.week_6_programming, 0)            AS week_6_programming,
            COALESCE(wg.week_6_coverage, 0)               AS week_6_coverage,

            COALESCE(wg.week_7_programming, 0)            AS week_7_programming,
            COALESCE(wg.week_7_coverage, 0)               AS week_7_coverage,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) > 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_positive_with_production,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) < 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_negative_with_production
        FROM final_intermediate
                 LEFT JOIN weeks_general wg
                           ON final_intermediate.article_code = wg.article_code
    )

    COUNT;
;-- -. . -..- - / . -. - .-. -.--
WITH
    date_range AS (
        SELECT generate_series(
                       CAST('2025-01-14' AS date),
                       CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day' - interval '1 day',
                       '1 day'
               ) AS target_date
    ),

    days_per_month AS (
        SELECT
            date_trunc('month', target_date)            AS month_start,
            CAST(COUNT(*) AS integer)                   AS days_in_range
        FROM date_range
        GROUP BY date_trunc('month', target_date)
    ),

    forecasts AS (
        SELECT
            branch_id,
            article_code,
            date_trunc('month', forecast_date) AS month_start,
            daily_forecast
        FROM public.daily_mean_forecast
        WHERE forecast_date >= CAST('2025-01-14' AS date)
          AND forecast_date <  CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day'
    ),

    monthly_forecast AS (
        SELECT
            dpm.month_start,
            f.branch_id,
            f.article_code,
            dpm.days_in_range,
            COALESCE(f.daily_forecast, 0) AS daily_forecast,
            COALESCE(dpm.days_in_range * f.daily_forecast, 0) AS monthly_forecast
        FROM days_per_month dpm
                 LEFT JOIN forecasts f
                           ON dpm.month_start = f.month_start
    ),

    final_sums AS (
        SELECT
            mf.branch_id,
            mf.article_code,
            SUM(mf.days_in_range)    AS total_days,
            SUM(mf.monthly_forecast) AS total_monthly_forecast
        FROM monthly_forecast mf
        GROUP BY mf.branch_id, mf.article_code
    ),

    final_intermediate AS (
        SELECT
            fs.branch_id,
            bm.article_code,
            fs.total_days,
            fs.total_monthly_forecast,
            bm.available_stock,
            CASE
                WHEN fs.total_days = 0 THEN 0
                ELSE fs.total_monthly_forecast / fs.total_days
                END AS daily_consumption
        FROM final_sums fs
                 LEFT JOIN brand_ian_master_stock bm
                           ON fs.article_code = bm.article_code
    ),

    weeks AS (
        SELECT
            generate_series(0, 7)                                                    AS week_offset,
            date_trunc('week', current_date) + (generate_series(0, 7) * interval '1 week') AS start_of_week,
            date_trunc('week', current_date) + ((generate_series(0, 7) + 1) * interval '1 week') - interval '1 second' AS end_of_week
    ),

    assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            SUM(b.manufacturing) AS total_manufacturing
        FROM brand_ian_po_po_week_detail_assigned b
                 JOIN weeks w
                      ON b.date >= w.start_of_week AND b.date < w.end_of_week
        GROUP BY w.week_offset, b.article_code
    ),

    not_assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            b.manufacturing AS manufacturing
        FROM brand_ian_po_po_week_detail_not_assigned b
                 JOIN weeks w
                      ON b.week_start_date = w.start_of_week
    ),

    combined AS (
        SELECT
            COALESCE(a.week, na.week)                 AS week,
            COALESCE(a.article_code, na.article_code) AS article_code,
            COALESCE(a.total_manufacturing, 0)
                + COALESCE(na.manufacturing, 0)       AS manufacturing
        FROM assigned a
                 FULL OUTER JOIN not_assigned na
                                 ON a.week = na.week
                                     AND a.article_code = na.article_code
    ),

    weeks_general_programming AS (
        SELECT
            article_code,
            MAX(CASE WHEN week = 0 THEN manufacturing END) AS week_0_programming,
            MAX(CASE WHEN week = 1 THEN manufacturing END) AS week_1_programming,
            MAX(CASE WHEN week = 2 THEN manufacturing END) AS week_2_programming,
            MAX(CASE WHEN week = 3 THEN manufacturing END) AS week_3_programming,
            MAX(CASE WHEN week = 4 THEN manufacturing END) AS week_4_programming,
            MAX(CASE WHEN week = 5 THEN manufacturing END) AS week_5_programming,
            MAX(CASE WHEN week = 6 THEN manufacturing END) AS week_6_programming,
            MAX(CASE WHEN week = 7 THEN manufacturing END) AS week_7_programming
        FROM combined
        GROUP BY article_code
    ),

    weeks_general_coverage AS (
        SELECT
            combined.article_code,
            final_intermediate.daily_consumption,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                , daily_consumption) - 7                                    AS week_0_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                , daily_consumption) - 14                                   AS week_1_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                , daily_consumption) - 21                                   AS week_2_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                , daily_consumption) - 28                                   AS week_3_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                , daily_consumption) - 35                                   AS week_4_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                , daily_consumption) - 42                                   AS week_5_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                , daily_consumption) - 49                                   AS week_6_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                + COALESCE(week_7_programming, 0)
                , daily_consumption) - 56                                   AS week_7_coverage
        FROM combined
                 JOIN final_intermediate
                      ON combined.article_code = final_intermediate.article_code
                 JOIN weeks_general_programming
                      ON combined.article_code = weeks_general_programming.article_code
        GROUP BY
            combined.article_code,
            final_intermediate.daily_consumption,
            available_stock,
            week_0_programming,
            week_1_programming,
            week_2_programming,
            week_3_programming,
            week_4_programming,
            week_5_programming,
            week_6_programming,
            week_7_programming
    ),

    weeks_general AS (
        SELECT
            wgc.article_code,
            wgp.week_0_programming
                + wgp.week_1_programming
                + wgp.week_2_programming
                + wgp.week_3_programming
                + wgp.week_4_programming
                + wgp.week_5_programming
                + wgp.week_6_programming
                + wgp.week_7_programming
                AS total_programming,

            wgc.week_0_coverage,
            wgp.week_0_programming,

            wgc.week_1_coverage,
            wgp.week_1_programming,

            wgc.week_2_coverage,
            wgp.week_2_programming,

            wgc.week_3_coverage,
            wgp.week_3_programming,

            wgc.week_4_coverage,
            wgp.week_4_programming,

            wgc.week_5_coverage,
            wgp.week_5_programming,

            wgc.week_6_coverage,
            wgp.week_6_programming,

            wgc.week_7_coverage,
            wgp.week_7_programming
        FROM weeks_general_coverage wgc
                 JOIN weeks_general_programming wgp
                      ON wgc.article_code = wgp.article_code
    ),

    final_calculations AS (
        SELECT
            branch_id,
            final_intermediate.article_code,
            total_monthly_forecast  AS mean_forecast,
            available_stock,
            daily_consumption,
            CASE
                WHEN daily_consumption = 0 THEN 0
                ELSE available_stock / daily_consumption
                END AS coverage_without_production,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) < 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_positive,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) > 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_negative,
            COALESCE(wg.total_programming, 0)             AS total_programming,

            COALESCE(wg.week_0_programming, 0)            AS week_0_programming,
            COALESCE(wg.week_0_coverage, 0)               AS week_0_coverage,

            COALESCE(wg.week_1_programming, 0)            AS week_1_programming,
            COALESCE(wg.week_1_coverage, 0)               AS week_1_coverage,

            COALESCE(wg.week_2_programming, 0)            AS week_2_programming,
            COALESCE(wg.week_2_coverage, 0)               AS week_2_coverage,

            COALESCE(wg.week_3_programming, 0)            AS week_3_programming,
            COALESCE(wg.week_3_coverage, 0)               AS week_3_coverage,

            COALESCE(wg.week_4_programming, 0)            AS week_4_programming,
            COALESCE(wg.week_4_coverage, 0)               AS week_4_coverage,

            COALESCE(wg.week_5_programming, 0)            AS week_5_programming,
            COALESCE(wg.week_5_coverage, 0)               AS week_5_coverage,

            COALESCE(wg.week_6_programming, 0)            AS week_6_programming,
            COALESCE(wg.week_6_coverage, 0)               AS week_6_coverage,

            COALESCE(wg.week_7_programming, 0)            AS week_7_programming,
            COALESCE(wg.week_7_coverage, 0)               AS week_7_coverage,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) > 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_positive_with_production,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) < 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_negative_with_production
        FROM final_intermediate
                 LEFT JOIN weeks_general wg
                           ON final_intermediate.article_code = wg.article_code
    )
-- SELECT
--     COUNT(*)                                    AS total_rows,
--         SUM(fc.mean_forecast)                       AS mean_forecast,
--         SUM(fc.available_stock)                     AS available_stock,
--         CASE
--             WHEN SUM(fc.mean_forecast) = 0 THEN 0
--             ELSE SUM(fc.available_stock) / (SUM(fc.mean_forecast) / :days)
-- END AS coverage_without_production,
--         SUM(fc.need_positive)                       AS need_positive,
--         SUM(fc.need_negative)                       AS need_negative,
--         SUM(fc.total_programming)                   AS total_programming,
--         SUM(fc.week_0_programming)                  AS week_0_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 7                 AS week_0_coverage,
--         SUM(fc.week_1_programming)                  AS week_1_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 14                AS week_1_coverage,
--         SUM(fc.week_2_programming)                  AS week_2_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 21                AS week_2_coverage,
--         SUM(fc.week_3_programming)                  AS week_3_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 28                AS week_3_coverage,
--         SUM(fc.week_4_programming)                  AS week_4_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 35                AS week_4_coverage,
--         SUM(fc.week_5_programming)                  AS week_5_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 42                AS week_5_coverage,
--         SUM(fc.week_6_programming)                  AS week_6_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 49                AS week_6_coverage,
--         SUM(fc.week_7_programming)                  AS week_7_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) + COALESCE((sum(fc.week_7_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 56                AS week_7_coverage,
--         SUM(fc.need_positive_with_production)        AS need_positive_with_production,
--         SUM(fc.need_negative_with_production)        AS need_negative_with_production
--     FROM final_calculations fc;

SELECT
    COUNT(*)
--     a.article_code,
--     a.article_name,
--     a.formula_name,
--     a.format_name,
--     fc.mean_forecast,
--     fc.available_stock,
--     fc.coverage_without_production,
--     fc.need_positive,
--     fc.need_negative,
--     total_programming,
--     week_0_programming,
--     week_0_coverage,
--     week_1_programming,
--     week_1_coverage,
--     week_2_programming,
--     week_2_coverage,
--     week_3_programming,
--     week_3_coverage,
--     week_4_programming,
--     week_4_coverage,
--     week_5_programming,
--     week_5_coverage,
--     week_6_programming,
--     week_6_coverage,
--     week_7_programming,
--     week_7_coverage,
--     need_positive_with_production,
--     need_negative_with_production
FROM final_calculations fc
         JOIN brand_ian_master_article a
              ON a.article_code = fc.article_code;
;-- -. . -..- - / . -. - .-. -.--
WITH
    date_range AS (
        SELECT generate_series(
                       CAST('2025-01-14' AS date),
                       CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day' - interval '1 day',
                       '1 day'
               ) AS target_date
    ),

    days_per_month AS (
        SELECT
            date_trunc('month', target_date)            AS month_start,
            CAST(COUNT(*) AS integer)                   AS days_in_range
        FROM date_range
        GROUP BY date_trunc('month', target_date)
    ),

    forecasts AS (
        SELECT
            branch_id,
            article_code,
            date_trunc('month', forecast_date) AS month_start,
            daily_forecast
        FROM public.daily_mean_forecast
        WHERE forecast_date >= CAST('2025-01-14' AS date)
          AND forecast_date <  CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day'
    ),

    monthly_forecast AS (
        SELECT
            dpm.month_start,
            f.branch_id,
            f.article_code,
            dpm.days_in_range,
            COALESCE(f.daily_forecast, 0) AS daily_forecast,
            COALESCE(dpm.days_in_range * f.daily_forecast, 0) AS monthly_forecast
        FROM days_per_month dpm
                 LEFT JOIN forecasts f
                           ON dpm.month_start = f.month_start
    ),

    final_sums AS (
        SELECT
            mf.branch_id,
            mf.article_code,
            SUM(mf.days_in_range)    AS total_days,
            SUM(mf.monthly_forecast) AS total_monthly_forecast
        FROM monthly_forecast mf
        GROUP BY mf.branch_id, mf.article_code
    ),

    final_intermediate AS (
        SELECT
            fs.branch_id,
            bm.article_code,
            fs.total_days,
            fs.total_monthly_forecast,
            bm.available_stock,
            CASE
                WHEN fs.total_days = 0 THEN 0
                ELSE fs.total_monthly_forecast / fs.total_days
                END AS daily_consumption
        FROM final_sums fs
                 LEFT JOIN brand_ian_master_stock bm
                           ON fs.article_code = bm.article_code
    ),

    weeks AS (
        SELECT
            generate_series(0, 7)                                                    AS week_offset,
            date_trunc('week', current_date) + (generate_series(0, 7) * interval '1 week') AS start_of_week,
            date_trunc('week', current_date) + ((generate_series(0, 7) + 1) * interval '1 week') - interval '1 second' AS end_of_week
    ),

    assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            SUM(b.manufacturing) AS total_manufacturing
        FROM brand_ian_po_po_week_detail_assigned b
                 JOIN weeks w
                      ON b.date >= w.start_of_week AND b.date < w.end_of_week
        GROUP BY w.week_offset, b.article_code
    ),

    not_assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            b.manufacturing AS manufacturing
        FROM brand_ian_po_po_week_detail_not_assigned b
                 JOIN weeks w
                      ON b.week_start_date = w.start_of_week
    ),

    combined AS (
        SELECT
            COALESCE(a.week, na.week)                 AS week,
            COALESCE(a.article_code, na.article_code) AS article_code,
            COALESCE(a.total_manufacturing, 0)
                + COALESCE(na.manufacturing, 0)       AS manufacturing
        FROM assigned a
                 FULL OUTER JOIN not_assigned na
                                 ON a.week = na.week
                                     AND a.article_code = na.article_code
    ),

    weeks_general_programming AS (
        SELECT
            article_code,
            MAX(CASE WHEN week = 0 THEN manufacturing END) AS week_0_programming,
            MAX(CASE WHEN week = 1 THEN manufacturing END) AS week_1_programming,
            MAX(CASE WHEN week = 2 THEN manufacturing END) AS week_2_programming,
            MAX(CASE WHEN week = 3 THEN manufacturing END) AS week_3_programming,
            MAX(CASE WHEN week = 4 THEN manufacturing END) AS week_4_programming,
            MAX(CASE WHEN week = 5 THEN manufacturing END) AS week_5_programming,
            MAX(CASE WHEN week = 6 THEN manufacturing END) AS week_6_programming,
            MAX(CASE WHEN week = 7 THEN manufacturing END) AS week_7_programming
        FROM combined
        GROUP BY article_code
    ),

    weeks_general_coverage AS (
        SELECT
            combined.article_code,
            final_intermediate.daily_consumption,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                , daily_consumption) - 7                                    AS week_0_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                , daily_consumption) - 14                                   AS week_1_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                , daily_consumption) - 21                                   AS week_2_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                , daily_consumption) - 28                                   AS week_3_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                , daily_consumption) - 35                                   AS week_4_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                , daily_consumption) - 42                                   AS week_5_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                , daily_consumption) - 49                                   AS week_6_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                + COALESCE(week_7_programming, 0)
                , daily_consumption) - 56                                   AS week_7_coverage
        FROM combined
                 JOIN final_intermediate
                      ON combined.article_code = final_intermediate.article_code
                 JOIN weeks_general_programming
                      ON combined.article_code = weeks_general_programming.article_code
        GROUP BY
            combined.article_code,
            final_intermediate.daily_consumption,
            available_stock,
            week_0_programming,
            week_1_programming,
            week_2_programming,
            week_3_programming,
            week_4_programming,
            week_5_programming,
            week_6_programming,
            week_7_programming
    ),

    weeks_general AS (
        SELECT
            wgc.article_code,
            wgp.week_0_programming
                + wgp.week_1_programming
                + wgp.week_2_programming
                + wgp.week_3_programming
                + wgp.week_4_programming
                + wgp.week_5_programming
                + wgp.week_6_programming
                + wgp.week_7_programming
                AS total_programming,

            wgc.week_0_coverage,
            wgp.week_0_programming,

            wgc.week_1_coverage,
            wgp.week_1_programming,

            wgc.week_2_coverage,
            wgp.week_2_programming,

            wgc.week_3_coverage,
            wgp.week_3_programming,

            wgc.week_4_coverage,
            wgp.week_4_programming,

            wgc.week_5_coverage,
            wgp.week_5_programming,

            wgc.week_6_coverage,
            wgp.week_6_programming,

            wgc.week_7_coverage,
            wgp.week_7_programming
        FROM weeks_general_coverage wgc
                 JOIN weeks_general_programming wgp
                      ON wgc.article_code = wgp.article_code
    ),

    final_calculations AS (
        SELECT
            branch_id,
            final_intermediate.article_code,
            total_monthly_forecast  AS mean_forecast,
            available_stock,
            daily_consumption,
            CASE
                WHEN daily_consumption = 0 THEN 0
                ELSE available_stock / daily_consumption
                END AS coverage_without_production,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) < 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_positive,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) > 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_negative,
            COALESCE(wg.total_programming, 0)             AS total_programming,

            COALESCE(wg.week_0_programming, 0)            AS week_0_programming,
            COALESCE(wg.week_0_coverage, 0)               AS week_0_coverage,

            COALESCE(wg.week_1_programming, 0)            AS week_1_programming,
            COALESCE(wg.week_1_coverage, 0)               AS week_1_coverage,

            COALESCE(wg.week_2_programming, 0)            AS week_2_programming,
            COALESCE(wg.week_2_coverage, 0)               AS week_2_coverage,

            COALESCE(wg.week_3_programming, 0)            AS week_3_programming,
            COALESCE(wg.week_3_coverage, 0)               AS week_3_coverage,

            COALESCE(wg.week_4_programming, 0)            AS week_4_programming,
            COALESCE(wg.week_4_coverage, 0)               AS week_4_coverage,

            COALESCE(wg.week_5_programming, 0)            AS week_5_programming,
            COALESCE(wg.week_5_coverage, 0)               AS week_5_coverage,

            COALESCE(wg.week_6_programming, 0)            AS week_6_programming,
            COALESCE(wg.week_6_coverage, 0)               AS week_6_coverage,

            COALESCE(wg.week_7_programming, 0)            AS week_7_programming,
            COALESCE(wg.week_7_coverage, 0)               AS week_7_coverage,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) > 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_positive_with_production,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) < 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_negative_with_production
        FROM final_intermediate
                 LEFT JOIN weeks_general wg
                           ON final_intermediate.article_code = wg.article_code
    )
-- SELECT
--     COUNT(*)                                    AS total_rows,
--         SUM(fc.mean_forecast)                       AS mean_forecast,
--         SUM(fc.available_stock)                     AS available_stock,
--         CASE
--             WHEN SUM(fc.mean_forecast) = 0 THEN 0
--             ELSE SUM(fc.available_stock) / (SUM(fc.mean_forecast) / :days)
-- END AS coverage_without_production,
--         SUM(fc.need_positive)                       AS need_positive,
--         SUM(fc.need_negative)                       AS need_negative,
--         SUM(fc.total_programming)                   AS total_programming,
--         SUM(fc.week_0_programming)                  AS week_0_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 7                 AS week_0_coverage,
--         SUM(fc.week_1_programming)                  AS week_1_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 14                AS week_1_coverage,
--         SUM(fc.week_2_programming)                  AS week_2_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 21                AS week_2_coverage,
--         SUM(fc.week_3_programming)                  AS week_3_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 28                AS week_3_coverage,
--         SUM(fc.week_4_programming)                  AS week_4_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 35                AS week_4_coverage,
--         SUM(fc.week_5_programming)                  AS week_5_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 42                AS week_5_coverage,
--         SUM(fc.week_6_programming)                  AS week_6_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 49                AS week_6_coverage,
--         SUM(fc.week_7_programming)                  AS week_7_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) + COALESCE((sum(fc.week_7_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 56                AS week_7_coverage,
--         SUM(fc.need_positive_with_production)        AS need_positive_with_production,
--         SUM(fc.need_negative_with_production)        AS need_negative_with_production
--     FROM final_calculations fc;

SELECT
    COUNT(*)
--     a.article_code,
--     a.article_name,
--     a.formula_name,
--     a.format_name,
--     fc.mean_forecast,
--     fc.available_stock,
--     fc.coverage_without_production,
--     fc.need_positive,
--     fc.need_negative,
--     total_programming,
--     week_0_programming,
--     week_0_coverage,
--     week_1_programming,
--     week_1_coverage,
--     week_2_programming,
--     week_2_coverage,
--     week_3_programming,
--     week_3_coverage,
--     week_4_programming,
--     week_4_coverage,
--     week_5_programming,
--     week_5_coverage,
--     week_6_programming,
--     week_6_coverage,
--     week_7_programming,
--     week_7_coverage,
--     need_positive_with_production,
--     need_negative_with_production
FROM final_calculations fc
         left JOIN brand_ian_master_article a
              ON a.article_code = fc.article_code
LIMIT 30
                OFFSET 0;
;-- -. . -..- - / . -. - .-. -.--
WITH
    date_range AS (
        SELECT generate_series(
                       CAST('2025-01-14' AS date),
                       CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day' - interval '1 day',
                       '1 day'
               ) AS target_date
    ),

    days_per_month AS (
        SELECT
            date_trunc('month', target_date)            AS month_start,
            CAST(COUNT(*) AS integer)                   AS days_in_range
        FROM date_range
        GROUP BY date_trunc('month', target_date)
    ),

    forecasts AS (
        SELECT
            branch_id,
            article_code,
            date_trunc('month', forecast_date) AS month_start,
            daily_forecast
        FROM public.daily_mean_forecast
        WHERE forecast_date >= CAST('2025-01-14' AS date)
          AND forecast_date <  CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day'
    ),

    monthly_forecast AS (
        SELECT
            dpm.month_start,
            f.branch_id,
            f.article_code,
            dpm.days_in_range,
            COALESCE(f.daily_forecast, 0) AS daily_forecast,
            COALESCE(dpm.days_in_range * f.daily_forecast, 0) AS monthly_forecast
        FROM days_per_month dpm
                 LEFT JOIN forecasts f
                           ON dpm.month_start = f.month_start
    ),

    final_sums AS (
        SELECT
            mf.branch_id,
            mf.article_code,
            SUM(mf.days_in_range)    AS total_days,
            SUM(mf.monthly_forecast) AS total_monthly_forecast
        FROM monthly_forecast mf
        GROUP BY mf.branch_id, mf.article_code
    ),

    final_intermediate AS (
        SELECT
            fs.branch_id,
            bm.article_code,
            fs.total_days,
            fs.total_monthly_forecast,
            bm.available_stock,
            CASE
                WHEN fs.total_days = 0 THEN 0
                ELSE fs.total_monthly_forecast / fs.total_days
                END AS daily_consumption
        FROM final_sums fs
                 LEFT JOIN brand_ian_master_stock bm
                           ON fs.article_code = bm.article_code
    ),

    weeks AS (
        SELECT
            generate_series(0, 7)                                                    AS week_offset,
            date_trunc('week', current_date) + (generate_series(0, 7) * interval '1 week') AS start_of_week,
            date_trunc('week', current_date) + ((generate_series(0, 7) + 1) * interval '1 week') - interval '1 second' AS end_of_week
    ),

    assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            SUM(b.manufacturing) AS total_manufacturing
        FROM brand_ian_po_po_week_detail_assigned b
                 JOIN weeks w
                      ON b.date >= w.start_of_week AND b.date < w.end_of_week
        GROUP BY w.week_offset, b.article_code
    ),

    not_assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            b.manufacturing AS manufacturing
        FROM brand_ian_po_po_week_detail_not_assigned b
                 JOIN weeks w
                      ON b.week_start_date = w.start_of_week
    ),

    combined AS (
        SELECT
            COALESCE(a.week, na.week)                 AS week,
            COALESCE(a.article_code, na.article_code) AS article_code,
            COALESCE(a.total_manufacturing, 0)
                + COALESCE(na.manufacturing, 0)       AS manufacturing
        FROM assigned a
                 FULL OUTER JOIN not_assigned na
                                 ON a.week = na.week
                                     AND a.article_code = na.article_code
    ),

    weeks_general_programming AS (
        SELECT
            article_code,
            MAX(CASE WHEN week = 0 THEN manufacturing END) AS week_0_programming,
            MAX(CASE WHEN week = 1 THEN manufacturing END) AS week_1_programming,
            MAX(CASE WHEN week = 2 THEN manufacturing END) AS week_2_programming,
            MAX(CASE WHEN week = 3 THEN manufacturing END) AS week_3_programming,
            MAX(CASE WHEN week = 4 THEN manufacturing END) AS week_4_programming,
            MAX(CASE WHEN week = 5 THEN manufacturing END) AS week_5_programming,
            MAX(CASE WHEN week = 6 THEN manufacturing END) AS week_6_programming,
            MAX(CASE WHEN week = 7 THEN manufacturing END) AS week_7_programming
        FROM combined
        GROUP BY article_code
    ),

    weeks_general_coverage AS (
        SELECT
            combined.article_code,
            final_intermediate.daily_consumption,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                , daily_consumption) - 7                                    AS week_0_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                , daily_consumption) - 14                                   AS week_1_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                , daily_consumption) - 21                                   AS week_2_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                , daily_consumption) - 28                                   AS week_3_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                , daily_consumption) - 35                                   AS week_4_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                , daily_consumption) - 42                                   AS week_5_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                , daily_consumption) - 49                                   AS week_6_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                + COALESCE(week_7_programming, 0)
                , daily_consumption) - 56                                   AS week_7_coverage
        FROM combined
                 JOIN final_intermediate
                      ON combined.article_code = final_intermediate.article_code
                 JOIN weeks_general_programming
                      ON combined.article_code = weeks_general_programming.article_code
        GROUP BY
            combined.article_code,
            final_intermediate.daily_consumption,
            available_stock,
            week_0_programming,
            week_1_programming,
            week_2_programming,
            week_3_programming,
            week_4_programming,
            week_5_programming,
            week_6_programming,
            week_7_programming
    ),

    weeks_general AS (
        SELECT
            wgc.article_code,
            wgp.week_0_programming
                + wgp.week_1_programming
                + wgp.week_2_programming
                + wgp.week_3_programming
                + wgp.week_4_programming
                + wgp.week_5_programming
                + wgp.week_6_programming
                + wgp.week_7_programming
                AS total_programming,

            wgc.week_0_coverage,
            wgp.week_0_programming,

            wgc.week_1_coverage,
            wgp.week_1_programming,

            wgc.week_2_coverage,
            wgp.week_2_programming,

            wgc.week_3_coverage,
            wgp.week_3_programming,

            wgc.week_4_coverage,
            wgp.week_4_programming,

            wgc.week_5_coverage,
            wgp.week_5_programming,

            wgc.week_6_coverage,
            wgp.week_6_programming,

            wgc.week_7_coverage,
            wgp.week_7_programming
        FROM weeks_general_coverage wgc
                 JOIN weeks_general_programming wgp
                      ON wgc.article_code = wgp.article_code
    ),

    final_calculations AS (
        SELECT
            branch_id,
            final_intermediate.article_code,
            total_monthly_forecast  AS mean_forecast,
            available_stock,
            daily_consumption,
            CASE
                WHEN daily_consumption = 0 THEN 0
                ELSE available_stock / daily_consumption
                END AS coverage_without_production,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) < 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_positive,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) > 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_negative,
            COALESCE(wg.total_programming, 0)             AS total_programming,

            COALESCE(wg.week_0_programming, 0)            AS week_0_programming,
            COALESCE(wg.week_0_coverage, 0)               AS week_0_coverage,

            COALESCE(wg.week_1_programming, 0)            AS week_1_programming,
            COALESCE(wg.week_1_coverage, 0)               AS week_1_coverage,

            COALESCE(wg.week_2_programming, 0)            AS week_2_programming,
            COALESCE(wg.week_2_coverage, 0)               AS week_2_coverage,

            COALESCE(wg.week_3_programming, 0)            AS week_3_programming,
            COALESCE(wg.week_3_coverage, 0)               AS week_3_coverage,

            COALESCE(wg.week_4_programming, 0)            AS week_4_programming,
            COALESCE(wg.week_4_coverage, 0)               AS week_4_coverage,

            COALESCE(wg.week_5_programming, 0)            AS week_5_programming,
            COALESCE(wg.week_5_coverage, 0)               AS week_5_coverage,

            COALESCE(wg.week_6_programming, 0)            AS week_6_programming,
            COALESCE(wg.week_6_coverage, 0)               AS week_6_coverage,

            COALESCE(wg.week_7_programming, 0)            AS week_7_programming,
            COALESCE(wg.week_7_coverage, 0)               AS week_7_coverage,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) > 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_positive_with_production,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) < 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_negative_with_production
        FROM final_intermediate
                 LEFT JOIN weeks_general wg
                           ON final_intermediate.article_code = wg.article_code
    )
-- SELECT
--     COUNT(*)                                    AS total_rows,
--         SUM(fc.mean_forecast)                       AS mean_forecast,
--         SUM(fc.available_stock)                     AS available_stock,
--         CASE
--             WHEN SUM(fc.mean_forecast) = 0 THEN 0
--             ELSE SUM(fc.available_stock) / (SUM(fc.mean_forecast) / :days)
-- END AS coverage_without_production,
--         SUM(fc.need_positive)                       AS need_positive,
--         SUM(fc.need_negative)                       AS need_negative,
--         SUM(fc.total_programming)                   AS total_programming,
--         SUM(fc.week_0_programming)                  AS week_0_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 7                 AS week_0_coverage,
--         SUM(fc.week_1_programming)                  AS week_1_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 14                AS week_1_coverage,
--         SUM(fc.week_2_programming)                  AS week_2_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 21                AS week_2_coverage,
--         SUM(fc.week_3_programming)                  AS week_3_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 28                AS week_3_coverage,
--         SUM(fc.week_4_programming)                  AS week_4_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 35                AS week_4_coverage,
--         SUM(fc.week_5_programming)                  AS week_5_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 42                AS week_5_coverage,
--         SUM(fc.week_6_programming)                  AS week_6_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 49                AS week_6_coverage,
--         SUM(fc.week_7_programming)                  AS week_7_programming,
--         COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) + COALESCE((sum(fc.week_7_programming)), 0) / (SUM(fc.mean_forecast) / :days) - 56                AS week_7_coverage,
--         SUM(fc.need_positive_with_production)        AS need_positive_with_production,
--         SUM(fc.need_negative_with_production)        AS need_negative_with_production
--     FROM final_calculations fc;

SELECT
    COUNT(*)
--     a.article_code,
--     a.article_name,
--     a.formula_name,
--     a.format_name,
--     fc.mean_forecast,
--     fc.available_stock,
--     fc.coverage_without_production,
--     fc.need_positive,
--     fc.need_negative,
--     total_programming,
--     week_0_programming,
--     week_0_coverage,
--     week_1_programming,
--     week_1_coverage,
--     week_2_programming,
--     week_2_coverage,
--     week_3_programming,
--     week_3_coverage,
--     week_4_programming,
--     week_4_coverage,
--     week_5_programming,
--     week_5_coverage,
--     week_6_programming,
--     week_6_coverage,
--     week_7_programming,
--     week_7_coverage,
--     need_positive_with_production,
--     need_negative_with_production
FROM final_calculations fc
         JOIN brand_ian_master_article a
              ON a.article_code = fc.article_code
LIMIT 30
                OFFSET 0;
;-- -. . -..- - / . -. - .-. -.--
WITH
    date_range AS (
        SELECT generate_series(
                       CAST('2025-01-14' AS date),
                       CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day' - interval '1 day',
                       '1 day'
               ) AS target_date
    ),

    days_per_month AS (
        SELECT
            date_trunc('month', target_date)            AS month_start,
            CAST(COUNT(*) AS integer)                   AS days_in_range
        FROM date_range
        GROUP BY date_trunc('month', target_date)
    ),

    forecasts AS (
        SELECT
            branch_id,
            article_code,
            date_trunc('month', forecast_date) AS month_start,
            daily_forecast
        FROM public.daily_mean_forecast
        WHERE forecast_date >= CAST('2025-01-14' AS date)
          AND forecast_date <  CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day'
    ),

    monthly_forecast AS (
        SELECT
            dpm.month_start,
            f.branch_id,
            f.article_code,
            dpm.days_in_range,
            COALESCE(f.daily_forecast, 0) AS daily_forecast,
            COALESCE(dpm.days_in_range * f.daily_forecast, 0) AS monthly_forecast
        FROM days_per_month dpm
                 LEFT JOIN forecasts f
                           ON dpm.month_start = f.month_start
    ),

    final_sums AS (
        SELECT
            mf.branch_id,
            mf.article_code,
            SUM(mf.days_in_range)    AS total_days,
            SUM(mf.monthly_forecast) AS total_monthly_forecast
        FROM monthly_forecast mf
        GROUP BY mf.branch_id, mf.article_code
    ),

    final_intermediate AS (
        SELECT
            fs.branch_id,
            bm.article_code,
            fs.total_days,
            fs.total_monthly_forecast,
            bm.available_stock,
            CASE
                WHEN fs.total_days = 0 THEN 0
                ELSE fs.total_monthly_forecast / fs.total_days
                END AS daily_consumption
        FROM final_sums fs
                 LEFT JOIN brand_ian_master_stock bm
                           ON fs.article_code = bm.article_code
    ),

    weeks AS (
        SELECT
            generate_series(0, 7)                                                    AS week_offset,
            date_trunc('week', current_date) + (generate_series(0, 7) * interval '1 week') AS start_of_week,
            date_trunc('week', current_date) + ((generate_series(0, 7) + 1) * interval '1 week') - interval '1 second' AS end_of_week
    ),

    assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            SUM(b.manufacturing) AS total_manufacturing
        FROM brand_ian_po_po_week_detail_assigned b
                 JOIN weeks w
                      ON b.date >= w.start_of_week AND b.date < w.end_of_week
        GROUP BY w.week_offset, b.article_code
    ),

    not_assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            b.manufacturing AS manufacturing
        FROM brand_ian_po_po_week_detail_not_assigned b
                 JOIN weeks w
                      ON b.week_start_date = w.start_of_week
    ),

    combined AS (
        SELECT
            COALESCE(a.week, na.week)                 AS week,
            COALESCE(a.article_code, na.article_code) AS article_code,
            COALESCE(a.total_manufacturing, 0)
                + COALESCE(na.manufacturing, 0)       AS manufacturing
        FROM assigned a
                 FULL OUTER JOIN not_assigned na
                                 ON a.week = na.week
                                     AND a.article_code = na.article_code
    ),

    weeks_general_programming AS (
        SELECT
            article_code,
            MAX(CASE WHEN week = 0 THEN manufacturing END) AS week_0_programming,
            MAX(CASE WHEN week = 1 THEN manufacturing END) AS week_1_programming,
            MAX(CASE WHEN week = 2 THEN manufacturing END) AS week_2_programming,
            MAX(CASE WHEN week = 3 THEN manufacturing END) AS week_3_programming,
            MAX(CASE WHEN week = 4 THEN manufacturing END) AS week_4_programming,
            MAX(CASE WHEN week = 5 THEN manufacturing END) AS week_5_programming,
            MAX(CASE WHEN week = 6 THEN manufacturing END) AS week_6_programming,
            MAX(CASE WHEN week = 7 THEN manufacturing END) AS week_7_programming
        FROM combined
        GROUP BY article_code
    ),

    weeks_general_coverage AS (
        SELECT
            combined.article_code,
            final_intermediate.daily_consumption,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                , daily_consumption) - 7                                    AS week_0_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                , daily_consumption) - 14                                   AS week_1_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                , daily_consumption) - 21                                   AS week_2_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                , daily_consumption) - 28                                   AS week_3_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                , daily_consumption) - 35                                   AS week_4_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                , daily_consumption) - 42                                   AS week_5_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                , daily_consumption) - 49                                   AS week_6_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                + COALESCE(week_7_programming, 0)
                , daily_consumption) - 56                                   AS week_7_coverage
        FROM combined
                 JOIN final_intermediate
                      ON combined.article_code = final_intermediate.article_code
                 JOIN weeks_general_programming
                      ON combined.article_code = weeks_general_programming.article_code
        GROUP BY
            combined.article_code,
            final_intermediate.daily_consumption,
            available_stock,
            week_0_programming,
            week_1_programming,
            week_2_programming,
            week_3_programming,
            week_4_programming,
            week_5_programming,
            week_6_programming,
            week_7_programming
    ),

    weeks_general AS (
        SELECT
            wgc.article_code,
            wgp.week_0_programming
                + wgp.week_1_programming
                + wgp.week_2_programming
                + wgp.week_3_programming
                + wgp.week_4_programming
                + wgp.week_5_programming
                + wgp.week_6_programming
                + wgp.week_7_programming
                AS total_programming,

            wgc.week_0_coverage,
            wgp.week_0_programming,

            wgc.week_1_coverage,
            wgp.week_1_programming,

            wgc.week_2_coverage,
            wgp.week_2_programming,

            wgc.week_3_coverage,
            wgp.week_3_programming,

            wgc.week_4_coverage,
            wgp.week_4_programming,

            wgc.week_5_coverage,
            wgp.week_5_programming,

            wgc.week_6_coverage,
            wgp.week_6_programming,

            wgc.week_7_coverage,
            wgp.week_7_programming
        FROM weeks_general_coverage wgc
                 JOIN weeks_general_programming wgp
                      ON wgc.article_code = wgp.article_code
    ),

    final_calculations AS (
        SELECT
            branch_id,
            final_intermediate.article_code,
            total_monthly_forecast  AS mean_forecast,
            available_stock,
            daily_consumption,
            CASE
                WHEN daily_consumption = 0 THEN 0
                ELSE available_stock / daily_consumption
                END AS coverage_without_production,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) < 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_positive,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) > 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_negative,
            COALESCE(wg.total_programming, 0)             AS total_programming,

            COALESCE(wg.week_0_programming, 0)            AS week_0_programming,
            COALESCE(wg.week_0_coverage, 0)               AS week_0_coverage,

            COALESCE(wg.week_1_programming, 0)            AS week_1_programming,
            COALESCE(wg.week_1_coverage, 0)               AS week_1_coverage,

            COALESCE(wg.week_2_programming, 0)            AS week_2_programming,
            COALESCE(wg.week_2_coverage, 0)               AS week_2_coverage,

            COALESCE(wg.week_3_programming, 0)            AS week_3_programming,
            COALESCE(wg.week_3_coverage, 0)               AS week_3_coverage,

            COALESCE(wg.week_4_programming, 0)            AS week_4_programming,
            COALESCE(wg.week_4_coverage, 0)               AS week_4_coverage,

            COALESCE(wg.week_5_programming, 0)            AS week_5_programming,
            COALESCE(wg.week_5_coverage, 0)               AS week_5_coverage,

            COALESCE(wg.week_6_programming, 0)            AS week_6_programming,
            COALESCE(wg.week_6_coverage, 0)               AS week_6_coverage,

            COALESCE(wg.week_7_programming, 0)            AS week_7_programming,
            COALESCE(wg.week_7_coverage, 0)               AS week_7_coverage,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) > 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_positive_with_production,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) < 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_negative_with_production
        FROM final_intermediate
                 LEFT JOIN weeks_general wg
                           ON final_intermediate.article_code = wg.article_code
    )
SELECT
    COUNT(*)                                    AS total_rows,
        SUM(fc.mean_forecast)                       AS mean_forecast,
        SUM(fc.available_stock)                     AS available_stock,
        CASE
            WHEN SUM(fc.mean_forecast) = 0 THEN 0
            ELSE SUM(fc.available_stock) / (SUM(fc.mean_forecast) / 60)
END AS coverage_without_production,
        SUM(fc.need_positive)                       AS need_positive,
        SUM(fc.need_negative)                       AS need_negative,
        SUM(fc.total_programming)                   AS total_programming,
        SUM(fc.week_0_programming)                  AS week_0_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 7                 AS week_0_coverage,
        SUM(fc.week_1_programming)                  AS week_1_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 14                AS week_1_coverage,
        SUM(fc.week_2_programming)                  AS week_2_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 21                AS week_2_coverage,
        SUM(fc.week_3_programming)                  AS week_3_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 28                AS week_3_coverage,
        SUM(fc.week_4_programming)                  AS week_4_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 35                AS week_4_coverage,
        SUM(fc.week_5_programming)                  AS week_5_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 42                AS week_5_coverage,
        SUM(fc.week_6_programming)                  AS week_6_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 49                AS week_6_coverage,
        SUM(fc.week_7_programming)                  AS week_7_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) + COALESCE((sum(fc.week_7_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 56                AS week_7_coverage,
        SUM(fc.need_positive_with_production)        AS need_positive_with_production,
        SUM(fc.need_negative_with_production)        AS need_negative_with_production
    FROM final_calculations fc;
;-- -. . -..- - / . -. - .-. -.--
WITH
    date_range AS (
        SELECT generate_series(
                       CAST('2025-01-14' AS date),
                       CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day' - interval '1 day',
                       '1 day'
               ) AS target_date
    ),

    days_per_month AS (
        SELECT
            date_trunc('month', target_date)            AS month_start,
            CAST(COUNT(*) AS integer)                   AS days_in_range
        FROM date_range
        GROUP BY date_trunc('month', target_date)
    ),

    forecasts AS (
        SELECT
            branch_id,
            article_code,
            date_trunc('month', forecast_date) AS month_start,
            daily_forecast
        FROM public.daily_mean_forecast
        WHERE forecast_date >= CAST('2025-01-14' AS date)
          AND forecast_date <  CAST('2025-01-14' AS date) + CAST(60 AS integer) * interval '1 day'
    ),

    monthly_forecast AS (
        SELECT
            dpm.month_start,
            f.branch_id,
            f.article_code,
            dpm.days_in_range,
            COALESCE(f.daily_forecast, 0) AS daily_forecast,
            COALESCE(dpm.days_in_range * f.daily_forecast, 0) AS monthly_forecast
        FROM days_per_month dpm
                 LEFT JOIN forecasts f
                           ON dpm.month_start = f.month_start
    ),

    final_sums AS (
        SELECT
            mf.branch_id,
            mf.article_code,
            SUM(mf.days_in_range)    AS total_days,
            SUM(mf.monthly_forecast) AS total_monthly_forecast
        FROM monthly_forecast mf
        GROUP BY mf.branch_id, mf.article_code
    ),

    final_intermediate AS (
        SELECT
            fs.branch_id,
            bm.article_code,
            fs.total_days,
            fs.total_monthly_forecast,
            bm.available_stock,
            CASE
                WHEN fs.total_days = 0 THEN 0
                ELSE fs.total_monthly_forecast / fs.total_days
                END AS daily_consumption
        FROM final_sums fs
                 LEFT JOIN brand_ian_master_stock bm
                           ON fs.article_code = bm.article_code
    ),

    weeks AS (
        SELECT
            generate_series(0, 7)                                                    AS week_offset,
            date_trunc('week', current_date) + (generate_series(0, 7) * interval '1 week') AS start_of_week,
            date_trunc('week', current_date) + ((generate_series(0, 7) + 1) * interval '1 week') - interval '1 second' AS end_of_week
    ),

    assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            SUM(b.manufacturing) AS total_manufacturing
        FROM brand_ian_po_po_week_detail_assigned b
                 JOIN weeks w
                      ON b.date >= w.start_of_week AND b.date < w.end_of_week
        GROUP BY w.week_offset, b.article_code
    ),

    not_assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            b.manufacturing AS manufacturing
        FROM brand_ian_po_po_week_detail_not_assigned b
                 JOIN weeks w
                      ON b.week_start_date = w.start_of_week
    ),

    combined AS (
        SELECT
            COALESCE(a.week, na.week)                 AS week,
            COALESCE(a.article_code, na.article_code) AS article_code,
            COALESCE(a.total_manufacturing, 0)
                + COALESCE(na.manufacturing, 0)       AS manufacturing
        FROM assigned a
                 FULL OUTER JOIN not_assigned na
                                 ON a.week = na.week
                                     AND a.article_code = na.article_code
    ),

    weeks_general_programming AS (
        SELECT
            article_code,
            MAX(CASE WHEN week = 0 THEN manufacturing END) AS week_0_programming,
            MAX(CASE WHEN week = 1 THEN manufacturing END) AS week_1_programming,
            MAX(CASE WHEN week = 2 THEN manufacturing END) AS week_2_programming,
            MAX(CASE WHEN week = 3 THEN manufacturing END) AS week_3_programming,
            MAX(CASE WHEN week = 4 THEN manufacturing END) AS week_4_programming,
            MAX(CASE WHEN week = 5 THEN manufacturing END) AS week_5_programming,
            MAX(CASE WHEN week = 6 THEN manufacturing END) AS week_6_programming,
            MAX(CASE WHEN week = 7 THEN manufacturing END) AS week_7_programming
        FROM combined
        GROUP BY article_code
    ),

    weeks_general_coverage AS (
        SELECT
            combined.article_code,
            final_intermediate.daily_consumption,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                , daily_consumption) - 7                                    AS week_0_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                , daily_consumption) - 14                                   AS week_1_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                , daily_consumption) - 21                                   AS week_2_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                , daily_consumption) - 28                                   AS week_3_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                , daily_consumption) - 35                                   AS week_4_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                , daily_consumption) - 42                                   AS week_5_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                , daily_consumption) - 49                                   AS week_6_coverage,
            div(COALESCE(available_stock, 0)
                + COALESCE(week_0_programming, 0)
                + COALESCE(week_1_programming, 0)
                + COALESCE(week_2_programming, 0)
                + COALESCE(week_3_programming, 0)
                + COALESCE(week_4_programming, 0)
                + COALESCE(week_5_programming, 0)
                + COALESCE(week_6_programming, 0)
                + COALESCE(week_7_programming, 0)
                , daily_consumption) - 56                                   AS week_7_coverage
        FROM combined
                 JOIN final_intermediate
                      ON combined.article_code = final_intermediate.article_code
                 JOIN weeks_general_programming
                      ON combined.article_code = weeks_general_programming.article_code
        GROUP BY
            combined.article_code,
            final_intermediate.daily_consumption,
            available_stock,
            week_0_programming,
            week_1_programming,
            week_2_programming,
            week_3_programming,
            week_4_programming,
            week_5_programming,
            week_6_programming,
            week_7_programming
    ),

    weeks_general AS (
        SELECT
            wgc.article_code,
            wgp.week_0_programming
                + wgp.week_1_programming
                + wgp.week_2_programming
                + wgp.week_3_programming
                + wgp.week_4_programming
                + wgp.week_5_programming
                + wgp.week_6_programming
                + wgp.week_7_programming
                AS total_programming,

            wgc.week_0_coverage,
            wgp.week_0_programming,

            wgc.week_1_coverage,
            wgp.week_1_programming,

            wgc.week_2_coverage,
            wgp.week_2_programming,

            wgc.week_3_coverage,
            wgp.week_3_programming,

            wgc.week_4_coverage,
            wgp.week_4_programming,

            wgc.week_5_coverage,
            wgp.week_5_programming,

            wgc.week_6_coverage,
            wgp.week_6_programming,

            wgc.week_7_coverage,
            wgp.week_7_programming
        FROM weeks_general_coverage wgc
                 JOIN weeks_general_programming wgp
                      ON wgc.article_code = wgp.article_code
    ),

    final_calculations AS (
        SELECT
            branch_id,
            final_intermediate.article_code,
            total_monthly_forecast  AS mean_forecast,
            available_stock,
            daily_consumption,
            CASE
                WHEN daily_consumption = 0 THEN 0
                ELSE available_stock / daily_consumption
                END AS coverage_without_production,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) < 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_positive,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) > 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_negative,
            COALESCE(wg.total_programming, 0)             AS total_programming,

            COALESCE(wg.week_0_programming, 0)            AS week_0_programming,
            COALESCE(wg.week_0_coverage, 0)               AS week_0_coverage,

            COALESCE(wg.week_1_programming, 0)            AS week_1_programming,
            COALESCE(wg.week_1_coverage, 0)               AS week_1_coverage,

            COALESCE(wg.week_2_programming, 0)            AS week_2_programming,
            COALESCE(wg.week_2_coverage, 0)               AS week_2_coverage,

            COALESCE(wg.week_3_programming, 0)            AS week_3_programming,
            COALESCE(wg.week_3_coverage, 0)               AS week_3_coverage,

            COALESCE(wg.week_4_programming, 0)            AS week_4_programming,
            COALESCE(wg.week_4_coverage, 0)               AS week_4_coverage,

            COALESCE(wg.week_5_programming, 0)            AS week_5_programming,
            COALESCE(wg.week_5_coverage, 0)               AS week_5_coverage,

            COALESCE(wg.week_6_programming, 0)            AS week_6_programming,
            COALESCE(wg.week_6_coverage, 0)               AS week_6_coverage,

            COALESCE(wg.week_7_programming, 0)            AS week_7_programming,
            COALESCE(wg.week_7_coverage, 0)               AS week_7_coverage,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) > 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_positive_with_production,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) < 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_negative_with_production
        FROM final_intermediate
                 LEFT JOIN weeks_general wg
                           ON final_intermediate.article_code = wg.article_code
    )
SELECT
    COUNT(*)                                    AS total_rows,
        SUM(fc.mean_forecast)                       AS mean_forecast,
        SUM(fc.available_stock)                     AS available_stock,
        CASE
            WHEN SUM(fc.mean_forecast) = 0 THEN 0
            ELSE SUM(fc.available_stock) / (SUM(fc.mean_forecast) / 60)
END AS coverage_without_production,
        SUM(fc.need_positive)                       AS need_positive,
        SUM(fc.need_negative)                       AS need_negative,
        SUM(fc.total_programming)                   AS total_programming,
        SUM(fc.week_0_programming)                  AS week_0_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 7                 AS week_0_coverage,
        SUM(fc.week_1_programming)                  AS week_1_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 14                AS week_1_coverage,
        SUM(fc.week_2_programming)                  AS week_2_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 21                AS week_2_coverage,
        SUM(fc.week_3_programming)                  AS week_3_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 28                AS week_3_coverage,
        SUM(fc.week_4_programming)                  AS week_4_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 35                AS week_4_coverage,
        SUM(fc.week_5_programming)                  AS week_5_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 42                AS week_5_coverage,
        SUM(fc.week_6_programming)                  AS week_6_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 49                AS week_6_coverage,
        SUM(fc.week_7_programming)                  AS week_7_programming,
        COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) + COALESCE((sum(fc.week_7_programming)), 0) / (SUM(fc.mean_forecast) / 60) - 56                AS week_7_coverage,
        SUM(fc.need_positive_with_production)        AS need_positive_with_production,
        SUM(fc.need_negative_with_production)        AS need_negative_with_production
    FROM final_calculations fc 
    JOIN brand_ian_master_article a ON a.article_code = fc.article_code;
;-- -. . -..- - / . -. - .-. -.--
WITH
    date_range AS (
        SELECT generate_series(
                       CAST('2025-01-22' AS date),
                       CAST('2025-01-22' AS date) + CAST(30 AS integer) * interval '1 day' - interval '1 day',
                       '1 day'
               ) AS target_date
    ),

    days_per_month AS (
        SELECT
            date_trunc('month', target_date)            AS month_start,
            CAST(COUNT(*) AS integer)                   AS days_in_range
        FROM date_range
        GROUP BY date_trunc('month', target_date)
    ),

    forecasts AS (
        SELECT
            branch_id,
            article_code,
            date_trunc('month', forecast_date) AS month_start,
            daily_forecast
        FROM public.daily_mean_forecast
        WHERE forecast_date >= CAST('2025-01-22' AS date)
          AND forecast_date <  CAST('2025-01-22' AS date) + CAST(30 AS integer) * interval '1 day'
    ),

    monthly_forecast AS (
        SELECT
            dpm.month_start,
            f.branch_id,
            f.article_code,
            dpm.days_in_range,
            COALESCE(f.daily_forecast, 0) AS daily_forecast,
            COALESCE(dpm.days_in_range * f.daily_forecast, 0) AS monthly_forecast
        FROM days_per_month dpm
                 LEFT JOIN forecasts f
                           ON dpm.month_start = f.month_start
--                                %s
    ),

    final_sums AS (
        SELECT
            mf.branch_id,
            mf.article_code,
            SUM(mf.days_in_range)    AS total_days,
            SUM(mf.monthly_forecast) AS total_monthly_forecast
        FROM monthly_forecast mf
        GROUP BY mf.branch_id, mf.article_code
    ),

    final_intermediate AS (
        SELECT
            fs.branch_id,
            bm.article_code,
            fs.total_days,
            fs.total_monthly_forecast,
            bm.available_stock,
            CASE
                WHEN fs.total_days = 0 THEN 0
                ELSE fs.total_monthly_forecast / fs.total_days
                END AS daily_consumption
        FROM final_sums fs
                 LEFT JOIN brand_ian_master_stock bm
                           ON fs.article_code = bm.article_code
    ),

    weeks AS (
        SELECT
            generate_series(0, 7)                                                    AS week_offset,
            date_trunc('week', current_date) + (generate_series(0, 7) * interval '1 week') AS start_of_week,
            date_trunc('week', current_date) + ((generate_series(0, 7) + 1) * interval '1 week') - interval '1 second' AS end_of_week
    ),

    assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            SUM(b.manufacturing) AS total_manufacturing
        FROM brand_ian_po_po_week_detail_assigned b
                 JOIN weeks w
                      ON b.date >= w.start_of_week AND b.date < w.end_of_week
        GROUP BY w.week_offset, b.article_code
    ),

    not_assigned AS (
        SELECT
            w.week_offset AS week,
            b.article_code,
            b.manufacturing AS manufacturing
        FROM brand_ian_po_po_week_detail_not_assigned b
                 JOIN weeks w
                      ON b.week_start_date = w.start_of_week
    ),

    combined AS (
        SELECT
            COALESCE(a.week, na.week)                 AS week,
            COALESCE(a.article_code, na.article_code) AS article_code,
            COALESCE(a.total_manufacturing, 0)
                + COALESCE(na.manufacturing, 0)       AS manufacturing
        FROM assigned a
                 FULL OUTER JOIN not_assigned na
                                 ON a.week = na.week
                                     AND a.article_code = na.article_code
    ),

    weeks_general_programming AS (
        SELECT
            article_code,
            MAX(CASE WHEN week = 0 THEN manufacturing END) AS week_0_programming,
            MAX(CASE WHEN week = 1 THEN manufacturing END) AS week_1_programming,
            MAX(CASE WHEN week = 2 THEN manufacturing END) AS week_2_programming,
            MAX(CASE WHEN week = 3 THEN manufacturing END) AS week_3_programming,
            MAX(CASE WHEN week = 4 THEN manufacturing END) AS week_4_programming,
            MAX(CASE WHEN week = 5 THEN manufacturing END) AS week_5_programming,
            MAX(CASE WHEN week = 6 THEN manufacturing END) AS week_6_programming,
            MAX(CASE WHEN week = 7 THEN manufacturing END) AS week_7_programming
        FROM combined
        GROUP BY article_code
    ),
    weeks_general_coverage AS (
        SELECT
            combined.article_code,
            final_intermediate.daily_consumption,
            div(COALESCE(available_stock, 0)
                    + COALESCE(week_0_programming, 0)
                , daily_consumption) - 7                                    AS week_0_coverage,
            div(COALESCE(available_stock, 0)
                    + COALESCE(week_0_programming, 0)
                    + COALESCE(week_1_programming, 0)
                , daily_consumption) - 14                                   AS week_1_coverage,
            div(COALESCE(available_stock, 0)
                    + COALESCE(week_0_programming, 0)
                    + COALESCE(week_1_programming, 0)
                    + COALESCE(week_2_programming, 0)
                , daily_consumption) - 21                                   AS week_2_coverage,
            div(COALESCE(available_stock, 0)
                    + COALESCE(week_0_programming, 0)
                    + COALESCE(week_1_programming, 0)
                    + COALESCE(week_2_programming, 0)
                    + COALESCE(week_3_programming, 0)
                , daily_consumption) - 28                                   AS week_3_coverage,
            div(COALESCE(available_stock, 0)
                    + COALESCE(week_0_programming, 0)
                    + COALESCE(week_1_programming, 0)
                    + COALESCE(week_2_programming, 0)
                    + COALESCE(week_3_programming, 0)
                    + COALESCE(week_4_programming, 0)
                , daily_consumption) - 35                                   AS week_4_coverage,
            div(COALESCE(available_stock, 0)
                    + COALESCE(week_0_programming, 0)
                    + COALESCE(week_1_programming, 0)
                    + COALESCE(week_2_programming, 0)
                    + COALESCE(week_3_programming, 0)
                    + COALESCE(week_4_programming, 0)
                    + COALESCE(week_5_programming, 0)
                , daily_consumption) - 42                                   AS week_5_coverage,
            div(COALESCE(available_stock, 0)
                    + COALESCE(week_0_programming, 0)
                    + COALESCE(week_1_programming, 0)
                    + COALESCE(week_2_programming, 0)
                    + COALESCE(week_3_programming, 0)
                    + COALESCE(week_4_programming, 0)
                    + COALESCE(week_5_programming, 0)
                    + COALESCE(week_6_programming, 0)
                , daily_consumption) - 49                                   AS week_6_coverage,
            div(COALESCE(available_stock, 0)
                    + COALESCE(week_0_programming, 0)
                    + COALESCE(week_1_programming, 0)
                    + COALESCE(week_2_programming, 0)
                    + COALESCE(week_3_programming, 0)
                    + COALESCE(week_4_programming, 0)
                    + COALESCE(week_5_programming, 0)
                    + COALESCE(week_6_programming, 0)
                    + COALESCE(week_7_programming, 0)
                , daily_consumption) - 56                                   AS week_7_coverage
        FROM combined
                 JOIN final_intermediate
                      ON combined.article_code = final_intermediate.article_code
                 JOIN weeks_general_programming
                      ON combined.article_code = weeks_general_programming.article_code
        GROUP BY
            combined.article_code,
            final_intermediate.daily_consumption,
            available_stock,
            week_0_programming,
            week_1_programming,
            week_2_programming,
            week_3_programming,
            week_4_programming,
            week_5_programming,
            week_6_programming,
            week_7_programming
    ),

    weeks_general AS (
        SELECT
            wgc.article_code,
            wgp.week_0_programming
                + wgp.week_1_programming
                + wgp.week_2_programming
                + wgp.week_3_programming
                + wgp.week_4_programming
                + wgp.week_5_programming
                + wgp.week_6_programming
                + wgp.week_7_programming
                AS total_programming,

            wgc.week_0_coverage,
            wgp.week_0_programming,

            wgc.week_1_coverage,
            wgp.week_1_programming,

            wgc.week_2_coverage,
            wgp.week_2_programming,

            wgc.week_3_coverage,
            wgp.week_3_programming,

            wgc.week_4_coverage,
            wgp.week_4_programming,

            wgc.week_5_coverage,
            wgp.week_5_programming,

            wgc.week_6_coverage,
            wgp.week_6_programming,

            wgc.week_7_coverage,
            wgp.week_7_programming
        FROM weeks_general_coverage wgc
                 JOIN weeks_general_programming wgp
                      ON wgc.article_code = wgp.article_code
    ),

    checked AS (
        SELECT
            article_code,
            checked
        FROM brand_ian_po_po_check
        WHERE user_id = 1
    ),
    final_calculations AS (
        SELECT
            branch_id,
            fi.article_code,
            total_monthly_forecast  AS mean_forecast,
            available_stock,
            daily_consumption,
            CASE
                WHEN daily_consumption = 0 THEN 0
                ELSE available_stock / daily_consumption
                END AS coverage_without_production,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) < 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_positive,
            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN (120 - (available_stock / NULLIF(daily_consumption, 0))) > 0 THEN
                    - daily_consumption * (120 - (available_stock / NULLIF(daily_consumption, 0)))
                ELSE 0
                END AS need_negative,
            COALESCE(wg.total_programming, 0) * 1.0             AS total_programming,

            COALESCE(wg.week_0_programming, 0) * 1.0            AS week_0_programming,
            COALESCE(wg.week_0_coverage, 0) * 1.0               AS week_0_coverage,

            COALESCE(wg.week_1_programming, 0) * 1.0            AS week_1_programming,
            COALESCE(wg.week_1_coverage, 0) * 1.0               AS week_1_coverage,

            COALESCE(wg.week_2_programming, 0) * 1.0            AS week_2_programming,
            COALESCE(wg.week_2_coverage, 0) * 1.0               AS week_2_coverage,

            COALESCE(wg.week_3_programming, 0) * 1.0            AS week_3_programming,
            COALESCE(wg.week_3_coverage, 0) * 1.0               AS week_3_coverage,

            COALESCE(wg.week_4_programming, 0) * 1.0            AS week_4_programming,
            COALESCE(wg.week_4_coverage, 0) * 1.0               AS week_4_coverage,

            COALESCE(wg.week_5_programming, 0) * 1.0            AS week_5_programming,
            COALESCE(wg.week_5_coverage, 0) * 1.0               AS week_5_coverage,

            COALESCE(wg.week_6_programming, 0) * 1.0            AS week_6_programming,
            COALESCE(wg.week_6_coverage, 0) * 1.0               AS week_6_coverage,

            COALESCE(wg.week_7_programming, 0) * 1.0            AS week_7_programming,
            COALESCE(wg.week_7_coverage, 0) * 1.0               AS week_7_coverage,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) > 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_positive_with_production,

            CASE
                WHEN daily_consumption = 0 THEN 0
                WHEN - daily_consumption * (120 - wg.week_7_coverage) < 0 THEN
                    - daily_consumption * (120 - wg.week_7_coverage)
                ELSE 0
                END                                           AS need_negative_with_production,
            COALESCE(c.checked, FALSE) AS checked
        FROM final_intermediate fi
                 LEFT JOIN checked c ON fi.article_code = c.article_code
                 LEFT JOIN weeks_general wg
                           ON fi.article_code = wg.article_code
--                                %s
    )
SELECT
    COUNT(*)                                    AS total_rows,
    SUM(fc.mean_forecast)                       AS mean_forecast,
    SUM(fc.available_stock)                     AS available_stock,
    CASE
        WHEN SUM(fc.mean_forecast) = 0 THEN 0
        ELSE SUM(fc.available_stock) / (SUM(fc.mean_forecast) / 30)
        END AS coverage_without_production,
    SUM(fc.need_positive)                       AS need_positive,
    SUM(fc.need_negative)                       AS need_negative,
    SUM(fc.total_programming)                   AS total_programming,
    SUM(fc.week_0_programming)                  AS week_0_programming,
    COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) / (SUM(fc.mean_forecast) / 30) - 7                 AS week_0_coverage,
    SUM(fc.week_1_programming)                  AS week_1_programming,
    COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) / (SUM(fc.mean_forecast) / 30) - 14                AS week_1_coverage,
    SUM(fc.week_2_programming)                  AS week_2_programming,
    COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) / (SUM(fc.mean_forecast) / 30) - 21                AS week_2_coverage,
    SUM(fc.week_3_programming)                  AS week_3_programming,
    COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) / (SUM(fc.mean_forecast) / 30) - 28                AS week_3_coverage,
    SUM(fc.week_4_programming)                  AS week_4_programming,
    COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) / (SUM(fc.mean_forecast) / 30) - 35                AS week_4_coverage,
    SUM(fc.week_5_programming)                  AS week_5_programming,
    COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) / (SUM(fc.mean_forecast) / 30) - 42                AS week_5_coverage,
    SUM(fc.week_6_programming)                  AS week_6_programming,
    COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) / (SUM(fc.mean_forecast) / 30) - 49                AS week_6_coverage,
    SUM(fc.week_7_programming)                  AS week_7_programming,
    COALESCE(SUM(fc.available_stock), 0) + COALESCE((sum(fc.week_0_programming)), 0) + COALESCE((sum(fc.week_1_programming)), 0) + COALESCE((sum(fc.week_2_programming)), 0) + COALESCE((sum(fc.week_3_programming)), 0) + COALESCE((sum(fc.week_4_programming)), 0) + COALESCE((sum(fc.week_5_programming)), 0) + COALESCE((sum(fc.week_6_programming)), 0) + COALESCE((sum(fc.week_7_programming)), 0) / (SUM(fc.mean_forecast) / 30) - 56                AS week_7_coverage,
    SUM(fc.need_positive_with_production)        AS need_positive_with_production,
    SUM(fc.need_negative_with_production)        AS need_negative_with_production
FROM final_calculations fc INNER JOIN brand_ian_master_article a ON a.article_code = fc.article_code;