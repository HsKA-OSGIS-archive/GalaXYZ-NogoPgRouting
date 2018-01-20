﻿/* ========================================================================= */
/* ===== DIJKSTRA 1 TO 1 DEFINITION ======================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_dijkstra(
	edges_sql TEXT,
	nogo_geom GEOMETRY,
	start_vid BIGINT,
	end_vid BIGINT,
	directed BOOLEAN,

	OUT seq integer,
	OUT path_seq integer,
	OUT node BIGINT,
	OUT edge BIGINT,
	OUT cost float,
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
		pgr_dijkstra(
			'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo;',
			start_vid,
			end_vid,
			directed
		)
);

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== DIJKSTRA 1 TO N DEFINITION ======================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_dijkstra(
	edges_sql TEXT,
	nogo_geom GEOMETRY,
	start_vid BIGINT,
	end_vids ANYARRAY,
	directed BOOLEAN,

	OUT seq integer,
	OUT path_seq integer,
	OUT end_vid BIGINT,
	OUT node BIGINT,
	OUT edge BIGINT,
	OUT cost float,
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
		pgr_dijkstra(
			'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo;',
			start_vid,
			end_vids,
			directed
		)
);

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== DIJKSTRA N TO 1 DEFINITION ======================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_dijkstra(
	edges_sql TEXT,
	nogo_geom GEOMETRY,
	start_vids ANYARRAY,
	end_vid BIGINT,
	directed BOOLEAN,

	OUT seq integer,
	OUT path_seq integer,
	OUT start_vid BIGINT,
	OUT node BIGINT,
	OUT edge BIGINT,
	OUT cost float,
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
		pgr_dijkstra(
			'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo;',
			start_vids,
			end_vid,
			directed
		)
);

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== DIJKSTRA N TO M DEFINITION========================================= */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_dijkstra(
	edges_sql TEXT,
	nogo_geom GEOMETRY,
	start_vids ANYARRAY,
	end_vids ANYARRAY,
	directed BOOLEAN,

	OUT seq integer,
	OUT path_seq integer,
	OUT start_vid BIGINT,
	OUT end_vid BIGINT,
	OUT node BIGINT,
	OUT edge BIGINT,
	OUT cost float,
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
		pgr_dijkstra(
			'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo;',
			start_vids,
			end_vids,
			directed
		)
);

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== DIJKSTRA 1 TO 1 TEST ============================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_dijkstra(
-- 		'SELECT gid AS id, source, target, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		2,
-- 		TRUE
-- 	);

/* ========================================================================= */
/* ===== DIJKSTRA 1 TO N TEST ============================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_dijkstra(
-- 		'SELECT gid AS id, source, target, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		ARRAY[2,3],
-- 		TRUE
-- 	);
	
/* ========================================================================= */
/* ===== DIJKSTRA N TO 1 TEST ============================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_dijkstra(
-- 		'SELECT gid AS id, source, target, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		ARRAY[1,2],
-- 		3,
-- 		TRUE
-- 	);

/* ========================================================================= */
/* ===== DIJKSTRA N TO M TEST ============================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_dijkstra(
-- 		'SELECT gid AS id, source, target, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		ARRAY[1,2],
-- 		ARRAY[3,2],
-- 		TRUE
-- 	);
