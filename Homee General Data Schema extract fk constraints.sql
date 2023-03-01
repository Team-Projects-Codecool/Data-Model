CREATE TABLE user (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  registered_at TIMESTAMP DEFAULT NOW(),
  last_logged_in TIMESTAMP,
  -- visual_impairment BOOLEAN DEFAULT false,
  -- hearing_impairment BOOLEAN DEFAULT false,
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
  owner_id integer,
  about TEXT,
);

ALTER TABLE device ADD CONSTRAINT fk_device_device_type_id FOREIGN KEY (device_type_id) REFERENCES device_type(id);

ALTER TABLE device ADD CONSTRAINT fk_device_owner_id FOREIGN KEY (owner_id) REFERENCES user(id);


CREATE TABLE technician (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  registered_at TIMESTAMP DEFAULT NOW(),
  schedule_last_updated_at TIMESTAMP DEFAULT NOW()
  last_logged_in TIMESTAMP,
  -- hearing_impairment BOOLEAN DEFAULT false,
  -- visual_impairment BOOLEAN DEFAULT false,
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
  user_id integer,
  space_id integer,
  PRIMARY KEY (user_id, space_id)
);

ALTER TABLE user_space_access ADD CONSTRAINT fk_user_space_access_user_id FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE;

ALTER TABLE user_space_access ADD CONSTRAINT fk_user_space_access_space_id FOREIGN KEY (space_id) REFERENCES space(id) ON DELETE CASCADE;

CREATE TABLE user_device_access (
  user_id integer,
  device_id bigint,
  PRIMARY KEY (user_id, device_id)
);
ALTER TABLE user_device_access ADD CONSTRAINT fk_user_device_access_user_id FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE;

ALTER TABLE user_device_access ADD CONSTRAINT fk_user_device_access_device_id FOREIGN KEY (device_id) REFERENCES device(id) ON DELETE CASCADE;

CREATE TABLE space_device_access (
  space_id integer,
  device_id bigint,
  PRIMARY KEY (space_id, device_id)
);
ALTER TABLE space_device_access ADD CONSTRAINT fk_space_device_access_space_id FOREIGN KEY (space_id) REFERENCES spaces(id) ON DELETE CASCADE;

ALTER TABLE space_device_access ADD CONSTRAINT fk_space_device_access_device_id FOREIGN KEY (device_id) REFERENCES device(id) ON DELETE CASCADE;

CREATE TABLE technician_device_access (
  technician_id integer,
  device_id bigint,
  PRIMARY KEY (technician_id, device_id)
);
ALTER TABLE technician_device_access ADD CONSTRAINT fk_technician_device_access_technician_id FOREIGN KEY (technician_id) REFERENCES technician(id) ON DELETE CASCADE;

ALTER TABLE technician_device_access ADD CONSTRAINT fk_technician_device_access_device_id FOREIGN KEY (device_id) REFERENCES device(id) ON DELETE CASCADE;

CREATE TABLE user_group_access (
  user_id integer,
  group_id integer,
  PRIMARY KEY (user_id, group_id)
);
ALTER TABLE user_group_access ADD CONSTRAINT fk_user_group_access_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE user_group_access ADD CONSTRAINT fk_user_group_access_group_id FOREIGN KEY (group_id) REFERENCES space_group(id) ON DELETE CASCADE;

CREATE TABLE space_space_group_mapping (
  space_group_id integer,
  space_id integer,
  PRIMARY KEY (space_group_id, space_id)
);
ALTER TABLE space_space_group_mapping ADD CONSTRAINT fk_space_space_group_mapping_space_group_id FOREIGN KEY (space_group_id) REFERENCES space_group(id) ON DELETE CASCADE;

ALTER TABLE space_space_group_mapping ADD CONSTRAINT fk_space_space_group_mapping_space_id FOREIGN KEY (space_id) REFERENCES space(id) ON DELETE CASCADE;


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
