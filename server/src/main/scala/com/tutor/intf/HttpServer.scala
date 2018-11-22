package com.tutor.intf

import akka.actor.ActorSystem
import akka.event.Logging
import akka.http.scaladsl.Http
import akka.http.scaladsl.Http.ServerBinding
import akka.http.scaladsl.model.{ContentTypes, HttpEntity, HttpResponse, StatusCodes}
import akka.http.scaladsl.server.Directives.{as, complete, entity, extractUri, get, path, post, _}
import akka.http.scaladsl.server.directives.Credentials
import akka.http.scaladsl.server.{ExceptionHandler, Route}
import akka.stream.ActorMaterializer
import com.tutor.domain.model.ID
import com.tutor.domain.service.{JwtToken, LoginService, RegistrationService, ToDoService}
import com.tutor.domain._
import com.typesafe.config.Config
import de.heikoseeberger.akkahttpcirce.FailFastCirceSupport._
import io.circe.generic.auto._
import io.circe.java8.time._
import io.circe.syntax._

import scala.concurrent.Future


class HttpServer(implicit val system: ActorSystem,
                 implicit val todoService: ToDoService,
                 implicit val registrationService: RegistrationService,
                 implicit val loginService: LoginService,
                 implicit val jwtToken: JwtToken,
                 implicit val config: Config) extends TimeInstances {

  val log = Logging(system, this.getClass.getName)

  val route: Route =
    authenticateOAuth2(realm = "secure site", myUserPassAuthenticator) { userId =>
      pathPrefix("todos") {
        pathEnd {
          get {
            complete(todoService.findAll(userId))
          } ~ post {
            entity(as[ToDoRequest]) { req => complete(todoService.create(userId, req))
            }
          }
        } ~ path(JavaUUID) { todoId => {
          put {
            entity(as[ToDoRequest]) { req => complete(todoService.update(userId, todoId, req))
            }
          }
        }
        } ~ path(JavaUUID) { todoId =>
          complete(todoService.find(userId, todoId))
        }
      }
    } ~ path("health") {
      get {
        complete(HttpEntity(ContentTypes.`text/html(UTF-8)`, "OK"))
      }
    } ~ pathPrefix("users") {
      path("login") {
        pathEnd {
          post {
            entity(as[LoginRequest]) { req => complete(loginService.login(req)) }
          }
        }
      } ~ pathEnd {
        post {
          entity(as[RegistrationRequest]) { req => complete(registrationService.register(req)) }
        }
      }
    }


  implicit def defaultExceptionHandler = ExceptionHandler {
    case notFound: NotFoundException =>
      extractUri { uri =>
        log.error("not Found error", notFound)
        val response = ErrorResponse(
          StatusCodes.NotFound.intValue,
          uri.toString(),
          List(notFound.getMessage)).asJson.noSpaces

        complete(HttpResponse(StatusCodes.NotFound, entity = response))
      }
    case validationEx: ValidationFailedException =>
      extractUri { uri =>
        val response = ErrorResponse(
          StatusCodes.BadRequest.intValue,
          uri.toString(),
          validationEx.errors).asJson.noSpaces

        complete(HttpResponse(StatusCodes.BadRequest, entity = response))
      }
    case ex: Exception =>
      extractUri { uri =>
        log.error("unknown error", ex)
        val response = ErrorResponse(
          StatusCodes.InternalServerError.intValue,
          uri.toString(),
          List("Internal Error")).asJson.noSpaces

        complete(HttpResponse(StatusCodes.InternalServerError, entity = response))
      }
  }

  def myUserPassAuthenticator(credentials: Credentials): Option[ID] =
    credentials match {
      case p@Credentials.Provided(id) => {
        val either = jwtToken.find(id)
          val foo = either.toOption.map(_.userId)
       foo
      }
      case _ => None
    }

  def start()(implicit materializer: ActorMaterializer): Future[ServerBinding] = {
    val proxyConfig = config.getConfig("httpServer")
    Http().bindAndHandle(route, proxyConfig.getString("host"), proxyConfig.getInt("port"))
  }
}
