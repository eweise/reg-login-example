package com.tutor.intf

import com.typesafe.config.Config


class Database(config: Config) {

  import scalikejdbc._

  private val user     = config.getString("user")
  private val url      = config.getString("url")
  private val password = config.getString("password")


  ConnectionPool.singleton(url, user, password)

  private val poolConfig = config.getConfig("pool")

  private val settings = ConnectionPoolSettings(
    initialSize = poolConfig.getInt("initialSize"),
    maxSize = poolConfig.getInt("maxSize"),
    connectionTimeoutMillis = poolConfig.getLong("connectionTimeoutMillis"),
    validationQuery = poolConfig.getString("validationQuery"))

  GlobalSettings.loggingSQLAndTime = LoggingSQLAndTimeSettings(
    enabled = true,
    singleLineMode = true,
    printUnprocessedStackTrace = true,
    stackTraceDepth = 1000,
    logLevel = 'debug,
    warningEnabled = false,
    warningThresholdMillis = 30000L,
    warningLogLevel = 'warn
  )
}

