CREATE TABLE a_user (
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
  owner_id integer REFERENCES a_user(id) REFERENCES a_user(id) ON DELETE CASCADE,
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
  owner_id integer NOT NULL REFERENCES a_user(id) ON DELETE CASCADE,
  about TEXT,
  UNIQUE (owner_id, name)
);

CREATE TABLE group (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id integer NOT NULL REFERENCES a_user(id) ON DELETE CASCADE,
  about TEXT,
  UNIQUE (owner_id, name)
);

CREATE TABLE user_group_access (
  user_id integer REFERENCES a_user(id) ON DELETE CASCADE,
  group_id integer REFERENCES group(id) ON DELETE CASCADE,
  access_level smallint,
  PRIMARY KEY (user_id, group_id)
);

CREATE TABLE user_space_access (
  user_id integer REFERENCES a_user(id) ON DELETE CASCADE,
  space_id integer REFERENCES space(id) ON DELETE CASCADE,
  access_level smallint,
  PRIMARY KEY (user_id, space_id)
);

CREATE TABLE user_device_access (
  user_id integer REFERENCES a_user(id) ON DELETE CASCADE,
  device_id bigint REFERENCES device(id) ON DELETE CASCADE,
  access_level smallint,
  PRIMARY KEY (user_id, device_id)
);

CREATE TABLE space_group (
  space_id integer REFERENCES space(id) ON DELETE CASCADE,
  group_id bigint REFERENCES group(id) ON DELETE CASCADE,
  PRIMARY KEY (space_id, group_id)
);

CREATE TABLE device_space (
  device_id bigint REFERENCES device(id) ON DELETE CASCADE,
  space_id integer REFERENCES space(id) ON DELETE CASCADE,
  PRIMARY KEY (device_id, space_id)
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

-- This function automatically deletes a group if it has got empty (no more mappings with any space)
CREATE OR REPLACE FUNCTION delete_group_if_no_mapping()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM space_space_group_mapping WHERE space_group_id = OLD.space_group_id) THEN
        DELETE FROM space_group WHERE id = OLD.space_group_id;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_group_if_last_mapping_deleted_trigger
AFTER DELETE ON space_group
FOR EACH ROW
EXECUTE FUNCTION delete_group_if_no_mapping();