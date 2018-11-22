package com.tutor.domain.service

import java.util.UUID

import com.tutor.domain.model.{Account, ClientRole, Person}
import com.tutor.domain.repository.{AccountRepository, PersonRepository}
import com.tutor.domain.{LoginRequest, NotFoundException, RegistrationRequest, ValidationFailedException}
import com.tutor.intf.DBTestSupport
import org.mockito.Matchers._
import org.mockito.Mockito
import org.mockito.Mockito.when
import scalikejdbc.DBSession

class LoginServiceTest extends DBTestSupport {

  trait Fixture {
    implicit val mockAccountRepo = Mockito.mock(classOf[AccountRepository])
    implicit val mockPersonRepo  = Mockito.mock(classOf[PersonRepository])
    implicit val webToken        = Mockito.mock(classOf[JwtToken])
    implicit val dbSession       = Mockito.mock(classOf[DBSession])

    val person = Person(
      accountId = UUID.randomUUID(),
      role = ClientRole,
      email = "e@mail",
      password = "password")

    val registrationRequest = RegistrationRequest(
      password = "P@ssw0rd",
      email = "e@mail.com")

    val personService = new RegistrationService()
    val loginService  = new LoginService()
  }

  "registration" should "not throw ValidationException" in new Fixture {
    when(mockAccountRepo.create(any())(any())).thenReturn(Account(name = UUID.randomUUID().toString))
    when(mockPersonRepo.create(any(classOf[Person]))(any())).thenReturn(person)
    when(mockPersonRepo.findByEmail(any())(any())).thenReturn(None)
    val response = personService.register(registrationRequest)
  }
  it should "validate form" in new Fixture {
    assertThrows[ValidationFailedException] {
      when(mockPersonRepo.findByEmail(any())(any())).thenReturn(None)
      personService.register(registrationRequest.copy(password = null))
    }
  }

  "login" should "validate person and return token" in new Fixture {
    when(mockPersonRepo.findByEmailAndPassword(any(), any())(any())).thenReturn(Some(person))
    val response = loginService.login(LoginRequest("email", "password"))
  }
  it should "throw exception if login fails" in new Fixture {
    when(mockPersonRepo.findByEmailAndPassword(any(), any())(any())).thenReturn(None)
    assertThrows[NotFoundException] {
      loginService.login(LoginRequest("email", "bad password"))
    }
  }

}


