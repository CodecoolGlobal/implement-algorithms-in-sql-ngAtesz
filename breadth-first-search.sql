-- SQL statements that are used to define the breadth-first search function
-- Include all your tried solutions in the SQL file
-- with commenting below the functions the execution times on the tested dictionaries.

SELECT *
FROM person p
    LEFT JOIN friend_request fr ON p.id = fr.sender OR p.id = fr.receiver
WHERE p.first_name = 'Tuure'
    AND fr.status = 'accepted';

SELECT *
FROM person
WHERE id IN (
    SELECT sender FROM friend_request WHERE receiver = 11 AND status = 'accepted'
    UNION ALL
    SELECT receiver FROM friend_request WHERE sender = 11 AND status = 'accepted'
    );

WITH RECURSIVE transitive_closure(a, b, distance, path_string) AS
    (
        SELECT sender AS a,
               receiver AS b,
               1 AS distance,
               sender || '.' || receiver || '.' AS path_string
        FROM friend_request
        WHERE status = 'accepted'

        UNION ALL

        SELECT tc.a,
               fr.receiver AS b,
               tc.distance + 1,
               tc.path_string || '.' || fr.receiver || '.' AS path_string
        FROM friend_request AS fr
            JOIN transitive_closure AS tc ON fr.sender = tc.b
        WHERE fr.status = 'accepted'
              AND tc.path_string NOT LIKE '%' || fr.receiver || '.%'
    )
SELECT *
FROM transitive_closure
ORDER BY a,b,distance;

DROP VIEW IF EXISTS accepted_friend_request;

CREATE VIEW accepted_friend_request (a, b) AS
    (
    SELECT sender, receiver FROM friend_request WHERE status = 'accepted'
    UNION ALL
    SELECT receiver, sender FROM friend_request WHERE status = 'accepted'
    );

-- non-directed graph
WITH RECURSIVE transitive_closure(a, b, distance, path_string) AS
( SELECT  a,
        b,
        1 AS distance,
        a || '.' || b || '.' AS path_string
  FROM accepted_friend_request

  UNION ALL

  SELECT tc.a,
        e.b,
        tc.distance + 1,
        tc.path_string || e.b || '.' AS path_string
  FROM accepted_friend_request AS e
    JOIN transitive_closure AS tc ON e.a = tc.b
  WHERE tc.path_string NOT LIKE '%' || e.b || '.%'
)
SELECT * FROM transitive_closure
WHERE a = 11
    AND distance < 3
ORDER BY a, b, distance;
