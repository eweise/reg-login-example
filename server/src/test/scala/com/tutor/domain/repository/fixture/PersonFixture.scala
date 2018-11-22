package com.tutor.domain.repository.fixture

import java.util.UUID

import com.tutor.domain.model.{Address, ClientRole, Person}

object PersonFixture {

  def createPerson(accountId: UUID): Person = {

    Person(
      accountId = accountId,
      role = ClientRole,
      email = "e@" + UUID.randomUUID() + ".com",
      password = "Welcome123",
      primaryAddress = Some(Address(
        street1 = "1 Elm Street",
        street2 = Some("suite 555"),
        city = "SF",
        state = "CA",
        postalCode = "94949"
      )))

  }
}
