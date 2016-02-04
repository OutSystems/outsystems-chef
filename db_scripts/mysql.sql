/*

An OutSystems Platform installation works on 2 databases:
* the OutSystems database where all meta information for the OutSystems Platform and user defined entities are stored
* the Session database where session data is stored

The OutSystems Platform uses 4 users for its runtime:
* The ADMIN user, used only by the Deployment Controller Service. This user has privileges to create tables and grant permissions in the outsystems database.
* The RUNTIME user, used by the runtime of the applications ( application server and scheduler service ). This user has privileges to manipulate data in the outsystems database.
* The LOG user, used by the Log Service to dump logs to the database. This user has privileges on the log tables.
* The SESSION user, used by runtime to access session data. This user has full control over the session database.



Below you can find a template to create the necessary database and users and grant them the required privileges.

In this replace the following placeholders with the names of the database and users you wish to use (names should be self-explainatory):

<outsystems_database> (suggestion, the name of your environment / machine you're installing )
<outsystems_session_database> (suggestion, <outsystems_database>_session )
<admin_user>
<runtime_user>
<log_user>
<session_user>
<password> -> replace this with unique and strong passwords for each user. Suggestion: https://duckduckgo.com/?q=password+20

*/

/* create the database */

CREATE DATABASE `<outsystems_database>`  DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci;
CREATE DATABASE `<outsystems_session_database>`  DEFAULT CHARACTER SET utf8;

/* create the users */

CREATE USER '<admin_user>' IDENTIFIED BY '<password>';
CREATE USER '<runtime_user>' IDENTIFIED BY '<password>';
CREATE USER '<log_user>' IDENTIFIED BY '<password>';
CREATE USER '<session_user>' IDENTIFIED BY '<password>';

/* grant privileges to the users */

GRANT ALL PRIVILEGES ON `<outsystems_database>`.* TO '<admin_user>' WITH GRANT OPTION;
GRANT SELECT ON `information\_schema`.* TO '<admin_user>';
GRANT process on *.* to '<admin_user>'; 

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE TEMPORARY TABLES, CREATE ROUTINE, ALTER ROUTINE, LOCK TABLES, EXECUTE ON `<outsystems_database>`.* TO '<runtime_user>';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE ON `<outsystems_database>`.* TO '<log_user>';

GRANT CREATE, ALTER, DROP, INDEX, SELECT, INSERT, UPDATE, DELETE, CREATE TEMPORARY TABLES, LOCK TABLES, CREATE ROUTINE, ALTER ROUTINE, EXECUTE ON `<outsystems_session_database>`.* TO '<session_user>';

