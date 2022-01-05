package com.epitech.cashmanager.models

import java.beans.JavaBean
import javax.persistence.*


@Entity
@Table(name = "users")
@JavaBean
class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0
    var username: String? = null
    var password: String? = null
    var role: String? = null
    var enabled: Boolean? = null

    constructor() {}
    constructor(user: User) {
        id = user.id
        username = user.username
        password = user.password
        role = user.role
        enabled = user.enabled
    }
}