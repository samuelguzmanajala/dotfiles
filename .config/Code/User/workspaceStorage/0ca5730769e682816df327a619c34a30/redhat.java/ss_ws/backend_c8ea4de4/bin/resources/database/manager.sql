CREATE TABLE IF NOT EXISTS vehicles (
    id CHAR(36) NOT NULL,
    license_plate VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    brand VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,
    year INT NOT NULL,
    PRIMARY KEY (id)
    )
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4
    COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS items (
    id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    stock INT NOT NULL,
    unit VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    sell_price DECIMAL(10,2) NOT NULL,
    minimum_stock INT NOT NULL,
    PRIMARY KEY (id)
    )
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4
    COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS vehicle_documents (
    id CHAR(36) NOT NULL,
    vehicle_id CHAR(36) NOT NULL,
    type VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    content LONGBLOB NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_vehicle_documents_vehicle
    FOREIGN KEY (vehicle_id)
    REFERENCES vehicles(id)
    ON DELETE CASCADE
    )
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4
    COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS pending_maintenance (
    id CHAR(36) NOT NULL,
    concept VARCHAR(255) NOT NULL,
    due_date DATE NOT NULL,
    vehicle_id CHAR(36) NOT NULL,
    type VARCHAR(255) NOT NULL,
    recurrence VARCHAR(50),
    time_interval INT,
    time_unit VARCHAR(20),
    kilometer_interval INT,
    estimated_duration INT,
    PRIMARY KEY (id),
    CONSTRAINT fk_pending_maintenance_vehicle
    FOREIGN KEY (vehicle_id)
    REFERENCES vehicles(id)
    ON DELETE CASCADE
    )
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4
    COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS maintenance_item (
    item_id CHAR(36) NOT NULL,
    maintenance_id CHAR(36) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (item_id, maintenance_id),
    CONSTRAINT fk_maintenance_item_item
    FOREIGN KEY (item_id)
    REFERENCES items(id)
    ON DELETE CASCADE,
    CONSTRAINT fk_maintenance_item_maintenance
    FOREIGN KEY (maintenance_id)
    REFERENCES pending_maintenance(id)
    ON DELETE CASCADE
    )
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4
    COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS domain_events (
    id CHAR(36) NOT NULL,
    aggregate_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    body JSON NOT NULL,
    occurred_on TIMESTAMP NOT NULL,
    PRIMARY KEY (id)
    )
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4
    COLLATE = utf8mb4_unicode_ci;