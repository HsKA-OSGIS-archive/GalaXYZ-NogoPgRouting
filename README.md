# Nogo Routing Functions for pgRouting

## Overview

This repository contains a series of wrapper functions for [pgRouting](http://pgrouting.org/) functions that enable supplying "nogo areas" into the routing algorithm.  This has the effect of completely excluding the intersecting network edges from the routing operation.  The "nogo areas" are supplied as an additional parameter to the function, which is designed to resemble the original pgRouting functions as closely as possible.  All available functions can be found in the `/nogo_queries` folder.  A respository for a website demonstrates the use of routing with nogo areas can be found [here](https://github.com/HsKA-OSGIS/GalaXYZ) (We hope to have it hosted soon!)

The functions have been developed for pgRouting v2.4.

## Adding functions to database

To make a function available, simply execute the contents of the desired nogo routing function found in `/nogo_queries` folder.  There are also some test cases commented out at the bottom of each definition query.  Once the query has been successfully executed, the function is available for use.

## Using the queries

An example is provided for the `pgr_Dijkstra` query.

The releveant nogo query for this one is `/nogo_queries/define_nogo_dijsktra`.  Run the contents of this query on your database to make this function available for use.

A simple example of `pgr_Dijkstra` looks like this:

    SELECT * FROM pgr_dijkstra(
        'SELECT id, source, target, cost, reverse_cost FROM edge_table',
        2, 3
    );

To "upgrade" this query to its new nogo counterpart, you must modify the `edges_sql` parameter to include the geometry column of your network dataset, and pass a new parameter just after (but before the rest of the parameters) as follows:

    SELECT * FROM pgr_nogo_dijkstra(
        'SELECT id, source, target, cost, reverse_cost, geom FROM edge_table',
        (SELECT ST_Union(geom) FROM nogo_table),
        2, 3
    );

All nogo queries follow this pattern: Add the network geometry column (if it isn't already there), then add a subquery returning geometries.  It is generally a good idea to union the geometries into one as seen above, sometimes it gets finnicky about overlapping geometries.

## Examples

The following are some examples comparing the results of various pgRouting algorithms and their nogo counterparts:

When comparing `pgr_drivingDistance` and `pgr_nogo_drivingDistance`, we can see that adding a nogo area changes how far the routing can extend.  The blue dots represent the nodes that can be reached in under a specified cost with no nogo restrictions.  The purple dots represent the same nodes that can be reached with nogo restrictions.

(img1)

When comparing `pgr_dijkstra` and `pgr_nogo_dijkstra`, we can see that adding a nogo area changes the route that gets returned by the algorithm.  The blue line represents the route that is taken with no nogo restrictions.  The purple route represents the route that is taken with a nogo restriction.

(img2)

## Credits

Credit must be given to the pgRouting team, who have designed such a great open source routing library, and provided help and insight during development.

These functions were developed as part of the class "Open Source GIS" at Hochschule Karlsruhe, with [Dr. Marco Lechner](https://www.researchgate.net/profile/Marco_Lechner) as instructor.

The group consisted of:

[Isaac Boates](https://www.linkedin.com/in/isaac-boates-338547100/)

[Rob Coppinger](https://www.linkedin.com/in/rob-coppinger-456b17103/)

[Anja Fürst](https://www.linkedin.com/in/anja-f%C3%BCrst-136899144/)

[Olumide Igbiloba](https://www.linkedin.com/in/olumide-igbiloba/)
