CREATE TABLE user (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  registered_at TIMESTAMP DEFAULT NOW(),
  last_logged_in TIMESTAMP,
  first_name VARCHAR(255) NULL,
  last_name VARCHAR(255) NULL,
  about_me TEXT,
);

CREATE TABLE device (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  model VARCHAR(255) NOT NULL,
  device_type_id integer,
  spot VARCHAR(255),
  warranty_start DATE,
  warranty_end DATE,
  purchase_date DATE,
  purchase_price NUMERIC(10, 2),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  owner_id integer REFERENCES user(id),
  about TEXT,
);

CREATE TABLE technician (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  registered_at TIMESTAMP DEFAULT NOW(),
  schedule_last_updated_at TIMESTAMP DEFAULT NOW()
  last_logged_in TIMESTAMP,
  about TEXT
);

CREATE TABLE space (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  about TEXT,
);

CREATE TABLE space_group (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  about TEXT
);

CREATE TABLE user_space_access (
  user_id integer REFERENCES user(id) ON DELETE CASCADE,
  space_id integer REFERENCES space(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, space_id)
);

CREATE TABLE user_device_access (
  user_id integer REFERENCES user(id) ON DELETE CASCADE,
  device_id bigint REFERENCES device(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, device_id)
);

CREATE TABLE space_device_access (
  space_id integer REFERENCES space(id) ON DELETE CASCADE,
  device_id bigint REFERENCES device(id) ON DELETE CASCADE,
  PRIMARY KEY (space_id, device_id)
);


CREATE TABLE technician_device_access (
  technician_id integer REFERENCES technician(id) ON DELETE CASCADE,
  device_id bigint REFERENCES device(id) ON DELETE CASCADE,
  PRIMARY KEY (technician_id, device_id)
);


CREATE TABLE user_group_access (
  user_id integer REFERENCES user(id) ON DELETE CASCADE,
  group_id integer REFERENCES space_group(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, group_id)
);

CREATE TABLE space_space_group_mapping (
  space_group_id integer REFERENCES space_group(id) ON DELETE CASCADE, -- automatically delete any associated rows in the space_space_group_mapping table when a space_group row is deleted.
  space_id integer REFERENCES space(id) ON DELETE CASCADE, -- automatically delete any associated rows in the space_space_group_mapping table when a space row is deleted.
  PRIMARY KEY (space_group_id, space_id)
);

-- This function automatically deletes a space group if it has got empty (no more mappings with any group)
CREATE OR REPLACE FUNCTION delete_space_group_if_no_mappings()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM space_space_group_mapping WHERE space_group_id = OLD.space_group_id) THEN
        DELETE FROM space_group WHERE id = OLD.space_group_id;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
