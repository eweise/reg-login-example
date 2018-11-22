package com.tutor.domain.service

import java.time.Instant
import java.util.UUID

import io.circe.generic.auto._
import io.circe.parser.decode
import pdi.jwt.{JwtAlgorithm, JwtCirce, JwtClaim}

case class UserClaim(userId: UUID)

class JwtToken {

  private val TEN_MINUTES = 10 * 60
  val key = "secret key"

  def create(userId: String): String = {

    val claim = JwtClaim(
      expiration = Some(Instant.now.plusSeconds(TEN_MINUTES).getEpochSecond),
      issuedAt = Some(Instant.now.getEpochSecond),
      content = s"""{"userId":"$userId"}"""
    )

    JwtCirce.encode(claim, key, JwtAlgorithm.HS256)
  }

  def find(token: String): Either[Throwable, UserClaim] =
    for {
      claim <- JwtCirce.decode(token, key, List(JwtAlgorithm.HS256)).toEither
      userClaim <- decode[UserClaim](claim.content)
    } yield userClaim
}
