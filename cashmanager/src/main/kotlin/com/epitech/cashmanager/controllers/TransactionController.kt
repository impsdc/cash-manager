package com.epitech.cashmanager.controllers

import com.epitech.cashmanager.exceptions.ForbiddenException
import com.epitech.cashmanager.models.Transaction
import com.epitech.cashmanager.repositories.TransactionRepository
import com.epitech.cashmanager.exceptions.ResourceNotFoundException
import com.epitech.cashmanager.models.Product
import com.epitech.cashmanager.models.User
import com.epitech.cashmanager.repositories.TransactionProductRepository
import com.epitech.cashmanager.repositories.UserRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.security.Principal
import java.util.*
import java.util.function.Function
import javax.validation.Valid

@RestController
class TransactionController {
    @Autowired
    private val transactionRepository: TransactionRepository? = null
    @Autowired
    private val transactionProductRepository: TransactionProductRepository? = null
    @Autowired
    private val userRepository: UserRepository? = null

    @GetMapping(value = ["/transactions"])
    fun getTransactions(pageable: Pageable?): Page<Transaction?> {
        return transactionRepository!!.findAll(pageable!!)
    }

    @GetMapping(value = ["/transactions/{transactionId}/products"])
    fun getTransactionProducts(@PathVariable transactionId: Long): Collection<Any?> {
        return transactionRepository!!.getAllTransactionProducts(transaction_id = transactionId)
    }

    @GetMapping(value = ["/transactions/{transactionId}"])
    fun getTransactionById(@PathVariable transactionId: Long): Transaction {
        return transactionRepository!!.findById(transactionId)
                .orElseThrow { ResourceNotFoundException("Transaction not found with id $transactionId") }!!
    }

    @GetMapping(value = ["/user/transactions"])
    fun getUserTransactions(pageable: Pageable?, principal: Principal): Page<Transaction?> {
        val user: User = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!
        return transactionRepository!!.findAllByUserId(pageable, user_id = user.id)
    }

    @GetMapping(value = ["/user/transactions/{transactionId}"])
    fun getUserTransaction(@PathVariable transactionId: Long, principal: Principal): Transaction {
        val user: User = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!
        return transactionRepository!!.getByIdAndUserId(user_id = user.id, transaction_id = transactionId)
                .orElseThrow { ForbiddenException("Transaction with id $transactionId is not available") }!!
    }

    @GetMapping(value = ["/user/transactions/{transactionId}/products"])
    fun getTransactionProducts(@PathVariable transactionId: Long, principal: Principal): Collection<Product?> {
        val user: User = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!
        transactionRepository!!.getByIdAndUserId(user_id = user.id, transaction_id = transactionId)
                .orElseThrow { ResourceNotFoundException("Transaction with id $transactionId could not be found or is not available") }!!
        return transactionProductRepository!!.getAllTransactionProducts(transaction_id = transactionId)
    }

    @PutMapping("/transactions/{transactionId}")
    fun updateTransaction(@PathVariable transactionId: Long, @RequestBody transactionRequest: @Valid Transaction): Transaction {
        return transactionRepository!!.findById(transactionId)
                .map { transaction: Transaction? ->
                    transaction!!.transactionDate = transactionRequest.transactionDate
                    transaction.paymentMode = transactionRequest.paymentMode
                    transaction.totalBill = transactionRequest.totalBill
                    transactionRepository.save(transaction)
                }.orElseThrow { ResourceNotFoundException("Transaction not found with id $transactionId") }
    }

    @DeleteMapping("/transactions/{transactionId}")
    fun deleteTransaction(@PathVariable transactionId: Long): ResponseEntity<*> {
        val transaction: Optional<Transaction?> = transactionRepository!!.findById(transactionId)
        if (transaction.isPresent) {
            transactionProductRepository!!.deleteAllByTransactionId(transactionId)
            return ResponseEntity<Optional<Any>>(
                    transaction.map(Function<Transaction?, ResponseEntity<Any?>> { Transaction: Transaction? ->
                        transactionRepository.delete(Transaction!!)
                        ResponseEntity.ok().build()
                    }),
                    HttpStatus.OK)
        }
        return ResponseEntity("Not found", HttpStatus.NOT_FOUND)
    }
}