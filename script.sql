CREATE OR REPLACE PROCEDURE pg_temp.show_files_meta()
AS $$
DECLARE
    rec record;
BEGIN
    RAISE NOTICE 'No. | FILE# |  ANALYZE_TIME | STATUS | SIZE';
    RAISE NOTICE '----|-------|---------------|--------|------';

    FOR rec IN
        SELECT
            ROW_NUMBER() OVER (ORDER BY pg_catalog.pg_stat_get_last_analyze_time(c.oid)) AS "No.",  
            pg_relation_filepath(c.oid) AS "FILE#",
            pg_catalog.pg_stat_get_last_analyze_time(c.oid) AS "ANALYZE_TIME",
            CASE
                WHEN c.relpersistence = 'p' THEN 'PERMANENT'
                WHEN c.relpersistence = 't' THEN 'TEMPORARY'
                WHEN c.relpersistence = 'u' THEN 'UNLOGGED'
                ELSE 'ONLINE'
            END AS "STATUS",
            pg_size_pretty(pg_relation_size(c.oid)) AS "SIZE"
        FROM pg_class c
        WHERE c.relkind IN ('r', 't', 'm') AND c.relfilenode <> 0
        ORDER BY pg_catalog.pg_stat_get_last_analyze_time(c.oid)
        LIMIT 25
    LOOP
        RAISE NOTICE '% | % | % | % | %',
            rec."No.", rec."FILE#", rec."ANALYZE_TIME", rec."STATUS", rec."SIZE";
    END LOOP;
END
$$ LANGUAGE plpgsql;

CALL pg_temp.show_files_meta();

