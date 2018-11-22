package com.tutor.domain.payload

import java.time.OffsetDateTime
import java.util.UUID

import com.tutor.domain.{ToDoRequest, ToDoResponse}

trait PayloadFixture {

  def createTaskRequest() = ToDoRequest(title = "t2", details = Some("d2"))

  def createTaskResponse() = ToDoResponse(
    id = UUID.randomUUID,
    title = "t1",
    details = Some("d1"),
    dueDate = Some(OffsetDateTime.now()),
    complete = true)
}
