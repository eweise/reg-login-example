package com.tutor.domain.repository.fixture

import java.time.OffsetDateTime
import java.util.UUID

import com.tutor.domain.model.Account

object AccountFixture {

  def createAccount(): Account = {
    Account(
      id = UUID.randomUUID(),
      name = "Therapy Business",
      dateOpened = OffsetDateTime.now()
    )
  }
}
