package com.epitech.cashmanager.controllers

import com.epitech.cashmanager.exceptions.IllegalArgumentException
import com.epitech.cashmanager.models.*
import com.epitech.cashmanager.exceptions.ResourceNotFoundException
import com.epitech.cashmanager.repositories.*
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.web.bind.annotation.*
import java.security.Principal
import java.time.LocalDateTime
import java.util.*
import javax.validation.Valid

@RestController
class CartController {
    @Autowired
    private val cartRepository: CartRepository? = null
    @Autowired
    private val cartProductRepository: CartProductRepository? = null
    @Autowired
    private val productRepository: ProductRepository? = null
    @Autowired
    private val transactionRepository: TransactionRepository? = null
    @Autowired
    private val transactionProductRepository: TransactionProductRepository? = null
    @Autowired
    private val userRepository: UserRepository? = null

    @GetMapping(value = ["/carts"])
    fun getCarts(pageable: Pageable?): Page<Cart?> {
        return cartRepository!!.findAll(pageable!!)
    }

    @GetMapping(value = ["/cart/products"])
    fun getCartProduct(principal: Principal): Collection<Product?> {
        val user: User? = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!
        return cartProductRepository!!.getAllCartProducts(user_id = user!!.id)
    }

    @GetMapping(value = ["/cart"])
    fun getCartById(principal: Principal): Cart? {
        val user: User? = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!
        return cartRepository!!.findById(user!!.id)
                .orElseThrow { ResourceNotFoundException("Cart not found with id ${user.id}") }!!
    }

    @PostMapping(value = ["/cart/products"])
    fun scanProduct(@RequestBody body: Map<String, Any>, principal: Principal): Product? {
        val user: User? = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!

        val productCode: String = body["code"] as String

        val product: Product = productRepository!!.findByCode(productCode)
                .orElseThrow { ResourceNotFoundException("Product not found with code $productCode") }!!
        if(product.quantity!! <= 0) {
            throw IllegalArgumentException("product quantity is too low")
        }
        cartRepository!!.findById(user!!.id)
                .orElseThrow { ResourceNotFoundException("Cart not found with id ${user.id}") }!!
        val cartProduct: Optional<CartProduct?> = cartProductRepository!!.findById(CartProductKey(user.id, product.id))

        val newCartProduct: CartProduct = if (cartProduct.isEmpty) {
            cartProductRepository.save(
                CartProduct(
                    CartProductKey(user.id, product.id), 1
                )
            )
        } else {
            cartProductRepository.save(
                CartProduct(
                    CartProductKey(user.id, product.id), cartProduct.get().quantity+1
                )
            )
        }
        product.quantity = product.quantity?.minus(1)
        productRepository.save(product)
        product.quantity = newCartProduct.quantity
        return product
    }

    @PostMapping(value = ["/cart/validate"])
    fun validateCart(@RequestBody body: Map<String, Any>, principal: Principal): Transaction? {
        val user: User? = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!

        val paymentMode: String = body["payment_mode"] as String
        val transactionDate = LocalDateTime.now()

        // Todo: check payment valid

        val cartProducts: Collection<CartProduct?> = cartProductRepository!!.findById_CartId(user!!.id)
        if(cartProducts.isEmpty()) throw ResourceNotFoundException("The cart ${user.id} is empty")

        val totalBill: Float = cartProductRepository.getCartProductsPrice(user.id)!!

        val transaction: Transaction = transactionRepository!!.save(
                Transaction(totalBill, paymentMode, user.id, transactionDate)
        )

        cartProducts.map { cartProduct: CartProduct? ->
            transactionProductRepository!!.save(
                TransactionProduct(
                    TransactionProductKey(transaction.id, cartProduct!!.id!!.productId),
                    cartProduct.quantity
                ),
            )
            cartProduct
        }

        cartProductRepository.deleteAll(cartProducts)

        return transaction
    }

    @PutMapping("/cart")
    fun updateCart(@RequestBody cartRequest: @Valid Cart, principal: Principal): Cart? {
        val user: User? = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!

        return cartRepository!!.findById(user!!.id)
                .map { cart: Cart? ->
                    cart!!.startDate = cartRequest.startDate
                    cartRepository.save(cart)
                }.orElseThrow { ResourceNotFoundException("Cart not found with id ${user.id}") }
    }

    @PutMapping(value = ["/cart/products/{productId}"])
    fun updateCartProductQuantity(@PathVariable productId: Long, @RequestBody body: Map<String, Any>, principal: Principal): CartProduct? {
        val user: User = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!

        val product: Product = productRepository!!.getById(productId)
        val quantity: Int = body["quantity"] as Int
        if(quantity < 0) {
            throw IllegalArgumentException("Quantity '$quantity' must not be negative")
        }
        return cartProductRepository!!.findById(CartProductKey(user.id, productId))
                .map { cartProduct: CartProduct? ->
                    cartProduct!!
                    if(quantity == 0) {
                        cartProductRepository.delete(cartProduct)
                        cartProduct.quantity = 0
                        cartProduct
                    } else {
                        if(product.quantity!! < quantity - cartProduct.quantity) {
                            throw IllegalArgumentException("Quantity '$quantity' must not be negative")
                        }
                        product.quantity = product.quantity?.plus(cartProduct.quantity - quantity)
                        cartProduct.quantity = quantity
                        productRepository.save(product)
                        cartProductRepository.save(cartProduct)
                    }
                }.orElseThrow { ResourceNotFoundException("Product $productId not found in cart ${user.id}") }
    }

    @DeleteMapping(value = ["/cart/products/{productId}"])
    fun deleteCartProduct(@PathVariable productId: Long, principal: Principal) {
        val user: User? = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!

        cartProductRepository!!.findById(CartProductKey(user!!.id, productId))
                .orElseThrow { ResourceNotFoundException("Product $productId not found in cart ${user.id}") }!!
        cartProductRepository.deleteById(CartProductKey(user.id, productId))
    }
}