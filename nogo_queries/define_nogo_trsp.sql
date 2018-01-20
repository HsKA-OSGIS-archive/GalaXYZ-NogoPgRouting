/* ========================================================================= */
/* ===== TRSP REGULAR DEFINITION =========================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_trsp(
	edges_sql TEXT,
	nogo_geom GEOMETRY,
	start_vid INTEGER,
	end_vid INTEGER,
	directed BOOLEAN,
	has_rcost BOOLEAN,
	restrictions_sql TEXT DEFAULT NULL
)

RETURNS SETOF pgr_costResult AS

$$
BEGIN

	DROP TABLE IF EXISTS edges_table;
	DROP TABLE IF EXISTS edges_table_nogo;

	/* Intercept the edges table that the pgr routing algorithm would normally work on, but make sure we have the geometry, too. */
	EXECUTE 'CREATE TEMPORARY TABLE edges_table AS (' || edges_sql || ');';

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
		IF restrictions_sql IS NULL THEN
		
			RETURN QUERY (
				SELECT * FROM pgr_trsp(
					'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo',
					start_vid,
					end_vid,
					directed,
					has_rcost
				)
			);
			
		/* IF restrctions_SQL IS NOT NULL */
		ELSE

			RETURN QUERY (
				SELECT * FROM pgr_trsp(
					'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo',
					start_vid,
					end_vid,
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
		IF restrictions_sql IS NULL THEN
		
			RETURN QUERY (
				SELECT * FROM pgr_trsp(
					'SELECT id, source, target, cost FROM edges_table_nogo',
					start_vid,
					end_vid,
					directed,
					has_rcost
				)
			);

		/* IF restrctions_SQL IS NOT NULL */
		ELSE

			RETURN QUERY (
				SELECT * FROM pgr_trsp(
					'SELECT id, source, target, cost FROM edges_table_nogo',
					start_vid,
					end_vid,
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
/* ===== TRSP WITH POS DEFINITION ========================================== */
/* ========================================================================= */

CREATE OR REPLACE FUNCTION pgr_nogo_trsp(
	sql TEXT,
	nogo_geom GEOMETRY,
	source_eid INTEGER,
	source_pos FLOAT8,
	target_eid INTEGER,
	target_pos FLOAT8,
	directed BOOLEAN,
	has_reverse_cost BOOLEAN,
	turn_restrict_sql TEXT DEFAULT NULL
)

RETURNS SETOF pgr_costResult AS

$$
BEGIN

	DROP TABLE IF EXISTS edges_table;
	DROP TABLE IF EXISTS edges_table_nogo;

	/* Intercept the edges table that the pgr routing algorithm would normally work on, but make sure we have the geometry, too. */
	EXECUTE 'CREATE TEMPORARY TABLE edges_table AS (' || sql || ');';

	IF has_reverse_cost IS TRUE THEN

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
				SELECT * FROM pgr_trsp(
					'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo',
					source_eid,
					source_pos,
					target_eid,
					target_pos,
					directed,
					has_reverse_cost
				)
			);
			
		/* IF restrctions_SQL IS NOT NULL */
		ELSE

			RETURN QUERY (
				SELECT * FROM pgr_trsp(
					'SELECT id, source, target, cost, reverse_cost FROM edges_table_nogo',
					source_eid,
					source_pos,
					target_eid,
					target_pos,
					directed,
					has_reverse_cost,
					turn_restrict_sql
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
				SELECT * FROM pgr_trsp(
					'SELECT id, source, target, cost FROM edges_table_nogo',
					source_eid,
					source_pos,
					target_eid,
					target_pos,
					directed,
					has_reverse_cost
				)
			);

		/* IF restrctions_SQL IS NOT NULL */
		ELSE

			RETURN QUERY (
				SELECT * FROM pgr_trsp(
					'SELECT id, source, target, cost FROM edges_table_nogo',
					source_eid,
					source_pos,
					target_eid,
					target_pos,
					directed,
					has_reverse_cost,
					turn_restrict_sql
				)
			);

		END IF;

	END IF;

END
$$
LANGUAGE plpgsql;

/* ========================================================================= */
/* ===== TRSP REGULAR TEST ================================================= */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trsp(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		2,
-- 		FALSE,
-- 		FALSE
-- 	);
-- 
-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trsp(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		2,
-- 		FALSE,
-- 		TRUE
-- 	);
-- 
-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trsp(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		2,
-- 		TRUE,
-- 		FALSE
-- 	);
-- 
-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trsp(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		2,
-- 		TRUE,
-- 		TRUE
-- 	);

/* ========================================================================= */
/* ===== TRSP WITH POS TEST ================================================ */
/* ========================================================================= */

-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trsp(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		0.5,
-- 		100,
-- 		0.5,
-- 		FALSE,
-- 		FALSE
-- 	);
-- 
-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trsp(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		0.5,
-- 		100,
-- 		0.5,
-- 		FALSE,
-- 		TRUE
-- 	);
-- 
-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trsp(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, reverse_cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		0.5,
-- 		100,
-- 		0.5,
-- 		TRUE,
-- 		TRUE
-- 	);
-- 
-- SELECT
-- 	*
-- FROM
-- 	pgr_nogo_trsp(
-- 		'SELECT gid::INTEGER AS id, source::INTEGER, target::INTEGER, cost, the_geom AS geom FROM ways',
-- 		(SELECT ST_Union(geom) FROM overwrite_poly),
-- 		1,
-- 		0.5,
-- 		100,
-- 		0.5,
-- 		TRUE,
-- 		FALSE
-- 	);