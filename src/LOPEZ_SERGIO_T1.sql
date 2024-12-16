-- tablas

-- director
CREATE TABLE Director (
    codigo INTEGER PRIMARY KEY,  -- Clave primaria director 
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    tipo VARCHAR(9) CHECK (Tipo IN ('Principal', 'Suplente')),
    fecha_nac DATE NOT NULL
);

-- pelicula
CREATE TABLE Pelicula (
    titulo VARCHAR(30) PRIMARY KEY,  -- Clave primaria pelicula
    sinopsis TEXT,
    pais_produccion VARCHAR(100),      
    genero VARCHAR(50),                
    codigo INTEGER NOT NULL,               
    FOREIGN KEY (codigo) REFERENCES Director(codigo) 
);

-- version
CREATE TABLE Version (
    codigo_v INTEGER PRIMARY KEY, -- clave primaria de version
    titulo_p VARCHAR(30), -- clave foranea de version
    año DATE NOT NULL,
    idioma VARCHAR(15) NOT NULL, 
    FOREIGN KEY (titulo_p) REFERENCES Pelicula(titulo),
);

-- ejemplar
CREATE TABLE Ejemplar (
    numero INTEGER, -- discriminante
    codigo_v INTEGER NOT NULL, -- clave primaria de la entidad con la que se relaciona (Version)
    formato VARCHAR(20),
    observaciones TEXT,
    PRIMARY KEY (numero, codigo_v),
    FOREIGN KEY (codigo_v) REFERENCES Version(codigo_v)
);

-- usuario
CREATE TABLE Usuario (
    cedula INTEGER PRIMARY KEY, -- clave primaria de Usuario
    nombre VARCHAR(20) NOT NULL,
    apellido VARCHAR(20) NOT NULL,
    telf VARCHAR(20)
);

-- accede
CREATE TABLE Accede (
    cedula INTEGER NOT NULL, -- clave primaria de usuario
    numero INTEGER NOT NULL, -- discriminante de ejemplar
    codigo_v INTEGER NOT NULL, -- clave primaria de Version, con quien Ejemplar se relaciona
    fecha_acceso DATE NOT NULL,
    fecha_terminacion DATE,
    PRIMARY KEY (cedula, numero, codigo_v), -- clave primaria de la relacion accede
    FOREIGN KEY (cedula) REFERENCES Usuario(cedula), -- clave foranea de usuario
    FOREIGN KEY (numero, codigo_v) REFERENCES Ejemplar(numero, codigo_v) -- clave foranea de ejemplar
);

-- Insercion de datos

-- director
INSERT INTO Director (codigo, nombre, apellido, tipo, fecha_nac) VALUES
(26272957, 'Sergillo', 'El Pillo', 'Principal', '1998-06-26'),
(45454545, 'Gabriela', 'Maluenga', 'Suplente', '1998-04-31'),
(6052785, 'Xavier', 'Lopez', 'Principal',  '1962-07-16');

-- pelicula
INSERT INTO Pelicula (titulo, sinopsis, pais_produccion, genero, codigo)
VALUES
    ('La Venganza del Queso', 
     'Un científico accidentalmente otorga vida al queso, desatando el caos en su ciudad.', 
     'Francia', 
     'Comedia', 
     26272957), -- relacionada con director: Sergillo El Pillo

    ('El Aguacate Valiente', 
     'Un aguacate rebelde lucha contra un tostador industrial para salvar su semilla.', 
     'México', 
     'Aventura', 
     45454545), -- relacionada con director: Gabriela Maluenga

    ('Mi Lavadora y Yo', 
     'Una lavadora con inteligencia artificial desarrolla una conexión emocional con su dueño.', 
     'Japón', 
     'Romance', 
     6052785); -- relacionada con director Xavier Lopez


-- version
INSERT INTO Version (codigo_v, titulo_p, año, idioma)
VALUES
    (1, 'La Venganza del Queso', '2022-05-15', 'Francés'),  
    (2, 'La Venganza del Queso', '2023-01-10', 'Inglés'),   
    (3, 'El Aguacate Valiente', '2021-11-20', 'Español'),  
    (4, 'El Aguacate Valiente', '2022-06-05', 'Portugués'), 
    (5, 'Mi Lavadora y Yo', '2023-08-30', 'Japonés'),      
    (6, 'Mi Lavadora y Yo', '2024-02-14', 'Inglés');     

-- ejemplar
INSERT INTO Ejemplar (numero, codigo_v, formato, observaciones)
VALUES
    (1, 1, 'fisico', 'Edición coleccionista con escenas eliminadas'),  
    (2, 1, 'digital', 'Incluye subtítulos en inglés y comentarios del director'),  
    (1, 2, 'fisico', 'Disponible en plataformas de streaming'),  
    (1, 3, 'digital', 'Versión original en español con entrevistas'), 
    (2, 3, 'fisico', 'Versión estándar sin extras'),  
    (1, 5, 'digital', 'Incluye banda sonora y arte conceptual'),
    (2, 5, 'fisico', 'Edición con caja metálica de colección'); 

-- usuario
INSERT INTO Usuario (cedula, nombre, apellido, telf)
VALUES
    (1001, 'Ana', 'Tejoporlas', '555-1234'),        
    (1002, 'Rosa', 'Melcacho', '555-5678'),         
    (1003, 'Esteban', 'Dido', '555-9101'),          
    (1004, 'Elsa', 'Pato', '555-1122'),             
    (1005, 'Armando', 'Bronca', '555-3344'),        
    (1006, 'Susana', 'Oria', '555-5566'),           
    (1007, 'Dolores', 'Delano', '555-7788'),        
    (1008, 'Paco', 'Tilla', '555-9900');  

-- accede
INSERT INTO Accede (cedula, numero, codigo_v, fecha_acceso, fecha_terminacion)
VALUES
    (2001, 1, 1, '2024-01-10', '2024-01-12'),  
    (2002, 2, 1, '2024-01-11', NULL),         
    (2003, 1, 3, '2024-02-05', '2024-02-07'), -- Aitor Tilla accedió al Ejemplar 1 de El Aguacate Valiente en español
    (2004, 1, 5, '2024-03-01', '2024-03-03'), 
    (2005, 2, 5, '2024-03-02', NULL);   

-- procedemos con crear la vista V_PELICULAS

CREATE VIEW V_PELICULAS AS
SELECT 
    p.titulo AS Pelicula_titulo,
    p.sinopsis,
    v.año AS Version_año,
    v.idioma, 
    d.nombre AS Director_nombre,
    d.apellido AS Director_apellido,
    e.numero AS ejemplar_numero,
    e.formato AS ejemplar_formato,
    u.nombre AS usuario_nombre,
    u.apellido AS usuario_apellido,
    a.fecha_acceso,
    a.fecha_terminacion
FROM 
    Pelicula p
JOIN  Director d ON p.codigo = d.codigo  -- Relación entre Pelicula y Director
JOIN Version v ON p.titulo = v.titulo_p  -- Relación entre Pelicula y Version
JOIN Ejemplar e ON v.codigo_v = e.codigo_v  -- Relación entre Version y Ejemplar
LEFT JOIN Accede a ON e.numero = a.numero AND e.codigo_v = a.codigo_v  -- Relación entre Ejemplar y Accede
LEFT JOIN Usuario u ON a.cedula = u.cedula  -- Relación entre Usuario y Accede
ORDER BY p.titulo, v.año, e.numero;

CREATE VIEW V_PELICULAS AS
SELECT 
    p.titulo,                      
    p.sinopsis,                    
    v.año,                         
    v.idioma,                      
    d.nombre AS director_nombre,   
    d.apellido AS director_apellido, 
    e.formato,                     
    e.observaciones,               
    u.nombre AS usuario_nombre,    
    u.apellido AS usuario_apellido, 
    a.fecha_acceso,                
    a.fecha_terminacion            
FROM Pelicula p
JOIN Director d ON p.codigo = d.codigo              -- Relación de director con película
JOIN Version v ON p.titulo = v.titulo_p             -- Relación de película con versión
JOIN Ejemplar e ON v.codigo_v = e.codigo_v         -- Relación de versión con ejemplar
JOIN Accede a ON e.numero = a.numero AND e.codigo_v = a.codigo_v  -- Relación de ejemplar con acceso
JOIN Usuario u ON a.cedula = u.cedula;      


-- ahora creamos la restriccion para prevenir que un usuario acceda a la misma pelicula en formato fisico o digital

CREATE OR REPLACE FUNCTION multiple_format_restriction()
RETURNS TRIGGER AS $$
BEGIN

    IF EXISTS (
        SELECT 1
        FROM Accede a
        JOIN Ejemplar e ON a.numero = e.numero AND a.codigo_v = e.codigo_v
        WHERE a.cedula = NEW.cedula
        AND e.formato != NEW.formato  -- Verifica que el formato sea diferente
        AND EXISTS (
            SELECT 1 
            FROM Version v 
            WHERE v.titulo_p = NEW.titulo_p 
            AND v.codigo_v = NEW.codigo_v
        )
    ) THEN
        RAISE EXCEPTION 'El usuario ya ha accedido en un formato diferente a esta pelicula';
    END IF;
    
    -- Permitir la inserción si no se encuentra ninguna violación
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER multiple_format_restriction
BEFORE INSERT ON Accede
FOR EACH ROW
EXECUTE FUNCTION multiple_format_restriction();


-- hagamos las actualizaciones de las tablas



