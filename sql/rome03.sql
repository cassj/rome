/* some test data */

INSERT INTO person (username, password, email) values ('test','test','cjohnsa@essex.ac.uk');
INSERT INTO person (username, password, email) values ('test2','test2','cjohnsa@essex.ac.uk');
INSERT INTO person (username, password, email) values ('test3','test3','cjohnsa@essex.ac.uk');

INSERT INTO role (name, description) VALUES ('user','a user');
INSERT INTO role (name, description) VALUES ('admin', 'an administrator');

INSERT INTO person_role(person,role)  VALUES ('test','user');
INSERT INTO person_role(person,role) VALUES ('test2','user');
INSERT INTO person_role(person,role) VALUES ('test3','user');
INSERT INTO person_role(person,role) VALUES ('test','admin');
