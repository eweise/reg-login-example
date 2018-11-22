package com.tutor.domain.repository

import java.util.UUID

import com.tutor.domain.model.{Account, AccountOwnerRole, Person, ToDo}
import com.tutor.intf.DBTestSupport
import org.scalatest.{FlatSpec, Matchers}

class ToDoRepositoryTest extends FlatSpec with Matchers with DBTestSupport {

  "create update and find " should "save to db and find" in {
    val accountRepository = new AccountRepository()
    val personRepository = new PersonRepository()
    val toDoRepository = new ToDoRepository()

    autoRollback { implicit session =>
      val account = accountRepository.create(Account(name = "Test Account"))
      val owner = personRepository.create(Person(
        accountId = account.id,
        role = AccountOwnerRole,
        email = "e@mail.com",
        password = "Welcome123"
      ))

      val newToDo = toDoRepository.create(ToDo(userId = owner.id, title = "A", details = Some("B")))
      val response = toDoRepository.find(owner.id, newToDo.id)

      response should not be None

      toDoRepository.update(response.get.copy(details = Some("C")))

      val responseAfterUpdate = toDoRepository.find(owner.id, newToDo.id)

      responseAfterUpdate should not be None

      val deleteResult = toDoRepository.delete(owner.id, responseAfterUpdate.get.id)

      deleteResult shouldBe true

      toDoRepository.findAll(owner.id).length shouldEqual 0
    }
  }
}
