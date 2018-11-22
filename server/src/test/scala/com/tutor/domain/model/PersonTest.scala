package com.tutor.domain.model

import java.util.UUID

import com.tutor.domain.repository.fixture.PersonFixture
import io.circe.generic.auto._
import io.circe.java8.time._
import io.circe.parser.decode
import org.scalatest.{FlatSpec, Matchers}
import io.circe.generic.auto._
import io.circe.java8.time.TimeInstances
import io.circe.parser.decode
import io.circe.syntax._


class PersonTest extends FlatSpec with Matchers with TimeInstances {

  "create Person from JSON " should "be successful" in {
    val existingPerson = PersonFixture.createPerson(UUID.randomUUID)
    val json = existingPerson.asJson.noSpaces
    val maybePerson = decode[Person](json)

    maybePerson should not be None

    val person = maybePerson.right.get
    person shouldEqual existingPerson
  }
}
