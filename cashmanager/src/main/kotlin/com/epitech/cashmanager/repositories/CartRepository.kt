package com.epitech.cashmanager.repositories

import com.epitech.cashmanager.models.Cart
import com.epitech.cashmanager.models.Product
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository


@Repository
interface CartRepository : JpaRepository<Cart?, Long?>

