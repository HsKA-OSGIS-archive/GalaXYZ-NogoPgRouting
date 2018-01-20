/* ========================================================================= */
/* ===== TRSP VIA EDGES DEFINITION ========================================= */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_trspViaEdges(
	sql TEXT,
	nogo_geom GEOMETRY,
	eids INTEGER[],
	pcts FLOAT[],
	directed BOOLEAN,
	has_rcost BOOLEAN,
	turn_restrict_sql TEXT DEFAULT NULL::TEXT
)

RETURNS SETOF pgr_costResult3 AS

$$
BEGIN

	DROP TABLE IF EXISTS edges_table;
	DROP TABLE IF EXISTS edges_table_nogo;

	/* Intercept the edges table that the pgr routing algorithm would normally work on, but make sure we have the geometry, too. */
	EXECUTE 'CREATE TEMPORARY TABLE edges_table AS (' || sql || ');';

	IF has_rcost IS TRUE THEN

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
		IF turn_restrict_sql IS NULL THEN
		
			RETURN QUERY (
				SELECT * FROM pgr_trspViaEdges(
					'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo',
					eids,
					pcts,
					directed,
					has_rcost
				)
			);
			
		/* IF restrctions_sql IS NOT NULL */
		ELSE

			RETURN QUERY (
				SELECT * FROM pgr_trspViaEdges(
					'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo',
					eids,
					pcts,
					directed,
					has_rcost,
					restrictions_sql
				)
			);

		END IF;
		
	/* IF has_rcost IS FALSE */
	ELSE

		/* Replace the cost columns with infinity where the geom intersects the nogo geom. */
		CREATE TEMPORARY TABLE
			edges_table_nogo
		AS (
			SELECT
				edges_table.id AS id,
				edges_table.source AS source,
				edges_table.target AS target,
				edges_table.cost AS cost
			FROM
				edges_table
			WHERE
				NOT ST_Intersects(nogo_geom, edges_table.geom)
				
			UNION ALL

			SELECT
				edges_table.id AS id,
				edges_table.source AS source,
				edges_table.target AS target,
				'INFINITY' AS cost
			FROM
				edges_table
			WHERE
				ST_Intersects(nogo_geom, edges_table.geom)

		);

		/* Now run the pgr routing algorithm on the updated table & return the result. */
		IF turn_restrict_sql IS NULL THEN
		
			RETURN QUERY (
				SELECT * FROM pgr_trspViaEdges(
					'SELECT id, source, target, cost FROM edges_table_nogo',
					eids,
					pcts,
					directed,
					has_rcost
				)
			);

		/* IF restrctions_SQL IS NOT NULL */
		ELSE

			RETURN QUERY (
				SELECT * FROM pgr_trspViaEdges(
					'SELECT id, source, target, cost FROM edges_table_nogo',
					eids,
					pcts,
					directed,
					has_rcost,
					restrictions_sql
				)
			);

		END IF;

	END IF;

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== TRSP VIA EDGES TEST =============================================== */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trspViaEdges(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		ARRAY[1,10,50,150],
-- 		ARRAY[0.5,0.5,0.5,0.5]::FLOAT[],
-- 		FALSE,
-- 		FALSE
-- 	);
-- 	
-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trspViaEdges(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		ARRAY[1,10,50,150],
-- 		ARRAY[0.5,0.5,0.5,0.5]::FLOAT[],
-- 		FALSE,
-- 		TRUE
-- 	);
-- 
-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trspViaEdges(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		ARRAY[1,10,50,150],
-- 		ARRAY[0.5,0.5,0.5,0.5]::FLOAT[],
-- 		TRUE,
-- 		FALSE
-- 	);
-- 
-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trspViaEdges(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		ARRAY[1,10,50,150],
-- 		ARRAY[0.5,0.5,0.5,0.5]::FLOAT[],
-- 		TRUE,
-- 		TRUE
-- 	);