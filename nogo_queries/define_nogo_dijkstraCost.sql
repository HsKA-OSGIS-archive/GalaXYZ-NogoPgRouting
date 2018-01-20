/* ========================================================================= */
/* ===== DIJKSTRACOST 1 TO 1 DEFINITION ==================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_dijkstraCost(
	edges_sql TEXT,
	nogo_geom GEOMETRY,
	start_vid_in BIGINT,
    end_vid_in BIGINT,

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
		pgr_dijkstraCost(
			'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo;',
			start_vid_in,
			end_vid_in,
			directed
		)
);

END
$$
LANGUAGE plpgsql;


/* ========================================================================= */
/* ===== DIJKSTRACOST 1 TO N DEFINITION ==================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_dijkstraCost(
	edges_sql TEXT,
	nogo_geom GEOMETRY,
	start_vid_in BIGINT,
	end_vids ANYARRAY,

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
		pgr_dijkstraCost(
			'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo;',
			start_vid_in,
			end_vids,
			directed
		)
);

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== DIJKSTRACOST N TO 1 DEFINITION ==================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_dijkstraCost(
	edges_sql TEXT,
	nogo_geom GEOMETRY,
	start_vids ANYARRAY,
	end_vid_in BIGINT,

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
		pgr_dijkstraCost(
			'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo;',
			start_vids,
			end_vid_in,
			directed
		)
);

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== DIJKSTRACOST N TO M DEFINITION===================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_dijkstraCost(
	edges_sql TEXT,
	nogo_geom GEOMETRY,
	start_vids ANYARRAY,
	end_vids ANYARRAY,

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
		pgr_dijkstraCost(
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
/* ===== DIJKSTRACOST 1 TO 1 TEST ========================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_dijkstraCost(
-- 		'SELECT gid AS id, source, target, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		2,
--		TRUE
-- 	);

/* ========================================================================= */
/* ===== DIJKSTRACOST 1 TO N TEST ========================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_dijkstraCost(
-- 		'SELECT gid AS id, source, target, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		ARRAY[2,3],
-- 		TRUE
-- 	);

/* ========================================================================= */
/* ===== DIJKSTRACOST N TO 1 TEST ========================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_dijkstraCost(
-- 		'SELECT gid AS id, source, target, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		ARRAY[1,2],
-- 		3,
-- 		TRUE
-- 	);

/* ========================================================================= */
/* ===== DIJKSTRACOST N TO M TEST ========================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_dijkstraCost(
-- 		'SELECT gid AS id, source, target, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		ARRAY[1,2],
-- 		ARRAY[3,2],
-- 		TRUE
-- 	);
