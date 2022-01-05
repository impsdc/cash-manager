package com.epitech.cashmanager.security

class SecurityConstants private constructor() {
    companion object {
        const val AUTH_LOGIN_URL = "/authenticate"

        // JWT token defaults
        const val TOKEN_HEADER = "Authorization"
        const val TOKEN_PREFIX = "Bearer "
        const val TOKEN_TYPE = "JWT"
        const val TOKEN_ISSUER = "secure-api"
        const val TOKEN_AUDIENCE = "secure-app"
    }

    init {
        throw IllegalStateException("Cannot create instance of static util class")
    }
}