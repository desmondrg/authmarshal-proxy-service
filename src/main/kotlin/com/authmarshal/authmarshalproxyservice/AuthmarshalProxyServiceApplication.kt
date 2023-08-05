package com.authmarshal.authmarshalproxyservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@EnableZuulProxy
@SpringBootApplication
class AuthmarshalProxyServiceApplication

fun main(args: Array<String>) {
    runApplication<AuthmarshalProxyServiceApplication>(*args)
}
