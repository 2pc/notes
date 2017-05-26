```
CREATE TABLE `canal_type_test` (
`ID` int(11) NOT NULL AUTO_INCREMENT,
`ftinyint` tinyint not null default 0,
`fsmallint` smallint not null default 0,
`fmediumint` mediumint not null default 0,
`fint` int not null default 0, 
`fbigint`  bigint not null default 0, 

`ftinytext` tinytext,
`ftext` text ,
`fmediumtext` mediumtext,
`flongtext` longtext ,
`fvarchar` varchar(6) not null default '' ,
`fchar` char(6) not null default '' ,
`ftinyblob` tinyblob ,
`fblob` blob ,
`fmediumblob` mediumblob,
`flongblob` longblob ,

`fbinary` binary (16) NOT NULL,
`fvarbinary` varbinary(256) ,
`fgeometry` geometry NOT NULL,
`fgeometrycollection` geometrycollection ,
`flinestring` linestring ,
`fmultilinestring` multilinestring,
`fmultipoint`  multipoint,
`fmultipolygon`  multipolygon,
`fpolygon` polygon POLYGONFROMTEXT('POLYGON((1 1,1 5,5 5,5 1,1 1))',
`fpoint` point,

`ffloat` float(20) DEFAULT NULL  ,
`fdouble`  double DEFAULT NULL ,
`fdecimal`decimal (5,2) DEFAULT NULL ,

`fdate` date default NULL ,
`fdatetime`  datetime default NULL,
`ftimestamp` timestamp default CURRENT_TIMESTAMP ,
`ftime` time  default NULL,
`fyear` year  default NULL,

`fenum`  enum('M', 'F'),
`fset` set('s1','s2'),
`fbit`  bit(8),
`fjson` json,
 PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 ;
```
