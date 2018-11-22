package com.tutor.domain.service


import cats.data.Validated.{Invalid, Valid}
import cats.implicits._
import com.tutor.domain.model.{ID, ToDo}
import com.tutor.domain.repository.{PersonRepository, ToDoRepository}
import com.tutor.domain.service.Validator.{ValidationResult, notNull, success}
import com.tutor.domain.{NotFoundException, ToDoRequest, ToDoResponse, ValidationFailedException}
import scalikejdbc.DB


class ToDoService(implicit todoRepository: ToDoRepository, personRepository: PersonRepository) {

  def findAll(userId: ID): List[ToDoResponse] =
    DB readOnly { implicit session => todoRepository.findAll(userId).map(toToDoResponse) }

  def find(userId: ID, taskId: ID): ToDoResponse = DB readOnly { implicit session =>
    toToDoResponse(todoRepository.find(userId, taskId).getOrElse(throw new NotFoundException("task not found")))
  }

  def create(userId: ID, req: ToDoRequest): ToDoResponse =
    validateForm(req) match {
      case Valid(_) => toToDoResponse(DB localTx { implicit session =>
        todoRepository.create(toToDo(userId, req))
      })
      case Invalid(errors) => throw new ValidationFailedException(errors.toList)
    }

  def update(userId: ID, taskId: ID, req: ToDoRequest): ToDoResponse =
    validateForm(req) match {
      case Valid(_) =>
        DB localTx { implicit session =>
          todoRepository.find(userId, taskId) match {
            case Some(existingToDo) =>
              toToDoResponse(todoRepository.update(updateFields(existingToDo, req)))
            case _ => throw new NotFoundException("todo not found")
          }
        }
      case Invalid(errors) => throw new ValidationFailedException(errors.toList)
    }

  def delete(userId: ID, taskId: ID): Unit = {
    DB localTx { implicit session =>
      if (!todoRepository.delete(userId, taskId)) {
        throw new NotFoundException("todo  not found")
      }
    }
  }

  def validateForm(req: ToDoRequest): ValidationResult[ToDoRequest] = (
    notNull("title", req.title),
    notNull("details", req.details),
    success(req.dueDate),
    success(req.complete)
  ).mapN(ToDoRequest)

  def updateFields(task: ToDo, req: ToDoRequest): ToDo = {
    task.copy(title = req.title,
      details = req.details,
      dueDate = req.dueDate,
      complete = req.complete.getOrElse(task.complete)
    )
  }

  def toToDoResponse(task: ToDo) =
    ToDoResponse(
      id = task.id,
      title = task.title,
      details = task.details,
      dueDate = task.dueDate,
      complete = task.complete)

  def toToDo(userId: ID, req: ToDoRequest): ToDo =
    ToDo(
      userId = userId,
      title = req.title,
      details = req.details,
      dueDate = req.dueDate)
}