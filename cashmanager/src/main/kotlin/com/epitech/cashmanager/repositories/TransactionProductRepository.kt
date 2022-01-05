package com.epitech.cashmanager.repositories

import com.epitech.cashmanager.models.CartProduct
import com.epitech.cashmanager.models.Product
import com.epitech.cashmanager.models.TransactionProduct
import com.epitech.cashmanager.models.TransactionProductKey
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.util.*
import javax.transaction.Transactional


@Repository
interface TransactionProductRepository : JpaRepository<TransactionProduct?, Long?> {
    fun findById(id: TransactionProductKey): Optional<TransactionProduct?>

    @Query(value = "SELECT NEW Product(p.id, p.code, p.name, p.price, p.imgUrl, p.description, tp.quantity)" +
            "FROM Product AS p LEFT JOIN TransactionProduct AS tp " +
            "ON tp.id.productId = p.id " +
            "WHERE tp.id.transactionId = :transaction_id ORDER BY p.id")
    fun getAllTransactionProducts(@Param("transaction_id") transaction_id: Long): Collection<Product?>

    fun deleteById(id: TransactionProductKey)

    @Modifying
    @Query(value = "DELETE " +
            "FROM TransactionProduct as tp " +
            "WHERE tp.id.transactionId = :transaction_id")
    fun deleteAllByTransactionId(@Param("transaction_id") transaction_id: Long)

    @Modifying
    @Transactional
    @Query(value = "DELETE FROM transaction_products " +
            "USING transaction_products as tp " +
            "LEFT JOIN transactions AS t ON " +
            "t.id = tp.transaction_id " +
            "WHERE t.user_id = :user_id", nativeQuery = true)
    fun deleteAllByUserId(@Param("user_id") user_id: Long)
}