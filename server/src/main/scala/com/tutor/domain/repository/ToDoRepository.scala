package com.tutor.domain.repository

import java.time.OffsetDateTime
import java.util.UUID

import com.tutor.domain.model.{ID, ToDo}
import scalikejdbc._

class ToDoRepository extends RepositoryHelper {
  val t = ToDoSyntax.syntax("t")

  def findAll(userId: ID)(implicit session: DBSession): List[ToDo] =
    sql"""select ${t.result.*} from ${ToDoSyntax.as(t)} where ${t.userId} = $userId """
      .map(ToDoSyntax(t.resultName)).list.apply()

  def find(userId: ID, toDoId: ID)(implicit session: DBSession): Option[ToDo] =
    sql"""select ${t.result.*} from ${ToDoSyntax.as(t)} where ${t.id} = $toDoId and ${t.userId} = $userId """
      .map(ToDoSyntax(t.resultName)).single.apply()

  def create(toDo: ToDo)(implicit session: DBSession): ToDo = {
    sql"""insert into todo (id, user_id, title, details, due_date, complete, created_at, modified_at) values (
                 ${toDo.id},
                 ${toDo.userId},
                    ${toDo.title},
                    ${toDo.details},
                    ${toDo.dueDate},
                    ${toDo.complete},
                    ${toDo.createdAt},
                    ${toDo.modifiedAt})""".update.apply()
    mustExist(find(toDo.userId, toDo.id))
  }

  def update(toDo: ToDo)(implicit session: DBSession): ToDo = {
    sql"""update todo set
              title = ${toDo.title},
              details=${toDo.details},
              due_date=${toDo.dueDate},
              complete=${toDo.complete},
              modified_at=${OffsetDateTime.now}
              where id = ${toDo.id} and user_id = ${toDo.userId}""".update.apply()
    mustExist(find(toDo.userId, toDo.id))
  }

  def delete(userId: ID, toDoId: ID)(implicit session: DBSession): Boolean =
    sql"delete from todo where id = $toDoId and user_id = $userId".update().apply() > 0
}

object ToDoSyntax extends SQLSyntaxSupport[ToDo] {
  override val tableName = "todo"

  def apply(t: ResultName[ToDo])(rs: WrappedResultSet) =
    new ToDo(
      id = UUID.fromString(rs.string(t.id)),
      userId = UUID.fromString(rs.string(t.userId)),
      title = rs.string(t.title),
      details = Option(rs.string(t.details)),
      dueDate = rs.offsetDateTimeOpt(t.dueDate),
      complete = rs.boolean(t.complete))
}

