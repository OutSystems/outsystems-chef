/*

An OutSystems Platform installation creates tables on two schemas:
* the ADMIN schema where all meta information for the OutSystems Platform and user defined entities are stored
* the SESSION schema where session data is stored

The OutSystems Platform uses 4 users for its runtime:
* The ADMIN user, used only by the Deployment Controller Service. This user has privileges to create tables and grant permissions in the admin schema.
* The RUNTIME user, used by the runtime of the applications ( application server and scheduler service ). This user has privileges to manipulate data in the admin schema.
* The LOG user, used by the Log Service to dump logs to the database. This user has privileges on the log tables.
* The SESSION user, used by runtime to access session data. This user has full control over the session schema.

TODO: Explain tablespaces.

Below you can find a template to create the necessary tablespaces and users and grant them the required privileges.

In this replace the following placeholders with the names of the tablespaces and users you wish to use (names should be self-explainatory):

<admin_tablespace>
<runtime_tablespace>
<index_tablespace>
<log_tablespace>
<session_tablespace>
<admin_user>
<runtime_user>
<log_user>
<session_user>
<password> -> replace this with unique and strong passwords for each user. Suggestion: https://duckduckgo.com/?q=password+20

*/


CREATE TABLESPACE <admin_tablespace>
    LOGGING 
    EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT  AUTO;

CREATE TABLESPACE <runtime_tablespace>
    LOGGING 
    EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT  AUTO;

CREATE TABLESPACE <index_tablespace>
    LOGGING 
    EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT  AUTO;

CREATE TABLESPACE <log_tablespace>
    NOLOGGING 
    EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT  AUTO;

CREATE TABLESPACE <session_tablespace>
    LOGGING 
    EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT  AUTO;




CREATE USER <admin_user>  PROFILE "DEFAULT" 
    IDENTIFIED BY <password> DEFAULT TABLESPACE <runtime_tablespace>
    ACCOUNT UNLOCK;

CREATE USER <runtime_user> PROFILE "DEFAULT"
	IDENTIFIED BY <password> DEFAULT TABLESPACE <runtime_tablespace>
	ACCOUNT UNLOCK;

CREATE USER <log_user> PROFILE "DEFAULT"
	IDENTIFIED BY <password> DEFAULT TABLESPACE <log_tablespace>
	ACCOUNT UNLOCK;

CREATE USER <session_user> PROFILE "DEFAULT" 
    IDENTIFIED BY <password> DEFAULT TABLESPACE <session_tablespace>
    ACCOUNT UNLOCK;


	
GRANT CREATE VIEW TO <admin_user>;
GRANT CREATE TABLE TO <admin_user>;
GRANT ALTER SESSION TO <admin_user>;
GRANT CREATE SEQUENCE TO <admin_user>;
GRANT CREATE PROCEDURE TO <admin_user>;
GRANT CREATE TRIGGER TO <admin_user>;

GRANT CREATE SESSION TO <admin_user>;
GRANT CREATE SESSION TO <log_user>;
GRANT CREATE SESSION TO <runtime_user>;

GRANT CREATE VIEW TO <session_user>;
GRANT CREATE TABLE TO <session_user>;
GRANT ALTER SESSION TO <session_user>;
GRANT CREATE SEQUENCE TO <session_user>;
GRANT CREATE PROCEDURE TO <session_user>;
GRANT CREATE TRIGGER TO <session_user>;

GRANT CREATE SESSION TO <session_user>;

/* XXX: In Amazon RDS remove this. */
GRANT EXECUTE on DBMS_LOB to <session_user>;


ALTER USER <admin_user> QUOTA UNLIMITED ON <runtime_tablespace>;
ALTER USER <admin_user> QUOTA UNLIMITED ON <admin_tablespace>;
ALTER USER <admin_user> QUOTA UNLIMITED ON <index_tablespace>;
ALTER USER <admin_user> QUOTA UNLIMITED ON <log_tablespace>;

ALTER USER <runtime_user> QUOTA UNLIMITED ON <runtime_tablespace>;
ALTER USER <runtime_user> QUOTA UNLIMITED ON <admin_tablespace>;
ALTER USER <runtime_user> QUOTA UNLIMITED ON <index_tablespace>;

ALTER USER <log_user> QUOTA UNLIMITED ON <log_tablespace>;

ALTER USER <session_user> QUOTA UNLIMITED ON <session_tablespace>;

