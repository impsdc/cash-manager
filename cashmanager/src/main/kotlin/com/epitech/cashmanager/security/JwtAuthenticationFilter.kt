package com.epitech.cashmanager.security

import com.fasterxml.jackson.databind.ObjectMapper
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.SignatureAlgorithm
import io.jsonwebtoken.security.Keys
import org.slf4j.LoggerFactory
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.userdetails.User
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import java.util.*
import java.util.stream.Collectors
import javax.servlet.FilterChain
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse


class JwtAuthenticationFilter(authenticationManager: AuthenticationManager, jwtSecret: String?) : UsernamePasswordAuthenticationFilter() {

    private var secret: String? = null

    override fun attemptAuthentication(request: HttpServletRequest, response: HttpServletResponse): Authentication {
        val body = request.reader.lines().collect(Collectors.joining(System.lineSeparator()))
        val data = ObjectMapper().readValue(body, MutableMap::class.java)
        val authenticationToken = UsernamePasswordAuthenticationToken(data["username"], data["password"])

        return authenticationManager.authenticate(authenticationToken)
    }

    override fun successfulAuthentication(request: HttpServletRequest, response: HttpServletResponse,
                                          filterChain: FilterChain, authentication: Authentication) {
        val user = authentication.principal as User
        val roles = user.authorities
                .stream()
                .map { obj: GrantedAuthority -> obj.authority }
                .collect(Collectors.toList())

        val signingKey: ByteArray = secret!!.toByteArray()
        val token = Jwts.builder()
                .signWith(Keys.hmacShaKeyFor(signingKey), SignatureAlgorithm.HS512)
                .setHeaderParam("typ", SecurityConstants.TOKEN_TYPE)
                .setIssuer(SecurityConstants.TOKEN_ISSUER)
                .setAudience(SecurityConstants.TOKEN_AUDIENCE)
                .setSubject(user.username)
                .setExpiration(Date(System.currentTimeMillis() + 864000000))
                .claim("rol", roles)
                .compact()
        response.addHeader(SecurityConstants.TOKEN_HEADER, SecurityConstants.TOKEN_PREFIX + token)
        val data = mapOf("username" to authentication.name,
                "role" to authentication.authorities.toList().first().authority)
        response.writer.write(ObjectMapper().writeValueAsString(data))
        response.contentType = "application/json"
        response.characterEncoding = "UTF-8"
        response.status = 200
    }



    init {
        secret = jwtSecret
        setAuthenticationManager(authenticationManager)
        setFilterProcessesUrl(SecurityConstants.AUTH_LOGIN_URL)
    }

    companion object {
        private val log = LoggerFactory.getLogger(JwtAuthorizationFilter::class.java)
    }
}