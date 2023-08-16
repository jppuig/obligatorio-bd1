# Obligatorio 2 - Base de datos 1

## Considerando el siguiente esquema relacional relacionado Discord y el subsistema de mensajería:

 Usuario (nombreUsuario, pais, correoElectronico, fechaRegistro, clave)
Clave primaria = {nombreUsuario}
Clave alterna = {correoElectronico}

Almacena los datos de los usuarios.

Servidor (nombre, descripcion, nombreUsuarioCreador, fCreac)

Clave primaria = {nombre}
ΠnombreUsuarioCreador (Servidor) ⊆ ΠnombreUsuario (Usuario)

Almacena los datos de los servidores incluyendo el usuario creador y la fecha de creación.

Se_une (nombreUsuario, nombre)
Clave primaria = {nombreUsuario, nombre}
ΠnombreUsuario (Se_une) ⊆ ΠnombreUsuario (Usuario)
Πnombre (Se_une) ⊆ Πnombre (Servidor)

Almacena los usuarios que se unieron a un servidor

Canal (nombre, tipo, desc, nombreServ)
Clave primaria = {nombre}
ΠnombreServ (Canal) ⊆ Πnombre (Servidor)
Dom(tipo) = {‘Texto’, ‘Voz’}

Almacena los datos de los canales de un servidor. Los canales son creados por el usuario creador del servidor.

Mensaje (nombreCanal, numero, contenido, nombreUsuario, fechaEnvio)

Clave primaria = {nombre, numero}
ΠnombreCanal (Mensaje) ⊆ Πnombre (Canal)
ΠnombreUsuario (Mensaje) ⊆ ΠnombreUsuario (Usuario)

Almacena los mensajes enviados a los canales por parte de los usuarios.

## Se pide:

### Resolver en álgebra relacional y SQL las siguientes consultas:

#### 1) Mostrar el nombre de los usuarios que se unieron al servidor “ServAPP” y que nunca enviaron mensajes a ningún canal de tipo “Voz” de dicho servidor.

#### 2) Listar los nombres de las parejas de usuarios de “Brasil”, “Colombia” y “Chile” que se hayan unido al menos a un servidor en común. Considerar los servidores que se hayan creado entre 2021 y 2022.

### Resolver en álgebra relacional, cálculo relacional de tuplas y SQL las siguientes consultas:

#### 3) Listar los usuarios que se unieron a más de un servidor. Considerar únicamente los usuarios que hayan mandado por lo menos un mensaje.

#### 4) Mostrar el nombre y la descripción de los servidores a los que todos los usuarios de “Uruguay” o “Argentina” se hayan unido, sin haber enviado ningún mensaje.

### Resolver en SQL las siguientes consultas:

#### 5) Mostrar los nombres de los usuarios que lideran en la creación de canales, limitando la lista a los tres que hayan creado la mayor cantidad de canales y que pertenezcan a servidores con menos de dos años de antigüedad.

#### 6) Listar la información de los servidores que cumplan con dos condiciones: ser los que tengan la menor cantidad de usuarios y la mayor cantidad de canales, y haber sido creados en el último año. Si hay varios servidores que satisfacen estas condiciones, mostrar todos ellos.

#### 7) Mostrar los datos de los usuarios que hayan enviado la mayor cantidad de mensajes en todos los canales de los servidores creados en los últimos 15 días. Se deben considerar tanto los mensajes enviados en canales públicos como privados. Si hay más de un usuario que cumpla con la condición, se deben listar todos ellos.

#### 8) Listar los servidores con la mayor cantidad de canales. Considerar aquellos canales que tengan mensajes y los servidores que hayan sido creados por “Pedro González” y “Juan ORT”.

#### 9) Obtener el nombre y el promedio de mensajes enviados por los usuarios en cada servidor.

#### 10) Obtener para cada usuario la cantidad de mensajes que envió en cada canal. Obtener el porcentaje que representa dicha cantidad sobre el total general de mensajes enviados (considerando todos los canales). Además, obtener el nombre del usuario que envío la mayor cantidad de mensajes (considerando todos los canales), si hay más de un usuario que envió la mayor cantidad de mensajes, se deben mostrar todos ellos.

Esquema de resultado esperado para la consulta 10:

```
Usuario Canal CantMsjs Porcentaje UsuMasMsjs
Juan TopGames 10 20 Juan
Ana TopGames 15 30 Juan
Juan Beta 25 50 Juan
```
## IMPORTANTE: En la resolución de las consultas SQL hasta la número 8 inclusive, no se permite hacer subconsultas en la cláusula FROM.
