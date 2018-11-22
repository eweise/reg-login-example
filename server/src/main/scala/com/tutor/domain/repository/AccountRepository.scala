package com.tutor.domain.repository

import com.tutor.domain.model.{Account, ID}
import io.circe.generic.auto._
import io.circe.java8.time.TimeInstances
import io.circe.parser.decode
import io.circe.syntax._
import scalikejdbc.{DBSession, _}

class AccountRepository extends RepositoryHelper with TimeInstances {
  def create(account: Account)(implicit session: DBSession): Account = {
    val data: String = account.asJson.noSpaces
    val result =
      sql"""insert into account (id, data)
               values (${account.id}, CAST($data as jsonb))""".update.apply
    mustExist(find(account.id))
  }

  def update(account: Account)(implicit session: DBSession): Account = {
    val data: String = account.asJson.noSpaces
    sql"""update account set data = CAST($data as jsonb) where id=${account.id}""".update.apply
    mustExist(find(account.id))
  }

  def findAll()(implicit session: DBSession): List[Account] =
    sql"select data from account".map(rs => handleResult(decode[Account](rs.string("data")))
    ).collection.apply()

  def find(accountId: ID)(implicit session: DBSession): Option[Account] =
    sql"select data::json#>>'{}' as data from account where id = $accountId".map(rs =>
      handleResult(decode[Account](rs.string("data")))).single.apply()
}