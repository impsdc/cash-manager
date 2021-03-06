package com.epitech.cashmanager.security


import io.jsonwebtoken.*
import io.jsonwebtoken.security.SignatureException
import org.apache.commons.lang3.StringUtils
import org.slf4j.LoggerFactory
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter
import java.io.IOException
import java.util.stream.Collectors
import javax.servlet.FilterChain
import javax.servlet.ServletException
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse


class JwtAuthorizationFilter(authenticationManager: AuthenticationManager?, jwtSecret: String?) : BasicAuthenticationFilter(authenticationManager) {

    private var secret: String? = null

    @Throws(IOException::class, ServletException::class)
    override fun doFilterInternal(request: HttpServletRequest, response: HttpServletResponse,
                                  filterChain: FilterChain) {
        try {
            val authentication = getAuthentication(request)
            if (authentication == null) {
                filterChain.doFilter(request, response)
                return
            }
            SecurityContextHolder.getContext().authentication = authentication
            filterChain.doFilter(request, response)
        } catch (exception: Exception) {
            log.warn(exception.message)
        }
    }

    private fun getAuthentication(request: HttpServletRequest): UsernamePasswordAuthenticationToken? {
        val token = request.getHeader(SecurityConstants.TOKEN_HEADER)
        if (StringUtils.isNotEmpty(token) && token.startsWith(SecurityConstants.TOKEN_PREFIX)) {
            try {
                val signingKey: ByteArray = secret!!.toByteArray()
                val parsedToken = Jwts.parserBuilder()
                        .setSigningKey(signingKey).build()
                        .parseClaimsJws(token.replace("Bearer ", ""))
                val username = parsedToken
                        .body
                        .subject
                val authorities = (parsedToken.body["rol"] as List<*>?)!!.stream()
                        .map { authority: Any? -> SimpleGrantedAuthority(authority as String?) }
                        .collect(Collectors.toList())
                if (StringUtils.isNotEmpty(username)) {
                    return UsernamePasswordAuthenticationToken(username, null, authorities)
                }
            } catch (exception: ExpiredJwtException) {
                log.warn("Request to parse expired JWT : {} failed : {}", token, exception.message)
            } catch (exception: UnsupportedJwtException) {
                log.warn("Request to parse unsupported JWT : {} failed : {}", token, exception.message)
            } catch (exception: MalformedJwtException) {
                log.warn("Request to parse invalid JWT : {} failed : {}", token, exception.message)
            } catch (exception: SignatureException) {
                log.warn("Request to parse JWT with invalid signature : {} failed : {}", token, exception.message)
            } catch (exception: IllegalArgumentException) {
                log.warn("Request to parse empty or null JWT : {} failed : {}", token, exception.message)
            } catch (exception: Exception) {
                log.warn(exception.message)
            }
        }
        return null
    }

    init {
        secret = jwtSecret
    }

    companion object {
        private val log = LoggerFactory.getLogger(JwtAuthorizationFilter::class.java)
    }
}