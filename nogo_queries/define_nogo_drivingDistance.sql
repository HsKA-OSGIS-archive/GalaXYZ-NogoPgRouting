/* ========================================================================= */
/* ===== DRIVINGDISTANCE N VIDS DEFINITION ================================= */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_drivingDistance(
	edges_sql text,
	nogo_geom GEOMETRY,
	start_vids anyarray,
	distance FLOAT,
	directed BOOLEAN DEFAULT TRUE,
	equicost BOOLEAN DEFAULT FALSE,
	
	OUT seq integer,
	OUT from_v bigint,
	OUT node bigint,
	OUT edge bigint,
	OUT cost FLOAT,
	OUT agg_cost FLOAT     
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
		edges_table.id AS id,
		edges_table.source AS source,
		edges_table.target AS target,
		edges_table.cost AS cost,
		edges_table.reverse_cost AS reverse_cost
	FROM
		edges_table
	WHERE
		NOT ST_Intersects(nogo_geom, edges_table.geom)

	UNION ALL

	SELECT
		edges_table.id AS id,
		edges_table.source AS source,
		edges_table.target AS target,
		'INFINITY' AS cost,
		'INFINITY' AS reverse_cost
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
		pgr_drivingDistance(
		'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo;',
		start_vids,
		distance,
		directed,
		equicost
	)
);

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== DRIVINGDISTANCE 1 VID DEFINITION ================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_drivingDistance(
	edges_sql text,
	nogo_geom GEOMETRY,
	start_vid BIGINT,
	distance FLOAT8,
	directed BOOLEAN DEFAULT TRUE,
	
	OUT seq integer,
	OUT node bigint,
	OUT edge bigint,
	OUT cost FLOAT,
	OUT agg_cost FLOAT     
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
		edges_table.id AS id,
		edges_table.source AS source,
		edges_table.target AS target,
		edges_table.cost AS cost,
		edges_table.reverse_cost AS reverse_cost
	FROM
		edges_table
	WHERE
		NOT ST_Intersects(nogo_geom, edges_table.geom)

	UNION ALL

	SELECT
		edges_table.id AS id,
		edges_table.source AS source,
		edges_table.target AS target,
		'INFINITY' AS cost,
		'INFINITY' AS reverse_cost
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
		pgr_drivingDistance(
		'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo;',
		start_vid,
		distance,
		directed
	)
);

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== DRIVINGDISTANCE N VIDS TEST ======================================= */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_drivingDistance(
-- 		'SELECT gid as id, source, target, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		ARRAY[59161, 59162],
-- 		0.1,
-- 		TRUE,
-- 		FALSE
-- 	);

/* ========================================================================= */
/* ===== DRIVINGDISTANCE 1 VID TEST ======================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_drivingDistance(
-- 		'SELECT gid as id, source, target, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		59161,
-- 		0.1,
-- 		TRUE
-- 	);