/*
mysql -u root -p

CREATE USER 'proyecto_food_rider'@'localhost' IDENTIFIED BY 'proyecto_food_rider';
GRANT ALL PRIVILEGES ON proyecto_food_rider.* TO 'proyecto_food_rider'@'localhost' WITH GRANT OPTION;
Flush privileges
*/

DROP DATABASE IF EXISTS proyecto_food_rider;
CREATE DATABASE IF NOT EXISTS proyecto_food_rider;
USE proyecto_food_rider;

-- Empezamos a crear tablas

CREATE TABLE UsuariosNoAceptado (
    id_usuario_no_aceptado INT AUTO_INCREMENT PRIMARY KEY,
    nick VARCHAR(100) NOT NULL UNIQUE,
    contrasenia VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    tipo VARCHAR(20) NOT NULL
);

CREATE TABLE EmpresasClienteNoAceptado (
    id_empresa_cliente_no_aceptada INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa_cliente VARCHAR(255) NOT NULL UNIQUE,
    cif VARCHAR(100) UNIQUE,
    direccion VARCHAR(255) NOT NULL UNIQUE,
    id_usuario_no_aceptado INT,
    FOREIGN KEY (id_usuario_no_aceptado) 
        REFERENCES UsuariosNoAceptado(id_usuario_no_aceptado)
        ON DELETE CASCADE
);


-- Tabla Usuarios
CREATE TABLE Usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nick VARCHAR(100) NOT NULL UNIQUE,
    contrasenia VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    tipo VARCHAR(20) NOT NULL
);

CREATE TABLE EmpresasCliente (
    id_empresa_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa_cliente VARCHAR(255) NOT NULL UNIQUE,
    cif VARCHAR(100) UNIQUE,
    direccion VARCHAR(255) NOT NULL UNIQUE,
    id_usuario INT,
        FOREIGN KEY (id_usuario) 
        REFERENCES Usuarios(id_usuario)
        ON DELETE CASCADE
);

-- Tabla Administradores
CREATE TABLE Administradores (
    id_administrador INT AUTO_INCREMENT PRIMARY KEY,
    numero_documento_administrador VARCHAR(100) NOT NULL UNIQUE,
    nss VARCHAR(100) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido_principal VARCHAR(100) NOT NULL,
    apellido_secundario VARCHAR(100),
    id_usuario INT,
        FOREIGN KEY (id_usuario) 
        REFERENCES Usuarios(id_usuario)
        ON DELETE CASCADE
);

-- Tabla EmpleadosRider
CREATE TABLE EmpleadosRider (
    id_empleado_rider INT AUTO_INCREMENT PRIMARY KEY,
    numero_documento_empleado_rider VARCHAR(100) NOT NULL UNIQUE,
    nss VARCHAR(100) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido_principal VARCHAR(100) NOT NULL,
    apellido_secundario VARCHAR(100),
    id_usuario INT,
        FOREIGN KEY (id_usuario) 
        REFERENCES Usuarios(id_usuario)
        ON DELETE CASCADE
);

-- Tabla de empresas proveedoras
CREATE TABLE EmpresasProveedora (
    id_empresa_proveedora INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa_proveedora VARCHAR(255) NOT NULL UNIQUE,
    cif VARCHAR(100) UNIQUE,
    direccion VARCHAR(255) NOT NULL UNIQUE,
    especialidad VARCHAR(255) NOT NULL,
    telefono VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE
);

-- Tabla Comprador
CREATE TABLE Compradores (
    id_comprador INT AUTO_INCREMENT PRIMARY KEY,
    numero_documento_comprador VARCHAR(100) NOT NULL UNIQUE,
    nss VARCHAR(100) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido_principal VARCHAR(100) NOT NULL,
    apellido_secundario VARCHAR(100),
    id_usuario INT,
        FOREIGN KEY (id_usuario) 
        REFERENCES Usuarios(id_usuario)
        ON DELETE CASCADE
);

-- Crear tabla TipoProducto
CREATE TABLE TipoProducto (
    id_tipoproducto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo_producto VARCHAR(100) NOT NULL
);

-- Crear tabla SubtipoProductoUno
CREATE TABLE SubtipoProductoUno (
    id_subtipoproductouno INT AUTO_INCREMENT PRIMARY KEY,
    nombre_subtipo_uno VARCHAR(100) NOT NULL,
    id_tipoproducto INT,
    FOREIGN KEY (id_tipoproducto) REFERENCES TipoProducto(id_tipoproducto)
);

-- Crear tabla SubtipoProductoDos
CREATE TABLE SubtipoProductoDos (
    id_subtipoproductodos INT AUTO_INCREMENT PRIMARY KEY,
    nombre_subtipo_dos VARCHAR(100) NOT NULL,
    id_subtipoproductouno INT,
    FOREIGN KEY (id_subtipoproductouno) REFERENCES SubtipoProductoUno(id_subtipoproductouno)
);

-- Crear tabla ProductosAlmacenados
CREATE TABLE ProductosAlmacenados (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(255) NOT NULL,
    marca VARCHAR(100),
    cantidad_total INT NOT NULL,
    precio_unidad DECIMAL(10,2) NOT NULL,
    peso_unidad INT,
    volumen_unidad INT,
    descripcion TEXT,
    ruta_imagen VARCHAR(300),
    
    id_tipoproducto INT NOT NULL,
    id_subtipoproductouno INT NOT NULL,
    id_subtipoproductodos INT NOT NULL,
    id_empresa_proveedora INT,

    UNIQUE(nombre_producto, marca),

    FOREIGN KEY (id_tipoproducto) REFERENCES TipoProducto(id_tipoproducto),
    FOREIGN KEY (id_subtipoproductouno) REFERENCES SubtipoProductoUno(id_subtipoproductouno),
    FOREIGN KEY (id_subtipoproductodos) REFERENCES SubtipoProductoDos(id_subtipoproductodos),
    FOREIGN KEY (id_empresa_proveedora) REFERENCES EmpresasProveedora(id_empresa_proveedora)
);

CREATE TABLE TipoIncidencia (
    id_tipo_incidencia INT AUTO_INCREMENT PRIMARY KEY,
    descripcion_tipo_incidencia VARCHAR(50) NOT NULL
);

CREATE TABLE Incidencia (
    id_incidencia INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_incidencia INT NOT NULL,
    descripcion_incidencia VARCHAR(500),

    FOREIGN KEY (id_tipo_incidencia) REFERENCES TipoIncidencia(id_tipo_incidencia)
);

-- Crear tabla Pedido
CREATE TABLE Pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_incidencia INT,
    id_empleado_rider INT NOT NULL,
    fecha VARCHAR(20) NOT NULL,
    hora VARCHAR(20) NOT NULL,
    pagado BOOLEAN NOT NULL DEFAULT FALSE,
    enviado BOOLEAN NOT NULL DEFAULT FALSE,
    aceptado BOOLEAN NOT NULL DEFAULT FALSE,
    asignado BOOLEAN NOT NULL DEFAULT FALSE,
    en_ruta BOOLEAN NOT NULL DEFAULT FALSE,
    entregado BOOLEAN NOT NULL DEFAULT FALSE,
    exito_de_entrega BOOLEAN NOT NULL DEFAULT FALSE,

    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_incidencia) REFERENCES Incidencia(id_incidencia),
    FOREIGN KEY (id_empleado_rider) REFERENCES EmpleadosRider(id_empleado_rider)
);

CREATE TABLE ProductosEnPedido (
    id_producto_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad_solicitada INT NOT NULL,

    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES ProductosAlmacenados(id_producto)
);

-- Recuperar el último ID insertado
SET @id_usuario := LAST_INSERT_ID();

-- Insertamos valores

INSERT INTO Usuarios (nick, contrasenia, telefono, email, tipo) VALUES
('noregistrado', 'noregistrado', 'noregistrado', 'noregistrado@example.com', 'No Registrado'),
('aa', 'a', 'aaaaaaaa', 'aa@example.com', 'Administrador'),
('noasignado', '', 'noasignado', 'noasignado@gmail.com', 'Rider');

INSERT INTO Administradores (numero_documento_administrador, nss, nombre, apellido_principal, apellido_secundario, id_usuario)
VALUES 
('aaaaaaaa', 'aaaaaaaa', 'aaaaaaaa', 'aaaaa', 'aaaaaaaaa', 2);

INSERT INTO EmpleadosRider (numero_documento_empleado_rider, nss, nombre, apellido_principal, apellido_secundario, id_usuario) VALUES 
('noasignado', 'No Asignado', 'No Asignado', 'No Asignado', 'No Asignado', 3);

-- Insertar empresas proveedoras
INSERT INTO EmpresasProveedora (nombre_empresa_proveedora, cif, direccion, especialidad, telefono, email) VALUES
('Distribuciones Alimentarias SA', 'E12345678', 'Polígono Industrial Norte, Nave 12, Madrid', 'Productos secos', '913456789', 'contacto@distalimentarias.com'),
('Frutas y Verduras Frescas SL', 'F87654321', 'Mercado Central, Puesto 34, Valencia', 'Productos frescos', '963456789', 'info@frutasfrescas.com'),
('Carnicerías Premium SL', 'G11223344', 'Calle del Mercado 56, Zaragoza', 'Carnes y embutidos', '976456789', 'ventas@carnespremium.com'),
('Lácteos del Valle SA', 'H55667788', 'Carretera Comarcal Km 12, Burgos', 'Productos lácteos', '947456789', 'lacteos@delvalle.com'),
('Pescados Marinos SL', 'I33445566', 'Puerto Pesquero, Muelle 3, Vigo', 'Pescados y mariscos', '986456789', 'pescados@marinos.com'),
('Bebidas Internacionales SA', 'J77889900', 'Polígono Industrial Sur, Nave 45, Barcelona', 'Bebidas alcohólicas', '934567890', 'info@bebidasint.com');

-- Insertar tipos de producto
INSERT INTO TipoProducto (nombre_tipo_producto) VALUES
('Alimentos'),
('Bebidas'),
('Limpieza'),
('Utensilios');

-- Insertar subtipos de producto nivel 1
INSERT INTO SubtipoProductoUno (nombre_subtipo_uno, id_tipoproducto) VALUES
('Frescos', 1),
('Secos', 1),
('Congelados', 1),
('Alcohólicas', 2),
('No alcohólicas', 2),
('Superficies', 3),
('Cocina', 3),
('Cubiertos', 4),
('Vajilla', 4);

-- Insertar subtipos de producto nivel 2
INSERT INTO SubtipoProductoDos (nombre_subtipo_dos, id_subtipoproductouno) VALUES
('Frutas', 1),
('Verduras', 1),
('Carnes', 1),
('Pescados', 1),
('Legumbres', 2),
('Arroces', 2),
('Pastas', 2),
('Carnes', 3),
('Pescados', 3),
('Verduras', 3),
('Vinos', 4),
('Cervezas', 4),
('Licores', 4),
('Refrescos', 5),
('Zumos', 5),
('Aguas', 5),
('Suelos', 6),
('Cristales', 6),
('Utensilios', 7),
('Productos', 7),
('Cuchillos', 8),
('Tenedores', 8),
('Cucharas', 8),
('Platos', 9),
('Vasos', 9),
('Tazas', 9);

-- Insertar productos almacenados (incluyendo las nuevas frutas, verduras y pescados)
INSERT INTO ProductosAlmacenados (
    nombre_producto, marca, cantidad_total, precio_unidad, peso_unidad, volumen_unidad, 
    descripcion, ruta_imagen, id_tipoproducto, id_subtipoproductouno, id_subtipoproductodos, 
    id_empresa_proveedora
) VALUES
-- Alimentos frescos - Frutas
('Pera Conferencia', 'Frutas del Valle', 150, 0.55, 130, 90, 'Peras Conferencia jugosas y dulces', 'images/logo-tipografico.jpg', 1, 1, 1, 2),

-- Alimentos frescos - Verduras
('Pimiento Rojo', 'Verduras Selectas', 120, 1.20, 150, 100, 'Pimientos rojos carnosos', 'imagen/logo.png', 1, 1, 2, 2),

-- Alimentos frescos - Carnes
('Pechuga de pollo', 'Carnes Premium', 100, 4.50, 1000, 500, 'Pechuga de pollo fresca', 'imagen/logo.png', 1, 1, 3, 3),

-- Alimentos frescos - Pescados
('Dorada', 'Mariscos del Sur', 70, 9.50, 800, 600, 'Dorada fresca de acuicultura', 'images/mail.png', 1, 1, 4, 5),

-- Alimentos secos - Legumbres
('Lentejas', 'Campo y Sabor', 120, 1.20, 500, 300, 'Lentejas extra', 'imagen/logo.png', 1, 2, 5, 1),

-- Alimentos secos - Arroces
('Arroz bomba', 'Arroces Selectos', 90, 2.10, 1000, 400, 'Arroz bomba de Valencia', 'images/logo.png', 1, 2, 6, 1),

-- Alimentos secos - Pastas
('Espaguetis', 'Pastas Italianas', 110, 1.50, 500, 350, 'Espaguetis de sémola de trigo duro', 'images/logo.png', 1, 2, 7, 1),

-- Alimentos congelados - Carnes
('Filete de ternera', 'Carnes Premium', 70, 7.80, 800, 400, 'Filete de ternera madurada', 'imagen/logo.png', 1, 3, 8, 3),

-- Alimentos congelados - Pescados
('Gambas congeladas', 'Mariscos del Norte', 60, 12.50, 500, 300, 'Gambas peladas congeladas', 'imagen/logo.png', 1, 3, 9, 5),

-- Alimentos congelados - Verduras
('Menestra de verduras', 'Huerta Congelada', 85, 2.30, 750, 450, 'Mezcla de verduras congeladas', 'imagen/logo.png', 1, 3, 10, 2),

-- Bebidas alcohólicas - Vinos
('Vino tinto Reserva', 'Viña Ardanza', 50, 15.90, 1000, 750, 'Vino tinto reserva 2018', 'imagen/logo.png', 2, 4, 11, 6),

-- Bebidas alcohólicas - Cervezas
('Cerveza IPA', 'Cervezas Artesanas', 120, 1.80, 330, 330, 'Cerveza IPA artesanal', 'imagen/logo.png', 2, 4, 12, 6),

-- Bebidas alcohólicas - Licores
('Whisky 12 años', 'Destilerías Nobles', 40, 25.00, 1000, 700, 'Whisky escocés 12 años', 'imagen/logo.png', 2, 4, 13, 6),

-- Bebidas no alcohólicas - Refrescos
('Refresco de cola', 'Cola Drink', 200, 1.20, 330, 330, 'Refresco de cola', 'imagen/logo.png', 2, 5, 14, 6),

-- Bebidas no alcohólicas - Zumos
('Zumo de naranja', 'Zumos Naturales', 150, 2.10, 1000, 1000, 'Zumo de naranja 100%', 'imagen/logo.png', 2, 5, 15, 2),

-- Bebidas no alcohólicas - Aguas
('Agua mineral', 'Fuente Pura', 180, 0.60, 1500, 1500, 'Agua mineral natural', 'imagen/logo.png', 2, 5, 16, 6),

-- Limpieza - Superficies
('Limpiador multiusos', 'Limpieza Total', 90, 3.20, 750, 500, 'Limpiador para todo tipo de superficies', 'imagen/logo.png', 3, 6, 17, 1),

-- Limpieza - Cristales
('Limpiacristales', 'Brillo Cristalino', 75, 2.80, 500, 400, 'Limpiador para cristales y espejos', 'imagen/logo.png', 3, 6, 18, 1),

-- Limpieza - Cocina (Utensilios)
('Estropajo', 'Cocina Limpia', 120, 0.90, 50, 30, 'Estropajo multiusos', 'imagen/logo.png', 3, 7, 19, 1),

-- Limpieza - Cocina (Productos)
('Lavavajillas', 'Platos Brillantes', 95, 4.50, 1000, 800, 'Detergente para lavavajillas', 'imagen/logo.png', 3, 7, 20, 1),

-- Utensilios - Cubiertos (Cuchillos)
('Cuchillo chef', 'Cuchillería Profesional', 60, 22.90, 300, 150, 'Cuchillo chef profesional 20cm', 'imagen/logo.png', 4, 8, 21, 1),

-- Utensilios - Cubiertos (Tenedores)
('Tenedor mesa', 'Cubertería Elegante', 110, 1.90, 100, 50, 'Tenedor de mesa estándar', 'imagen/logo.png', 4, 8, 22, 1),

-- Utensilios - Cubiertos (Cucharas)
('Cuchara sopa', 'Cubertería Elegante', 110, 1.90, 100, 50, 'Cuchara de sopa estándar', 'imagen/logo.png', 4, 8, 23, 1),

-- Utensilios - Vajilla (Platos)
('Plato llano', 'Vajilla Clásica', 150, 3.50, 400, 300, 'Plato llano blanco 24cm', 'imagen/logo.png', 4, 9, 24, 1),

-- Utensilios - Vajilla (Vasos)


-- Utensilios - Vajilla (Tazas)
('Taza café', 'Vajilla Clásica', 130, 2.10, 250, 200, 'Taza para café 15cl', 'imagen/logo.png', 4, 9, 26, 1);

INSERT INTO TipoIncidencia (descripcion_tipo_incidencia) VALUES
('Sin inicidencia'),
('Con el cliente'),
('Problemas mecánicos del vehículo de reparto'),
('Accidente de trafico');

INSERT INTO Incidencia (id_tipo_incidencia, descripcion_incidencia) VALUES
(1, 'Sin incidencia existente'),
(2, 'El repartidor no conforme con el producto se niega a abonarlo y el pedido no es entregado'),
(3, 'Batería de bicileta sin carga, tuve que parar el reparto'),
(4, 'Me atropecha un coche');





