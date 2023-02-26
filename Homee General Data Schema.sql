CREATE TABLE user (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  model VARCHAR(255) NOT NULL,
  device_type_id INT REFERENCES device_type(id),
  spot VARCHAR(255),
  warranty_start DATE,
  warranty_end DATE,
  purchase_date DATE,
  purchase_price NUMERIC(10, 2),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  owner_id UUID REFERENCES users(id),
  about TEXT,
);

CREATE TABLE device_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

INSERT INTO device_type (name) VALUES 
  ('Laptop'),
  ('Desktop'),
  ('Tablet'),
  ('Smartphone'),
  ('Smartwatch'),
  ('TV'),
  ('Speaker'),
  ('Headphones'),
  ('Camera'),
  ('Drone'),
  ('Printer'),
  ('Scanner'),
  ('Router'),
  ('Coffee Machine'),
  ('Milk frother')
  ('Vacuum Cleaner'),
  ('Washing Machine'),
  ('Dryer')
  ('Dishwasher'),
  ('Fridge'),
  ('Freezer'),
  ('Oven'),
  ('E-Reader'),
  ('Barbecue'),
  ('Tent'),
  ('Thermostat'),
  ('Air purifier'),
  ('Water purifier'),
  ('Blender'),
  ('Toaster'),
  ('Hair dryer'),
  ('Iron'),
  ('Sewing machine'),
  ('Gaming console'),
  ('Speaker'),
  ('Smart speaker'),
  ('Projector'),
  ('Electric scooter'),
  ('Hoverboard'),
  ('Electric bike'),
  ('Karaoke machine'),
  ('Massage chair'),
  ('Aquarium'),
  ('Telescope'),
  ('3D printer'),
  ('Smart lock'),
  ('Smart light bulb'),
  ('Drill'),
  ('Saw'),
  ('Hammer'),
  ('Screwdriver'),
  ('Thermometer'),
  ('Weather station'),
  ('Drone'),
  ('Alarm system'),
  ('Heat pump'),
  ('Water pump'),
  ('Central heating system element'),
  ('Water meter'),
  ('Electricity meter'),
  ('Sensor'),
  ('Boiler'),
  ('Heater'),
  ('Other');

CREATE TABLE technician (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  about TEXT,
);

CREATE TABLE space_group (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  about TEXT
);

CREATE TABLE user_space_access (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  space_id UUID REFERENCES spaces(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, space_id)
);

CREATE TABLE user_device_access (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, device_id)
);

CREATE TABLE space_device_access (
  space_id UUID REFERENCES spaces(id) ON DELETE CASCADE,
  device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
  PRIMARY KEY (space_id, device_id)
);


CREATE TABLE technician_device_access (
  technician_id UUID REFERENCES technicians(id) ON DELETE CASCADE,
  device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
  PRIMARY KEY (technician_id, device_id)
);


CREATE TABLE user_group_access (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  group_id UUID REFERENCES space_group(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, group_id)
);

CREATE TABLE space_space_group_mapping (
  space_group_id UUID REFERENCES space_group(id) ON DELETE CASCADE, -- automatically delete any associated rows in the space_space_group_mapping table when a space_group row is deleted.
  space_id UUID REFERENCES space(id) ON DELETE CASCADE, -- automatically delete any associated rows in the space_space_group_mapping table when a space row is deleted.
  PRIMARY KEY (group_id, space_id)
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
