package com.tutor.domain

import java.time.OffsetDateTime
import java.util.UUID

import cats.implicits._
import com.tutor.domain.repository.PersonRepository
import com.tutor.domain.service.Validator
import com.tutor.domain.service.Validator.{FieldValue, ValidationResult, notNull}
import scalikejdbc.DBSession

final case class ErrorResponse(statusCode: Int,
                               uri: String,
                               messages: List[String])

final case class LoginRequest(email: String, password: String)

final case class LoginResponse(username: String, token: String)

final case class RegistrationRequest(email: String, password: String) {
  def validateForm()(
    implicit session: DBSession,
    personRepo: PersonRepository): Validator.ValidationResult[RegistrationRequest] = {

    def validateEmail(implicit fieldValue: FieldValue[String],
                      session: DBSession): ValidationResult[String] =
      notNull.andThen(_ =>
        Validator.validateEmail.andThen(_ =>
          Validator.validateDoesNotAlreadyExist))

    def validatePassword(implicit fieldValue: FieldValue[String]): ValidationResult[String] =
      notNull.andThen(_ => Validator.validatePassword(fieldValue))

    val result = (validateEmail(("email", this.email), session),
      validatePassword(("password", this.password))
    ).mapN(RegistrationRequest)

    result
  }

}

final case class RegistrationResponse(username: String, token: String)

final case class ToDoRequest(title: String,
                             details: Option[String],
                             dueDate: Option[OffsetDateTime] = None,
                             complete: Option[Boolean] = Some(false))


final case class ToDoResponse(id: UUID,
                              title: String,
                              details: Option[String],
                              dueDate: Option[OffsetDateTime] = None,
                              complete: Boolean)
