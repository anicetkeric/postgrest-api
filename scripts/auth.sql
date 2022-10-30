
ALTER DATABASE bookdb SET "app.jwt_secret" TO 'Q!6HLp@B5wD24Pbq*LNd!%S4&H%ly7bt';

-- add custom extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pgjwt;


-- Authentication management schema
CREATE SCHEMA IF NOT EXISTS auth;

-- users table
CREATE TABLE IF NOT EXISTS auth.users (
  email			  TEXT PRIMARY KEY CHECK ( email ~* '^.+@.+\..+$' ),
  password	  TEXT NOT NULL CHECK (LENGTH(password) < 512),
  role			  NAME NOT NULL CHECK (LENGTH(role) < 512)
);


CREATE OR REPLACE FUNCTION auth.check_role_exists() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles AS r WHERE r.rolname = new.role) THEN
    raise foreign_key_violation USING message =
      'unknown database role: ' || new.role;
    RETURN NULL;
  END IF;
  RETURN new;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ensure_user_role_exists ON auth.users;
CREATE CONSTRAINT TRIGGER ensure_user_role_exists
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE PROCEDURE auth.check_role_exists();

CREATE OR REPLACE FUNCTION
auth.encrypt_password() RETURNS trigger AS $$
BEGIN
  IF tg_op = 'INSERT' OR new.password <> old.password THEN
    new.password = crypt(new.password, gen_salt('bf'));
  END IF;
  RETURN new;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS encrypt_password ON auth.users;
CREATE TRIGGER encrypt_password
  BEFORE INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE PROCEDURE auth.encrypt_password();
  
-- add new type
DROP TYPE IF EXISTS auth.jwt_token cascade;
CREATE TYPE auth.jwt_token AS (
  token TEXT
);

-- login should be on our exposed schema
CREATE OR REPLACE FUNCTION
rest.login(email text, password text) RETURNS auth.jwt_token AS $$
DECLARE
  _user auth.users;
  result auth.jwt_token;
BEGIN
  -- check email and password
  SELECT users.* FROM auth.users
   WHERE users.email = login.email
     AND users.password = crypt(login.password, users.password)
  INTO _user;
  IF NOT FOUND THEN
    raise invalid_password USING message = 'invalid user or password';
  END IF;

  SELECT sign(
      row_to_json(r), current_setting('app.jwt_secret')
    ) AS token
    FROM (
      SELECT _user.role AS role, login.email AS email,
         extract(epoch FROM now())::INTEGER + 60*60 AS exp
    ) r
    INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION
rest.signup(email text, password text) RETURNS void
AS $$
BEGIN
  INSERT INTO auth.users (email, password, role) VALUES
    (signup.email, signup.password, 'webuser');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT USAGE ON SCHEMA auth TO anonymous, webuser;
GRANT EXECUTE ON FUNCTION rest.login(text,text) TO anonymous;
GRANT EXECUTE ON FUNCTION rest.signup(text,text) TO anonymous;
