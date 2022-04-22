```
mysql> delimiter //
mysql>  CREATE PROCEDURE BatchInsert(IN loop_time INT)
    ->  BEGIN
    ->  DECLARE Var INT;
    -> SET Var = 0;
    -> WHILE Var < loop_time 
    -> DO
    ->  insert into xdual(id,x) values(null,now());
    -> SET Var = Var + 1; 
    -> END WHILE;  
    ->  END; 
    -> //
Query OK, 0 rows affected (0.03 sec)

mysql> use test;
Database changed
mysql> delimiter ; 
mysql> call  BatchInsert(2000000);
```
