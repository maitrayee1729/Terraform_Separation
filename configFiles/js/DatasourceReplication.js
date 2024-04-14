db.dataSourceConfiguration.insert({ 	"serverName" : "SERVER_NAME", 	"type" : "REPLICATION", 	"driverClassName" : "com.mysql.jdbc.Driver", 	"url" : "jdbc:mysql://REPLICA_HOSTNAME:3306/SERVER_NAME?autoReconnect=true", 	"username" : "REPLICA_USER", 	"password" : "REPLICA_PWD", 	"defaultCatalog" : "SERVER_NAME", 	"evictionPolicyClassName" : "org.apache.tomcat.dbcp.pool2.impl.DefaultEvictionPolicy", 	"abandonedUsageTracking" : false, 	"cacheState" : true, 	"enableAutoCommitOnReturn" : true, 	"initialSize" : 1, 	"lifo" : true, 	"logAbandoned" : false, 	"maxConnLifetimeMillis" : -1, 	"maxIdle" : 20, 	"maxOpenPreparedStatements" : -1, 	"maxTotal" : "100", 	"maxWaitMillis" : 15000, 	"minIdle" : 0, 	"numTestsPerEvictionRun" : 3, 	"poolPreparedStatements" : false, 	"removeAbandonedOnBorrow" : false, 	"removeAbandonedOnMaintenance" : false, 	"removeAbandonedTimeout" : 30, 	"rollbackOnReturn" : true, 	"softMinEvictableIdleTimeMillis" : -1, 	"testOnBorrow" : true, 	"testOnCreate" : false, 	"testOnReturn" : false, 	"testWhileIdle" : false, 	"timeBetweenEvictionRunsMillis" : -1, 	"validationQuery" : "select 1", 	"validationQueryTimeout" : 100, 	"accessToUnderlyingConnectionAllowed" : false, 	"defaultReadOnly" : false, 	"connectionProperties" : "" } );
