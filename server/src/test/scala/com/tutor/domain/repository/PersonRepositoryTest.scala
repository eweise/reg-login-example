package com.tutor.domain.repository

import com.tutor.domain.model.{ClientRole, Person}
import com.tutor.domain.repository.fixture.{AccountFixture, PersonFixture}
import com.tutor.intf.DBTestSupport
import org.scalatest.{FlatSpec, Matchers}

class PersonRepositoryTest extends FlatSpec with Matchers with DBTestSupport {

  val personRepo  = new PersonRepository()
  val accountRepo = new AccountRepository()

  val account = AccountFixture.createAccount()
  val person  = PersonFixture.createPerson(account.id)

  "PersonRepository " should "create, update and retrieve Person" in {
    autoRollback { implicit session =>
      accountRepo.create(account)
      val newPerson = personRepo.create(person)
      newPerson should not be None
      val savedAddress = newPerson.primaryAddress.get

      person.primaryAddress.get shouldEqual savedAddress

      val updated = personRepo.update(person.copy(email = "x@y.com"))
      updated.email shouldEqual "x@y.com"

      val maybePerson = personRepo.find(updated.id)
      maybePerson should not be None
      maybePerson.get.email shouldEqual "x@y.com"
    }
  }

  "PersonRepository " should "find by email + password" in {
    autoRollback { implicit session =>
      accountRepo.create(account)
      val newPerson = personRepo.create(person)
      newPerson should not be None

      personRepo.findByEmailAndPassword(person.email, person.password) should not be None
    }
  }

  "PersonRepository " should "find all" in {
    autoRollback { implicit session =>
      accountRepo.create(account)
      personRepo.create(person)
      personRepo.create(Person(
        accountId = account.id,
        role = ClientRole,
        email = "x@y.com",
        password = "password"))

      personRepo.findAll.length shouldEqual 2
    }
  }
}
