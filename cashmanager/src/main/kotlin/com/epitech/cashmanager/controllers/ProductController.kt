package com.epitech.cashmanager.controllers

import com.epitech.cashmanager.models.Product
import com.epitech.cashmanager.repositories.ProductRepository
import com.epitech.cashmanager.exceptions.ResourceNotFoundException
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import javax.validation.Valid


@RestController
class ProductController {
    @Autowired
    private val productRepository: ProductRepository? = null
    @GetMapping(value = ["/products"])
    fun getProducts(pageable: Pageable?): Page<Product?> {
        return productRepository!!.findAll(pageable!!)
    }

    @GetMapping(value = ["/products/{productId}"])
    fun getProductById(@PathVariable productId: Long): Product {
        return productRepository!!.findById(productId)
                .orElseThrow { ResourceNotFoundException("Product not found with id $productId") }!!
    }

    @PostMapping("/products")
    fun createProduct(@RequestBody product: @Valid Product): Product {
        return productRepository!!.save(product)
    }

    @PutMapping("/products/{productId}")
    fun updateProduct(@PathVariable productId: Long,
                      @RequestBody productRequest: @Valid Product): Product {
        return productRepository!!.findById(productId)
                .map { product: Product? ->
                    println(productRequest.name)
                    println(productId)
                    product!!.name = productRequest.name ?: product.name
                    product.description = productRequest.description ?: product.description
                    product.quantity = productRequest.quantity
                    product.price = productRequest.price
                    product.imgUrl = productRequest.imgUrl ?: product.imgUrl
                    product.code = productRequest.code ?: product.code
                    productRepository.save(product)
                }.orElseThrow { ResourceNotFoundException("Product not found with id $productId") }
    }

    @DeleteMapping("/products/{productId}")
    fun deleteProduct(@PathVariable productId: Long): ResponseEntity<*> {
        return productRepository!!.findById(productId)
                .map<ResponseEntity<Any?>> { product: Product? ->
                    productRepository.delete(product!!)
                    ResponseEntity.ok().build()
                }.orElseThrow { ResourceNotFoundException("Product not found with id $productId") }
    }
}