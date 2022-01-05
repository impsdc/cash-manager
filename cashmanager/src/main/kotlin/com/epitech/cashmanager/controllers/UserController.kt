package com.epitech.cashmanager.controllers

import com.epitech.cashmanager.exceptions.ResourceNotFoundException
import com.epitech.cashmanager.models.Cart
import com.epitech.cashmanager.models.Transaction
import com.epitech.cashmanager.models.User
import com.epitech.cashmanager.repositories.*
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.core.io.ByteArrayResource
import org.springframework.core.io.Resource
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.web.bind.annotation.*
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.security.Principal
import java.util.*
import java.util.function.Function
import java.util.stream.Collectors
import javax.validation.Valid


@RestController
class UserController {
    @Autowired
    private val userRepository: UserRepository? = null
    @Autowired
    private val cartRepository: CartRepository? = null
    @Autowired
    private val cartProductRepository: CartProductRepository? = null
    @Autowired
    private val transactionRepository: TransactionRepository? = null
    @Autowired
    private val transactionProductRepository: TransactionProductRepository? = null
    @Autowired
    private val passwordEncoder: PasswordEncoder? = null


    @get:GetMapping("/isApiUp")
    val isApiUp: ResponseEntity<*>
        get() = ResponseEntity("Api UP!", HttpStatus.OK)

    @GetMapping(value = ["/client.apk"])
    fun download(): ResponseEntity<Resource?>? {
        val file = File("client.apk")

        val path: Path = Paths.get(file.absolutePath)
        val resource = ByteArrayResource(Files.readAllBytes(path))

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(resource)
    }

    @get:GetMapping("/users")
    val users: List<Any?>
        get() = userRepository!!.findAll()
                .stream()
                .map<User?>(Function { User: User? -> User })
                .collect(Collectors.toList<Any?>())

    @GetMapping(value = ["/user"])
    fun getUserById(principal: Principal): ResponseEntity<*> {
        val user: User? = userRepository!!.getUserByUsername(principal.name)
                .orElseThrow { ResourceNotFoundException("User ${principal.name} could not be found") }!!
        return ResponseEntity.ok()
                .body {
                    user!!.password = ""
                    user
                }
    }

    @PostMapping("/users")
    fun createUser(@RequestBody userRequest: @Valid User): User {
        userRequest.password = passwordEncoder!!.encode(userRequest.password)
        userRequest.enabled = true
        val user: User = userRepository!!.save(userRequest)
        cartRepository!!.save(Cart(user.id, null))
        return user
    }

    @DeleteMapping("/users/{userId:.*}")
    fun deleteUser(@PathVariable userId: Long?): ResponseEntity<*> {
        val user: Optional<User?>? = userRepository!!.getUserById(userId!!)
        if (user!!.isPresent) {
            cartProductRepository!!.deleteAllById_CartId(user_id = userId)
            cartRepository!!.deleteById(userId)
            transactionProductRepository!!.deleteAllByUserId(user_id = userId)
            transactionRepository!!.deleteByUserId(user_id = userId)
            return ResponseEntity<Optional<Any>>(
                    user.map(Function<User?, ResponseEntity<Any?>> { User: User? ->
                        userRepository.delete(User!!)
                        ResponseEntity.ok().build()
                    }),
                    HttpStatus.OK)
        }
        return ResponseEntity("Not found", HttpStatus.NOT_FOUND)
    }
}