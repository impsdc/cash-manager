package com.epitech.cashmanager.repositories

import com.epitech.cashmanager.models.Transaction
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.util.*
import javax.transaction.Transactional

@Repository
interface TransactionRepository : JpaRepository<Transaction?, Long?> {
    @Query(value = "SELECT NEW Product(p.id, p.code, p.name, p.price, p.imgUrl, p.description, tp.quantity)" +
            "FROM Product as p LEFT JOIN TransactionProduct as tp " +
            "ON tp.id.productId = p.id " +
            "WHERE tp.id.transactionId = :transaction_id ORDER BY p.id")
    fun getAllTransactionProducts(@Param("transaction_id") transaction_id: Long): Collection<Any?>

    fun findAllByUserId(pageable: Pageable?, @Param("user_id") user_id: Long): Page<Transaction?>

    @Query(value = "SELECT t " +
            "FROM Transaction as t " +
            "WHERE t.userId = :user_id")
    fun getAllByUserId(@Param("user_id") user_id: Long): List<Transaction?>

    @Query(value = "SELECT t " +
            "FROM Transaction as t " +
            "WHERE t.id = :transaction_id AND t.userId = :user_id")
    fun getByIdAndUserId(@Param("user_id") user_id: Long, @Param("transaction_id") transaction_id: Long): Optional<Transaction?>

    @Transactional
    @Modifying
    fun deleteByUserId(@Param("user_id") user_id: Long)
}