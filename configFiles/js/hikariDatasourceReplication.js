db.hikariDataSourceConfiguration.insert({    "serverName":"SERVER_NAME",    "type":"REPLICATION",    "autoCommit":"true",    "url":"jdbc:mysql://REPLICA_HOSTNAME:3306/SERVER_NAME?autoReconnect=true",    "user":"REPLICA_USER",    "password":"REPLICA_PWD",    "readOnly":"false",    "minIdle":20,    "defaultCatalog":"SERVER_NAME",    "maximumPoolSize":"100",    "maxConnLifetimeMillis":0,    "connectionTimeOut":30000,    "validationTimeOut":5000,    "driverClassName" : "com.mysql.jdbc.Driver",    "idleTimeOutinMillis":30000,    "cachePreparedStatement":"true",    "leakDetectionThreshold":0    }    );