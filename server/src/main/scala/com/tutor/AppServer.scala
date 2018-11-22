package com.tutor

import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import com.tutor.domain.repository.{AccountRepository, PersonRepository, ToDoRepository}
import com.tutor.domain.service.{JwtToken, LoginService, RegistrationService, ToDoService}
import com.tutor.intf.{Database, HttpServer, Migrator}
import com.typesafe.config.ConfigFactory
import com.typesafe.scalalogging.StrictLogging

import scala.io.StdIn

object AppServer extends App with StrictLogging  {
  lazy implicit val system           = ActorSystem()
  lazy implicit val materializer     = ActorMaterializer()
  lazy implicit val executionContext = system.dispatcher

  lazy implicit val webToken = new JwtToken()

  lazy implicit val accountRepo         = new AccountRepository()
  lazy implicit val personRepo          = new PersonRepository()
  lazy implicit val taskRepo            = new ToDoRepository()
  lazy implicit val taskService         = new ToDoService()
  lazy implicit val loginService        = new LoginService()
  lazy implicit val registrationService = new RegistrationService()


  implicit val config = ConfigFactory.load()
  val dbConfig            = config.getConfig("database")
  val dbPoolConfiguration = new Database(dbConfig)
  val serverBinding       = new HttpServer().start()

  ReverseProxyServer.start()
  println("migrating...")
  new Migrator(dbConfig).flyway

  println("server is ready")
  StdIn.readLine()
  // Unbind from the port and shut down when done
  //    serverBinding
  //            .flatMap(_.unbind())
  //            .onComplete(_ => system.terminate())
}
