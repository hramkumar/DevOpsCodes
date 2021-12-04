For SonarQube we need database like Postgres and OpenJDK
To install Postgres on CentOS 8 follow the instructions here -- https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-8

### Initializ postgresql
------------------------

    [root@xxx ~]# sudo postgresql-setup --initdb
     * Initializing database in '/var/lib/pgsql/data'
     * Initialized, logs are in /var/lib/pgsql/initdb_postgresql.log


### Start postgresql
--------------------

    [root@xxx ~]# systemctl start postgresql
    [root@xxx ~]# systemctl status postgresql

### Create role named 'sonar' in Postgres
----------------------------------------

    su - postgres
    psql
    
    [root@xxx ~]# tail -1 /etc/passwd
    postgres::26:26:PostgreSQL Server:/var/lib/pgsql:/bin/bash
    [root@xxx ~]# su - postgres
    [postgres@xxx ~]$ psql
    psql (12.7)
    Type "help" for help.
    
    postgres=# 
    
    postgres=# CREATE USER sonar WITH PASSWORD 'sonar';
    CREATE ROLE
    postgres=# 
    postgres=# ALTER USER sonar WITH SUPERUSER
    postgres-# 
    
    
    postgres-# SHOW hba_file;
    
    /var/lib/pgsql/data/pg_hba.conf

***Change the values peer and intend to `trust` and save the changes to the file /var/lib/pgsql/data/pg_hba.conf***

### Create database named sonar
--------------------------------

    postgres=# CREATE DATABASE sonar;
    CREATE DATABASE
    postgres=# 
    postgres=# \l
                                      List of databases
       Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
    -----------+----------+----------+-------------+-------------+-----------------------
     postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
     sonar     | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
     template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
     template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
    (4 rows)


### Finally Grant access to the role sonar to the database sonar
----------------------------------------------------------------

    postgres=# 
    postgres=# GRANT ALL PRIVILEGES ON DATABASE sonar TO sonar;
    GRANT
    postgres=# 
