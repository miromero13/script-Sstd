-- Verifica si la base de datos existe y la crea si no existe
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AirlineDB')
BEGIN
    CREATE DATABASE AirlineDB;
    PRINT 'Database "AirlineDB" created successfully.';
END
ELSE
BEGIN
    PRINT 'Database "AirlineDB" already exists.';
END
GO

USE AirlineDB;

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='country' AND xtype='U')
BEGIN
    CREATE TABLE country (
        country_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(100) NOT NULL UNIQUE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='nationality' AND xtype='U')
BEGIN
    CREATE TABLE nationality (
        nationality_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(50) NOT NULL UNIQUE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='frequent_flyer_card' AND xtype='U')
BEGIN
    CREATE TABLE frequent_flyer_card (
        ftc_number INT PRIMARY KEY NOT NULL,
        miles INT CHECK (miles >= 0),
        meal_code VARCHAR(20) DEFAULT 'N/A'
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='plane_model' AND xtype='U')
BEGIN
    CREATE TABLE plane_model (
        plane_model_id INT PRIMARY KEY IDENTITY(1,1),
        description VARCHAR(100) NOT NULL,
        graphic VARCHAR(255) DEFAULT 'No Image'
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='category' AND xtype='U')
BEGIN
    CREATE TABLE category (
        category_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(50) NOT NULL UNIQUE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='passport' AND xtype='U')
BEGIN
    CREATE TABLE passport (
        passport_id INT PRIMARY KEY IDENTITY(1,1),
        visa_type VARCHAR(50) NOT NULL DEFAULT 'Tourist'
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='department' AND xtype='U')
BEGIN
    CREATE TABLE department (
        department_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(100) NOT NULL,
        country_id INT NOT NULL,
        FOREIGN KEY (country_id) REFERENCES country(country_id) ON DELETE CASCADE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='airport' AND xtype='U')
BEGIN
    CREATE TABLE airport (
        airport_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(100) NOT NULL,
        department_id INT NOT NULL,
        FOREIGN KEY (department_id) REFERENCES department(department_id) ON DELETE CASCADE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='flight_number' AND xtype='U')
BEGIN
    CREATE TABLE flight_number (
        flight_number VARCHAR(50) PRIMARY KEY NOT NULL,
        departure_time DATETIME NOT NULL,
        description VARCHAR(255) DEFAULT 'No Description',
        type VARCHAR(50) NOT NULL CHECK (type IN ('Regular', 'Charter', 'Private')) DEFAULT 'Regular',
        airline VARCHAR(50) DEFAULT 'Unknown',
        start_airport_id INT NOT NULL,
        goal_airport_id INT NOT NULL,
        plane_model_id INT NOT NULL,
        FOREIGN KEY (plane_model_id) REFERENCES plane_model(plane_model_id) ON DELETE CASCADE,
        FOREIGN KEY (start_airport_id) REFERENCES airport(airport_id),
        FOREIGN KEY (goal_airport_id) REFERENCES airport(airport_id)
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='customer' AND xtype='U')
BEGIN
    CREATE TABLE customer (
        customer_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(100) NOT NULL,
        date_of_birth DATE NOT NULL,
        gender CHAR(1) CHECK (gender IN ('f', 'm')) DEFAULT 'f',
        ftc_number INT,
        nationality_id INT,
        FOREIGN KEY (nationality_id) REFERENCES nationality(nationality_id) ON DELETE SET NULL,
        FOREIGN KEY (ftc_number) REFERENCES frequent_flyer_card(ftc_number) ON DELETE SET NULL
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='airplane' AND xtype='U')
BEGIN
    CREATE TABLE airplane (
        airplane_id INT PRIMARY KEY IDENTITY(1,1),
        registration_number VARCHAR(50) NOT NULL UNIQUE,
        begin_of_operation DATE NOT NULL,
        status VARCHAR(20) CHECK (status IN ('Active', 'Inactive', 'Maintenance')) DEFAULT 'Active',
        plane_model_id INT NOT NULL,
        FOREIGN KEY (plane_model_id) REFERENCES plane_model(plane_model_id) ON DELETE CASCADE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='seat' AND xtype='U')
BEGIN
    CREATE TABLE seat (
        seat_id INT PRIMARY KEY IDENTITY(1,1),
        size VARCHAR(10) CHECK (size IN ('Standard', 'Economy', 'Business', 'First Class')) DEFAULT 'Standard',
        number INT NOT NULL,
        location VARCHAR(50) DEFAULT 'Not Assigned',
        plane_model_id INT NOT NULL,
        FOREIGN KEY (plane_model_id) REFERENCES plane_model(plane_model_id) ON DELETE CASCADE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='flight' AND xtype='U')
BEGIN
    CREATE TABLE flight (
        flight_id INT PRIMARY KEY IDENTITY(1,1),
        boarding_time DATETIME NOT NULL,
        flight_date DATE NOT NULL,
        gate VARCHAR(50) DEFAULT 'Not Assigned',
        check_in_counter VARCHAR(50) DEFAULT 'Not Assigned',
        flight_number VARCHAR(50) NOT NULL,
        FOREIGN KEY (flight_number) REFERENCES flight_number(flight_number) ON DELETE CASCADE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ticket' AND xtype='U')
BEGIN
    CREATE TABLE ticket (
        ticket_id INT PRIMARY KEY NOT NULL,
        number INT NOT NULL UNIQUE,
        customer_id INT,
        flight_number VARCHAR(50),
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE SET NULL,
        FOREIGN KEY (flight_number) REFERENCES flight_number(flight_number) ON DELETE CASCADE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='flight_category' AND xtype='U')
BEGIN
    CREATE TABLE flight_category (
        flight_id INT NOT NULL,
        category_id INT NOT NULL,
        PRIMARY KEY(flight_id, category_id),
        FOREIGN KEY (flight_id) REFERENCES flight(flight_id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='available_seat' AND xtype='U')
BEGIN
    CREATE TABLE available_seat (
        available_seat_id INT PRIMARY KEY IDENTITY(1,1),
        flight_number VARCHAR(50) NOT NULL,
        seat_id INT NOT NULL,
        flight_id INT NOT NULL,
        FOREIGN KEY (flight_number) REFERENCES flight_number(flight_number),
        FOREIGN KEY (seat_id) REFERENCES seat(seat_id),
        FOREIGN KEY (flight_id) REFERENCES flight(flight_id) ON DELETE CASCADE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='identity_document' AND xtype='U')
BEGIN
    CREATE TABLE identity_document (
        identity_document_id INT PRIMARY KEY NOT NULL,
        type VARCHAR(50) CHECK (type IN ('Passport', 'ID Card', 'Driver License', 'Other')) NOT NULL,
        expiration_date DATE NOT NULL,
        customer_id INT NOT NULL,
        passport_id INT,
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
        FOREIGN KEY (passport_id) REFERENCES passport(passport_id) ON DELETE SET NULL
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='coupon' AND xtype='U')
BEGIN
    CREATE TABLE coupon (
        coupon_id INT PRIMARY KEY NOT NULL,
        date_of_redemption DATE NOT NULL,
        class VARCHAR(10) CHECK (class IN ('Economy', 'Business', 'First Class')) DEFAULT 'Economy',
        standby BIT DEFAULT 0,
        meal_code VARCHAR(10) DEFAULT 'N/A',
        ticket_id INT NOT NULL,
        FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE
    );
END

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='pieces_of_luggage' AND xtype='U')
BEGIN
    CREATE TABLE pieces_of_luggage (
        pieces_of_luggage_id INT PRIMARY KEY IDENTITY(1,1),
        number INT NOT NULL,
        weight FLOAT CHECK (weight >= 0),
        coupon_id INT,
        FOREIGN KEY (coupon_id) REFERENCES coupon(coupon_id) ON DELETE SET NULL
    );
END

-- Insertar datos en la tabla country
INSERT INTO country (name) VALUES
('USA'),
('Canada'),
('Mexico');

-- Insertar datos en la tabla nationality
INSERT INTO nationality (name) VALUES
('American'),
('Canadian'),
('Mexican');

-- Insertar datos en la tabla frequent_flyer_card
INSERT INTO frequent_flyer_card (ftc_number, miles, meal_code) VALUES
(1001, 5000, 'Vegetarian'),
(1002, 15000, 'Vegan'),
(1003, 3000, 'Non-Vegetarian');

-- Insertar datos en la tabla plane_model
INSERT INTO plane_model (description, graphic) VALUES
('Boeing 737', 'boeing737.png'),
('Airbus A320', 'airbus_a320.png'),
('Boeing 787', 'boeing787.png');

-- Insertar datos en la tabla category
INSERT INTO category (name) VALUES
('Economy'),
('Business'),
('First Class');

-- Insertar datos en la tabla passport
INSERT INTO passport (visa_type) VALUES
('Tourist'),
('Business'),
('Student');

-- Insertar datos en la tabla department
INSERT INTO department (name, country_id) VALUES
('New York Office', 1),
('Toronto Office', 2),
('Mexico City Office', 3);

-- Insertar datos en la tabla airport
INSERT INTO airport (name, department_id) VALUES
('JFK International Airport', 1),
('Toronto Pearson International Airport', 2),
('Benito Juárez International Airport', 3);

-- Insertar datos en la tabla flight_number
INSERT INTO flight_number (flight_number, departure_time, description, type, airline, start_airport_id, goal_airport_id, plane_model_id) VALUES
('AA101', '2024-08-25 08:00:00', 'Morning Flight', 'Regular', 'American Airlines', 1, 2, 1),
('AC202', '2024-08-25 10:00:00', 'Midday Flight', 'Charter', 'Air Canada', 2, 3, 2),
('AM303', '2024-08-25 14:00:00', 'Afternoon Flight', 'Regular', 'AeroMexico', 3, 1, 3);

-- Insertar datos en la tabla customer
INSERT INTO customer (name, date_of_birth, gender, ftc_number, nationality_id) VALUES
('John Doe', '1980-05-15', 'm', 1001, 1),
('Jane Smith', '1990-07-22', 'f', 1002, 2),
('Carlos García', '1975-11-30', 'm', 1003, 3);

-- Insertar datos en la tabla airplane
INSERT INTO airplane (registration_number, begin_of_operation, status, plane_model_id) VALUES
('N12345', '2015-03-12', 'Active', 1),
('C23456', '2018-06-22', 'Inactive', 2),
('M34567', '2020-09-10', 'Active', 3);

-- Insertar datos en la tabla seat
INSERT INTO seat (size, number, location, plane_model_id) VALUES
('Economy', 1, 'A1', 1),
('Business', 2, 'B1', 1),
('First Class', 3, 'C1', 2);

-- Insertar datos en la tabla flight
INSERT INTO flight (boarding_time, flight_date, gate, check_in_counter, flight_number) VALUES
('2024-08-25 07:30:00', '2024-08-25', 'Gate 12', 'Counter 4', 'AA101'),
('2024-08-25 09:30:00', '2024-08-25', 'Gate 15', 'Counter 2', 'AC202'),
('2024-08-25 13:30:00', '2024-08-25', 'Gate 18', 'Counter 6', 'AM303');

-- Insertar datos en la tabla ticket
INSERT INTO ticket (ticket_id, number, customer_id, flight_number) VALUES
(1, 12345, 1, 'AA101'),
(2, 67890, 2, 'AC202'),
(3, 11223, 3, 'AM303');

-- Insertar datos en la tabla flight_category
INSERT INTO flight_category (flight_id, category_id) VALUES
(1, 1),
(2, 2),
(3, 3);

-- Insertar datos en la tabla available_seat
INSERT INTO available_seat (flight_number, seat_id, flight_id) VALUES
('AA101', 1, 1),
('AC202', 2, 2),
('AM303', 3, 3);

-- Insertar datos en la tabla identity_document
INSERT INTO identity_document (identity_document_id, type, expiration_date, customer_id, passport_id) VALUES
(1, 'Passport', '2030-12-31', 1, 1),
(2, 'ID Card', '2027-06-30', 2, NULL),
(3, 'Driver License', '2025-08-15', 3, 2);

-- Insertar datos en la tabla coupon
INSERT INTO coupon (coupon_id, date_of_redemption, class, standby, meal_code, ticket_id) VALUES
(1, '2024-08-20', 'Economy', 0, 'Vegetarian', 1),
(2, '2024-08-21', 'Business', 1, 'Non-Vegetarian', 2),
(3, '2024-08-22', 'First Class', 0, 'Vegan', 3);

-- Insertar datos en la tabla pieces_of_luggage
INSERT INTO pieces_of_luggage (pieces_of_luggage_id, number, weight, coupon_id) VALUES
(1, 2, 20.5, 1),
(2, 1, 15.0, 2),
(3, 3, 25.0, 3);

