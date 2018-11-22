package com.tutor.domain

class ValidationFailedException(val errors: List[String])
  extends RuntimeException(errors.reduceLeft((err, accum) => err + " " + accum))

class NotFoundException(message: String) extends RuntimeException(message)

// Unrecoverable issues
class InternalException(message: String, cause: Throwable = null) extends RuntimeException(message, cause)
