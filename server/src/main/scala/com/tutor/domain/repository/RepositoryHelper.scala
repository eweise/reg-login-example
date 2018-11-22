package com.tutor.domain.repository

import com.tutor.domain.InternalException
import io.circe.Error

trait RepositoryHelper {

  def handleResult[A](result: Either[Error, A]): A = {
    result match {
      case Right(value: A) => value
      case Left(error) => throw new InternalException(s"could not decode entity", error)
    }
  }

  def mustExist[A](maybeExists: Option[A]): A =
    maybeExists.getOrElse(throw new InternalException("entity does not exist"))
}
