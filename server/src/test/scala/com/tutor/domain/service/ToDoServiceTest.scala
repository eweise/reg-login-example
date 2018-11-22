package com.tutor.domain.service

import java.util.UUID

import com.tutor.domain.model.ToDo
import com.tutor.domain.repository.{PersonRepository, ToDoRepository}
import com.tutor.domain.{ToDoRequest, ValidationFailedException}
import com.tutor.intf.DBTestSupport
import org.mockito.Matchers.{any, same}
import org.mockito.Mockito
import org.mockito.Mockito.{mock, when}

class ToDoServiceTest extends DBTestSupport {

  trait Fixture {
    val accountId = UUID.randomUUID()
    val clientId  = UUID.randomUUID()

    val toDoRequest = ToDoRequest(title = "title1", details = Some("details1"))
    val toDo        = ToDo(userId = clientId, title = "title1", details = Some("details1"))

    implicit val todoRepo = mock(classOf[ToDoRepository])
    when(todoRepo.create(any())(any())).thenReturn(toDo)
    when(todoRepo.update(any())(any())).thenReturn(toDo)
    when(todoRepo.find(same(clientId), any())(any())).thenReturn(Some(toDo))
    when(todoRepo.delete(same(clientId), any())(any())).thenReturn(true)

    implicit val personRepo = mock(classOf[PersonRepository])

    val todoService = new ToDoService()
  }

  "TaskService" should "create todos" in new Fixture {
    todoService.create(clientId, toDoRequest).complete shouldBe false
  }
  it should "validate the request" in new Fixture {
    assertThrows[ValidationFailedException] {
      todoService.create(clientId, toDoRequest.copy(details = null))
    }
  }
  it should "find todos" in new Fixture {
    val response = todoService.find(clientId, toDo.id)
    response should not be null
    response.complete shouldEqual false
    response.details shouldEqual Some("details1")
    response.title shouldEqual "title1"
    response.dueDate shouldEqual None
  }
  it should "validate on update todos" in new Fixture {
    val response = todoService.update(clientId, toDo.id, toDoRequest)
    response should not be null
    response.title shouldEqual "title1"

    assertThrows[ValidationFailedException] {
      todoService.update(clientId, toDo.id, toDoRequest.copy(title = null))
    }
  }

  "TaskService validation" should "validate title" in new Fixture {
    todoService.validateForm(toDoRequest.copy(title = null)).isInvalid shouldBe true
  }
}
