package com.tutor.domain

import java.time.OffsetDateTime
import java.time.OffsetDateTime.now
import java.util.UUID
import java.util.UUID.randomUUID

package object model {
  type ID = UUID

  case class Account(id: UUID = randomUUID(),
                     name: String,
                     dateOpened: OffsetDateTime = now,
                     address: Option[Address] = None,
                     phone: Option[String] = None,
                     email: Option[String] = None
                    )

  sealed trait Role

  case object ClientRole extends Role

  case object AccountOwnerRole extends Role

  case class Person(id: UUID = randomUUID(),
                    accountId: UUID,
                    role: Role,
                    firstName: Option[String] = None,
                    lastName: Option[String] = None,
                    age: Option[Int] = None,
                    email: String,
                    password: String,
                    primaryAddress: Option[Address] = None,
                    primaryPhone: Option[String] = None,
                    primaryEmail: Option[String] = None,

                    createdAt: OffsetDateTime = now,
                    modifiedAt: OffsetDateTime = now
                   )

  case class Address(street1: String,
                     street2: Option[String],
                     city: String,
                     state: String,
                     postalCode: String)

  case class ToDo(id: ID = randomUUID(),
                  userId: ID,
                  title: String,
                  details: Option[String] = None,
                  dueDate: Option[OffsetDateTime] = None,
                  complete: Boolean = false,
                  createdAt: OffsetDateTime = now,
                  modifiedAt: OffsetDateTime = now
                 )

}
