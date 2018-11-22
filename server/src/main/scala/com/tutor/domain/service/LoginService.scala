package com.tutor.domain.service

import com.tutor.domain._
import com.tutor.domain.repository.PersonRepository
import scalikejdbc.DB


class LoginService(implicit userRepo: PersonRepository, webToken: JwtToken) {
  def login(user: LoginRequest): LoginResponse =
    DB localTx { implicit session =>
      val foundPerson =
        userRepo.findByEmailAndPassword(user.email, user.password)
          .getOrElse(throw new NotFoundException("Invalid username or password"))

      LoginResponse(username = foundPerson.email, token = webToken.create(foundPerson.id.toString))
    }

}
