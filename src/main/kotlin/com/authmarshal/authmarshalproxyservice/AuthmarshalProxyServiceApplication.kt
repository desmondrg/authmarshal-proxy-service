package com.authmarshal.authmarshalproxyservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.zuul.EnableZuulProxy

@EnableZuulProxy
@SpringBootApplication
class AuthmarshalProxyServiceApplication

fun main(args: Array<String>) {
    runApplication<AuthmarshalProxyServiceApplication>(*args)
}
