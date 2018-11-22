package com.tutor.intf

import com.typesafe.config.Config
import org.flywaydb.core.Flyway


class Migrator(config: Config) {
  val flyway = new Flyway()
  flyway.setDataSource(config.getString("url"), config.getString("user"), config.getString("password"))
  flyway.migrate()
}

