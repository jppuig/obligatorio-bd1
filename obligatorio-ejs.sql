ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY'; 

-- Obligatorio
-- Ejericicio 1
-- Los nombres de usuario que esten unidos al servidor SERVAPP y que no hayan mandado mensaje
SELECT su.nombreUsuario
FROM se_une su
WHERE su.nombreServidor = 'SERVAPP'
AND NOT EXISTS (
    SELECT 1
    FROM mensaje m, canal c
    WHERE su.nombreUsuario = m.nombreUsuario
    AND c.nombreCanal = m.nombreCanal
    AND c.tipo = 'Voz' AND c.nombreServidor = su.nombreServidor
);

-- Ejercicio 2
SELECT u1.nombreUsuario, u2.nombreUsuario
FROM usuario u1, usuario u2
WHERE u1.pais IN ('BRASIL', 'COLOMBIA', 'CHILE')
AND u2.pais IN ('BRASIL', 'COLOMBIA', 'CHILE')
AND u1.nombreUsuario > u2.nombreUsuario
AND EXISTS (
    SELECT 1
    FROM se_une su1, se_une su2
    WHERE EXISTS (
    	SELECT 1
    	FROM servidor s1, servidor s2
    	WHERE s1.nombre = su1.nombreServidor
    	AND s2.nombre = su2.nombreServidor
    	AND su1.nombreUsuario = u1.nombreUsuario
    	AND su2.nombreUsuario = u2.nombreUsuario
        AND s1.nombre = s2.nombre
    	AND s1.fechaCreacion >= '01/01/2021' AND s1.fechaCreacion <= '31/12/2022'
        AND s2.fechaCreacion >= '01/01/2021' AND s2.fechaCreacion <= '31/12/2022'
    )
);

-- Ejercicio 3
-- Muestra los nombres de usuario que estan unidos a mas de un servidor y existe al menos 
-- un mensaje de ellos en algun canal del servidor
SELECT DISTINCT su.nombreUsuario
FROM se_une su
WHERE su.nombreUsuario IN (
    -- Estan unidos a por lo menos 2 dos canales
    SELECT su1.nombreUsuario
    FROM se_une su1
    GROUP BY su1.nombreUsuario
    HAVING count(su1.nombreServidor) > 1
)
AND EXISTS (
    -- Existe al menos un mensaje del usuario en el servidor
    SELECT 1
    FROM canal c, mensaje m
    WHERE c.nombreCanal = m.nombreCanal
    AND c.nombreServidor = su.nombreServidor
    AND m.nombreUsuario = su.nombreUsuario
);

-- EMPIEZAN LOS 4

-- Ejercicio 4
-- Los servidores que no exista algun usuario de uruguay o argentina que no este unido
SELECT s.nombre, s.descripcion
FROM servidor s
WHERE NOT EXISTS (
    SELECT 1
    FROM usuario u
    WHERE u.pais IN ('URUGUAY', 'ARGENTINA')
    AND NOT EXISTS (
    	SELECT 1
    	FROM se_une su
        WHERE su.nombreServidor = s.nombre
        AND su.nombreUsuario = u.nombreUsuario
    )
)
INTERSECT
-- Los servidores que no tengan usuarios de uruguay o argentina que tengan mensajes
SELECT s.nombre, s.descripcion
FROM servidor s
WHERE NOT EXISTS (
    SELECT 1
    FROM usuario u
    WHERE u.pais IN ('URUGUAY', 'ARGENTINA')
    AND EXISTS (
		SELECT 1
    	FROM canal c, mensaje m
    	WHERE m.nombreUsuario = u.nombreUsuario
    	AND c.nombreServidor = s.nombre
        AND c.nombreCanal = m.nombreCanal
    )
);
-- La interseccion da los servidores que tegan a todos los usuarios de uruguay o argentina y que no hayan mandado mensajes

-- Servidores que tengan al menos un usuario del conjunto de abajo
SELECT s.nombre, s.descripcion
FROM servidor s
WHERE s.nombre IN (
    SELECT su.nombreServidor
    FROM se_une su
    WHERE su.nombreUsuario IN (
        -- Conjunto de uru o arg que no tengan msj en ningun servidor
        SELECT u.nombreUsuario 
        FROM usuario u
        WHERE u.pais IN ('URUGUAY', 'ARGENTINA')
        AND NOT EXISTS (
            SELECT 1
            FROM mensaje m
            WHERE m.nombreUsuario = u.nombreUsuario
        )
    )
);


SELECT s.nombre, s.descripcion
FROM servidor s
WHERE NOT EXISTS (
    SELECT 1 
    FROM usuario u
    WHERE u.pais IN ('URUGUAY', 'ARGENTINA')
    AND EXISTS (
        SELECT 1
        FROM mensaje m
        WHERE m.nombreUsuario = u.nombreUsuario
    )
    AND NOT EXISTS (
        SELECT 1
        FROM se_une su
        WHERE su.nombreUsuario = u.nombreUsuario
    )
);

-- Ejercicio 4
-- Todos los servidores que tengan a todos los usuarios de uruguay o argentina que no tengan mensajes en ningun servidor
SELECT s.nombre, s.descripcion
FROM servidor s
WHERE NOT EXISTS (
    SELECT 1 
    FROM usuario u
    WHERE u.pais IN ('URUGUAY', 'ARGENTINA')
    AND NOT EXISTS (
    -- Que no tengan mensajes??
        SELECT 1
        FROM mensaje m
        WHERE m.nombreUsuario = u.nombreUsuario
    )
    AND NOT EXISTS (
        SELECT 1
        FROM se_une su
        WHERE su.nombreUsuario = u.nombreUsuario
    	AND s.nombre = su.nombreServidor
    )
);


-- TERMINAN LOS 4


-- Ejercicio 5
SELECT s.nombreUsuarioCreador
FROM servidor s
WHERE s.fechaCreacion >= sysdate - 730 -- El menos funciona para los dias sino con exrtactYear
GROUP BY s.nombreUsuarioCreador 
HAVING count (s.nombre) > 0 
ORDER BY count(s.nombre) DESC
FETCH FIRST 3 ROWS ONLY;

-- Ejercicio 6
SELECT s.*
FROM servidor s
WHERE s.nombre IN (
    -- Servidores con menor cantidad de usuarios
    SELECT su1.nombreServidor
    FROM se_une su1
    GROUP BY su1.nombreServidor
    HAVING count(nombreUsuario) IN (
        SELECT MIN(count(su2.nombreUsuario))
        FROM se_une su2
        GROUP BY su2.nombreServidor
    )
)
AND s.nombre IN (
    -- Servidores con mas cantidad de canales
    SELECT c1.nombreServidor
    FROM canal c1
    GROUP BY c1.nombreServidor
    HAVING count(c1.nombreCanal) IN (
        SELECT MAX(count(c2.nombreCanal))
        FROM canal c2
        GROUP BY c2.nombreServidor
    )
)
-- Que tengan menos de un anio de antiguedad
AND s.fechaCreacion >= sysdate - 365;

-- Ejercicio 7
SELECT u.*
FROM usuario u
WHERE u.nombreUsuario IN (
    SELECT su.nombreUsuario
    FROM se_une su
    WHERE su.nombreUsuario IN (
        -- Devuelve el usuario con mas mensajes contando todos los canales de un servidor
        SELECT m.nombreUsuario
        FROM canal c, mensaje m
        WHERE m.nombreCanal = c.nombreCanal
        GROUP BY c.nombreServidor, m.nombreUsuario
        HAVING count(m.nombreCanal) = (
            -- Cuenta cantidad de mensajes mandados por usuario en cada servidor y devuelve el max
            SELECT MAX(count(m.nombreCanal))
            FROM canal c, mensaje m
            WHERE m.nombreCanal = c.nombreCanal
            GROUP BY c.nombreServidor, m.nombreUsuario
            HAVING count(m.nombreCanal) > 0
        )
    )
    AND su.nombreServidor IN (
        -- Devuelvo servidores que tengan menos de 15 dias de creacion
    	SELECT s.nombre
    	FROM servidor s
    	WHERE s.fechaCreacion >= sysdate - 15
    )
);

-- Ejercicio 8
SELECT * 
-- Devuelve servidores con mayor cantidad de canales
FROM servidor s1
WHERE s1.nombre IN (
    SELECT c.nombreServidor
    FROM canal c
    GROUP BY c.nombreServidor
    HAVING count(c.nombreCanal) = (
    	-- Devuelve mayor cantidad de canales en un servidor
    	SELECT MAX(count(c1.nombreCanal))
    	FROM canal c1
    	GROUP BY c1.nombreServidor
    )
)
INTERSECT
-- Devuelve servidores creados por Pedro Gonzalez o Juan ORT
SELECT *
FROM servidor s2
WHERE s2.nombreUsuarioCreador IN ('PEDRO GONZALEZ', 'JUAN ORT')
INTERSECT
-- Devuelve servidores con mensajes
SELECT *
FROM servidor s3
WHERE s3.nombre IN (
    SELECT c.nombreServidor
    FROM canal c
    WHERE EXISTS (
    	SELECT 1
    	FROM mensaje m
    	WHERE m.nombreCanal = c.nombreCanal
    )
);

-- Ejercicio 9
SELECT nomServidor AS "Nombre del servidor", ROUND ((CantMsjServ / CantUsuServ), 2) AS "Promedio de mensajes por servidor"
FROM (
    -- Cantidad usuarios por servidor
    SELECT su.nombreServidor AS nomServidor, count(su.nombreUsuario) AS CantUsuServ
    FROM se_une su
    GROUP BY su.nombreServidor
), (
    -- Cant msj por servidor
    SELECT c.nombreServidor AS nombreServ, count(*) AS CantMsjServ
    FROM mensaje m, canal c
    WHERE m.nombreCanal = c.nombreCanal
    GROUP BY c.nombreServidor
)
WHERE nombreServ = nomServidor;

-- Ejercicio 10
SELECT Usuario AS "Usuario", Canal as "Canal", CantMsjs AS "CantMsjs", ROUND((CantMsjs / CantTotal) * 100, 2) AS "Porcentaje", UsuarioMax AS "UsuMasMsjs"
FROM (
    -- Usuarios en cada canal cuantos mensajes
    SELECT m.nombreUsuario AS Usuario, m.nombreCanal AS Canal, count(m.numero) AS CantMsjs
    FROM mensaje m
    GROUP BY m.nombreUsuario, m.nombreCanal
), (
    -- Usuario/s con mas cantidad de mensaje
    SELECT m1.nombreUsuario AS UsuarioMax
    FROM mensaje m1
    GROUP BY m1.nombreUsuario
    HAVING count(m1.numero) = (
        -- Mayor cantidad de mensajes por un usuario
        SELECT MAX(count(m2.numero))
        FROM mensaje m2
        GROUP BY m2.nombreUsuario
    )
), (
    -- Cantidad de mensajes por usuarios
    SELECT m.nombreUsuario AS UsuarioTotal, count(m.numero) AS CantTotal
    FROM mensaje m
    GROUP BY m.nombreUsuario
    HAVING count(m.numero) > 0
)
WHERE UsuarioTotal = Usuario