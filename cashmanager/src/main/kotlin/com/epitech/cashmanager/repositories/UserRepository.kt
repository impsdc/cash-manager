package com.epitech.cashmanager.repositories

import com.epitech.cashmanager.models.User
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*


@Repository
interface UserRepository : JpaRepository<User?, Long?>, UserRepositoryCustom<User?, Long?> {
    fun getUserByUsername(username: String?): Optional<User?>
}