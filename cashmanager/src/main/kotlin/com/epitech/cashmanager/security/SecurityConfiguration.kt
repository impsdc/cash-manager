package com.epitech.cashmanager.security

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.http.HttpMethod
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource
import javax.sql.DataSource


@EnableWebSecurity
@EnableGlobalMethodSecurity(securedEnabled = true)
open class SecurityConfiguration : WebSecurityConfigurerAdapter() {
    @Autowired
    var dataSource: DataSource? = null

    @Value("\${jwt.secret}")
    private val jwtSecret: String? = null

    @Throws(Exception::class)
    override fun configure(http: HttpSecurity) {
        http.cors().and()
            .csrf().disable()
            .authorizeRequests()
                .antMatchers(HttpMethod.GET, "/isApiUp").permitAll()
                .antMatchers(HttpMethod.GET, "/client.apk").permitAll()
                .antMatchers(HttpMethod.GET, "/users").hasRole("ADMIN")
                .antMatchers(HttpMethod.GET, "/user").authenticated()
                .antMatchers(HttpMethod.POST, "/users").hasRole("ADMIN")
                .antMatchers(HttpMethod.DELETE, "/users/{userId:.*}").hasRole("ADMIN")
                .antMatchers(HttpMethod.GET, "/carts").hasRole("ADMIN")
                .antMatchers(HttpMethod.GET, "/cart/products").authenticated()
                .antMatchers(HttpMethod.GET, "/cart").authenticated()
                .antMatchers(HttpMethod.POST, "/cart/products").authenticated()
                .antMatchers(HttpMethod.POST, "/cart/validate").authenticated()
                .antMatchers(HttpMethod.PUT, "/cart").authenticated()
                .antMatchers(HttpMethod.PUT, "/cart/products/{productId}").authenticated()
                .antMatchers(HttpMethod.DELETE, "/cart/products/{productId}").authenticated()
                .antMatchers(HttpMethod.GET, "/products").authenticated()
                .antMatchers(HttpMethod.GET, "/products/{productId}").authenticated()
                .antMatchers(HttpMethod.POST, "/products").hasRole("ADMIN")
                .antMatchers(HttpMethod.PUT, "/products/{productId}").hasRole("ADMIN")
                .antMatchers(HttpMethod.DELETE, "/products/{productId}").hasRole("ADMIN")
                .antMatchers(HttpMethod.GET, "/transactions").hasRole("ADMIN")
                .antMatchers(HttpMethod.GET, "/transactions/{transactionId}").hasRole("ADMIN")
                .antMatchers(HttpMethod.GET, "/transactions/{transactionId}/products").hasRole("ADMIN")
                .antMatchers(HttpMethod.GET, "/user/transactions").authenticated()
                .antMatchers(HttpMethod.GET, "/user/transactions/{transactionId}").authenticated()
                .antMatchers(HttpMethod.GET, "/user/transactions/{transactionId}/products").authenticated()
                .antMatchers(HttpMethod.PUT, "/transactions/{transactionId}").hasRole("ADMIN")
                .antMatchers(HttpMethod.DELETE, "/transactions/{transactionId}").hasRole("ADMIN")
            .anyRequest().authenticated()
            .and()
            .addFilter(JwtAuthenticationFilter(authenticationManager(), jwtSecret))
            .addFilter(JwtAuthorizationFilter(authenticationManager(), jwtSecret))
            .sessionManagement()
            .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
    }

    @Autowired
    @Throws(Exception::class)
    fun configAuthentication(auth: AuthenticationManagerBuilder) {
        auth.jdbcAuthentication().dataSource(dataSource)
                .usersByUsernameQuery("SELECT username, password, enabled FROM users WHERE username = ?")
                .authoritiesByUsernameQuery("SELECT username, role FROM users WHERE username = ?")
    }

    @Bean
    open fun passwordEncoder(): PasswordEncoder {
        return BCryptPasswordEncoder()
    }

    @Bean
    open fun jdbcTemplate(dataSource: DataSource?): JdbcTemplate {
        return JdbcTemplate(dataSource!!)
    }

    @Bean
    open fun corsConfigurationSource(): CorsConfigurationSource {
        val source = UrlBasedCorsConfigurationSource()
        source.registerCorsConfiguration("/**", CorsConfiguration().applyPermitDefaultValues())
        return source
    }
}