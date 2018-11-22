package com.tutor.domain.payload

import com.tutor.domain.RegistrationRequest
import com.tutor.domain.repository.PersonRepository
import org.mockito.Matchers.any
import org.mockito.Mockito
import com.tutor.intf.DBTestSupport
import io.circe.java8.time.TimeInstances
import org.mockito.Matchers._
import org.mockito.Mockito
import org.scalatest.{FlatSpec, Matchers}
import scalikejdbc.DBSession


class RegistrationRequestTest extends FlatSpec with Matchers with TimeInstances {

  class Fixture {
    val request = RegistrationRequest(email = null, password = "Welcome123")
    implicit val mockPersonRepo = Mockito.mock(classOf[PersonRepository])
    implicit val mockDbSession  = Mockito.mock(classOf[DBSession])
  }

  "validateForm" should "validate email is not null" in new Fixture {
    request.validateForm().isInvalid shouldBe true
  }
  it should "validate password is correct format" in new Fixture {
    Mockito.when(mockPersonRepo.findByEmail(any())(any())).thenReturn(None)
    request.validateForm().isInvalid shouldBe true
  }

}
