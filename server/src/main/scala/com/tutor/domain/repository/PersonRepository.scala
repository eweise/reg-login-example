package com.tutor.domain.repository

import com.tutor.domain.model.{ID, Person}
import io.circe.generic.auto._
import io.circe.java8.time.TimeInstances
import io.circe.parser.decode
import io.circe.syntax._
import scalikejdbc._

class PersonRepository extends RepositoryHelper with TimeInstances {

  def findByEmailAndPassword(email: String, password: String)(implicit session: DBSession): Option[Person] = {
    sql"""select data::json#>>'{}' as data from person
             where data::json->>'email'=$email
             and data::json->>'password'=$password"""
      .map(rs => handleResult(decode[Person](rs.string("data")))).single().apply
  }

  def findByEmail(email: String)(implicit session: DBSession): Option[Person] = {
    sql"""select data::json#>>'{}' as data from person
             where data::json->>'email'=$email"""
      .map(rs => handleResult(decode[Person](rs.string("data")))).single().apply
  }

  def create(person: Person)(implicit session: DBSession): Person = {
    val data: String = person.asJson.noSpaces
    val result =
      sql"""insert into person (id, account_id, data)
               values (${person.id}, ${person.accountId}, CAST($data as jsonb))""".update.apply
    mustExist(find(person.id))
  }

  def update(person: Person)(implicit session: DBSession): Person = {
    val data: String = person.asJson.noSpaces
    sql"""update person set data = CAST($data as jsonb) where id=${person.id}""".update.apply
    mustExist(find(person.id))
  }

  def findAll()(implicit session: DBSession): List[Person] =
    sql"select data from person".map(rs => handleResult(decode[Person](rs.string("data")))
    ).collection.apply()

  def find(userId: ID)(implicit session: DBSession): Option[Person] =
    sql"select data::json#>>'{}' as data from person where id = $userId".map(rs =>
      handleResult(decode[Person](rs.string("data")))).single.apply()
}
