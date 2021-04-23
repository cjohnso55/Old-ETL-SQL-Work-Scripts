USE [Step_1]
GO
/*
CREATE TABLE #nodes(node int NOT NULL);
ALTER TABLE #nodes ADD CONSTRAINT PK_nodes PRIMARY KEY CLUSTERED (node);

CREATE TABLE #arcs(child_node int NOT NULL, parent_node int NOT NULL);
ALTER TABLE #arcs ADD CONSTRAINT PK_arcs PRIMARY KEY CLUSTERED (child_node, parent_node);

INSERT INTO #nodes(node)
VALUES (1), (2), (3), (4), (5), (6), (7);

INSERT INTO #arcs(child_node, parent_node)
VALUES (2, 3), (3, 4), (2, 6), (6, 7);
*/

WITH root_nodes
AS (
    -- Grab all the leaf nodes I care about
    SELECT NULL as child_node, n.node as parent_node
    FROM #nodes n
    WHERE n.node IN (1, 2)

    UNION ALL

    -- Grab all the parent nodes
    SELECT rn.parent_node as child_node, a.parent_node
    FROM root_nodes rn
        JOIN #arcs a
      ON rn.parent_node = a.child_node
)
SELECT *
FROM root_nodes rn
    LEFT JOIN #arcs a
  ON rn.parent_node = a.child_node
WHERE a.parent_node IS NULL