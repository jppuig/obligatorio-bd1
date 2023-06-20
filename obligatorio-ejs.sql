-- Obligatorio
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY'; 

-- Ejericicio 1
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
SELECT DISTINCT su.nombreUsuario
FROM se_une su
WHERE su.nombreUsuario IN (
    -- Estan unidos a por lo menos 2 dos servidores
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

-- Ejercicio 4
SELECT s.nombre, s.descripcion
FROM servidor s
WHERE NOT EXISTS (
    SELECT 1 
    FROM usuario u
    WHERE u.pais IN ('URUGUAY', 'ARGENTINA')
    AND NOT EXISTS (
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
        -- Usuarios con mas mensajes contando todos los canales de un servidor
        SELECT m.nombreUsuario
        FROM canal c, mensaje m
        WHERE m.nombreCanal = c.nombreCanal
        GROUP BY c.nombreServidor, m.nombreUsuario
        HAVING count(m.nombreCanal) = (
            -- Maxima cantidad de mensajes mandados por usuario en un servidor
            SELECT MAX(count(1))
            FROM canal c, mensaje m
            WHERE m.nombreCanal = c.nombreCanal
            GROUP BY c.nombreServidor, m.nombreUsuario
            HAVING count(1) > 0
        )
    )
    AND su.nombreServidor IN (
        -- Servidores que tengan menos de 15 dias de creacion
    	SELECT s.nombre
    	FROM servidor s
    	WHERE s.fechaCreacion >= sysdate - 15
    )
);

-- Ejercicio 8
SELECT s.*
FROM servidor s
WHERE s.nombre IN (
    -- Servidores que tengan la maxima cantidad de canales con al menos un mensaje 
    SELECT c.nombreServidor
    FROM canal c
    WHERE EXISTS (
    		SELECT 1
			FROM mensaje m
    		WHERE c.nombreCanal = m.nombreCanal
        )
    GROUP BY c.nombreServidor
    HAVING count(c.nombreCanal) = (
        SELECT MAX(count(c1.nombreCanal))
        FROM canal c1
        GROUP BY c1.nombreServidor
    )
)
AND s.nombreUsuarioCreador IN ('PEDRO GONZALEZ', 'JUAN ORT');

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
WHERE UsuarioTotal = Usuario;