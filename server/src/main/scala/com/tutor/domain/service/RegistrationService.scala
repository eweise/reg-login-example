package com.tutor.domain.service

import java.util.UUID

import cats.data.Validated.{Invalid, Valid}
import com.tutor.domain.{RegistrationRequest, RegistrationResponse, ValidationFailedException}
import com.tutor.domain.model.{Account, ClientRole, ID, Person}
import com.tutor.domain.repository.{AccountRepository, PersonRepository}
import scalikejdbc.DB

class RegistrationService(
                           implicit userRepo: PersonRepository,
                           accountRepository: AccountRepository,
                           webToken: JwtToken) {

  def register(request: RegistrationRequest): RegistrationResponse = {
    val newPerson = DB localTx { implicit session =>
      request.validateForm() match {
        case Valid(validRegRequest) =>
          //todo create account first
          //fixme why is name = UUID?
          val account = accountRepository.create(Account(name = UUID.randomUUID().toString))
          userRepo.create(createPerson(validRegRequest, account.id))
        case Invalid(errors) => throw new ValidationFailedException(errors.toList)
      }
    }
    RegistrationResponse("email1","token1")
  }

  private[this] def createPerson(req: RegistrationRequest, accountId: ID): Person = Person(
    accountId = accountId,
    email = req.email,
    role = ClientRole,
    password = req.password)

}
