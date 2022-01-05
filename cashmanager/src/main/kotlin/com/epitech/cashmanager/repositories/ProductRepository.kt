package com.epitech.cashmanager.repositories

import com.epitech.cashmanager.models.Product
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.util.*


@Repository
interface ProductRepository : JpaRepository<Product?, Long?> {
    @Query(value = "SELECT p " +
            "FROM Product as p " +
            "WHERE p.code = :code")
    fun findByCode(@Param("code") code: String) : Optional<Product>
}