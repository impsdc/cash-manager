package com.epitech.cashmanager.repositories

import com.epitech.cashmanager.models.CartProduct
import com.epitech.cashmanager.models.CartProductKey
import com.epitech.cashmanager.models.Product
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.util.*
import javax.transaction.Transactional


@Repository
interface CartProductRepository : JpaRepository<CartProduct?, Long?> {

    @Query("SELECT COALESCE(SUM(p.price * cp.quantity),0) " +
            "FROM Product AS p LEFT JOIN CartProduct AS cp " +
            "ON cp.id.productId = p.id " +
            "WHERE cp.id.cartId = :cart_id")
    fun getCartProductsPrice(@Param("cart_id") cart_id: Long): Float?

    @Query(value = "SELECT NEW Product(p.id, p.code, p.name, p.price, p.imgUrl, p.description, cp.quantity) " +
            "FROM Product AS p LEFT JOIN CartProduct AS cp " +
            "ON cp.id.productId = p.id " +
            "WHERE cp.id.cartId = :user_id ORDER BY p.id")
    fun getAllCartProducts(@Param("user_id") user_id: Long): Collection<Product?>

    fun findById(id: CartProductKey): Optional<CartProduct?>

    fun findById_CartId(cartId: Long): Collection<CartProduct?>

    @Transactional
    @Modifying
    fun deleteById(id: CartProductKey)

    @Transactional
    @Modifying
    fun deleteAllById_CartId(@Param("user_id") user_id: Long)
}