/* ========================================================================= */
/* ===== JOHNSON DEFINITION ======================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_johnson(
	edges_sql TEXT,
	nogo_geom GEOMETRY,
	directed BOOLEAN DEFAULT TRUE,

	OUT start_vid BIGINT,
	OUT end_vid BIGINT,
	OUT agg_cost float
)

RETURNS SETOF RECORD AS

$$
BEGIN

DROP TABLE IF EXISTS edges_table;
DROP TABLE IF EXISTS edges_table_nogo;

/* Intercept the edges table that the pgr routing algorithm would normally work on, but make sure we have the geometry, too. */
EXECUTE 'CREATE TEMPORARY TABLE edges_table AS (' || edges_sql || ');';

/* Replace the cost columns with infinity where the geom intersects the nogo geom. */
CREATE TEMPORARY TABLE
	edges_table_nogo
AS (
	SELECT
		edges_table.source AS source,
		edges_table.target AS target,
		edges_table.cost AS cost
	FROM
		edges_table
	WHERE
		NOT ST_Intersects(nogo_geom, edges_table.geom)

	UNION ALL

	SELECT
		edges_table.source AS source,
		edges_table.target AS target,
		'INFINITY' AS cost
	FROM
		edges_table
	WHERE
		ST_Intersects(nogo_geom, edges_table.geom)

);

/* Now run the pgr routing algorithm on the updated table & return the result. */
RETURN QUERY (
	SELECT
		*
	FROM
		pgr_johnson(
			'SELECT source, target, cost FROM edges_table_nogo;',
			directed
		)
);

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== JOHNSON TEST ============================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_johnson(
-- 		'SELECT source, target, cost, the_geom AS geom FROM ways where gid < 5',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		FALSE
-- 	);