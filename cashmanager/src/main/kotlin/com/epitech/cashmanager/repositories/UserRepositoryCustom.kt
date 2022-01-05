package com.epitech.cashmanager.repositories

import java.util.*


interface UserRepositoryCustom<User, Long> {
    fun getUserById(id: Long?): Optional<User>?
}