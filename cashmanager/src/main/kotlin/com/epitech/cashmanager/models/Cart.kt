package com.epitech.cashmanager.models

import java.beans.JavaBean
import java.util.*
import javax.persistence.*


@Entity
@Table(name = "carts")
@JavaBean
class Cart {
    @Id
    var userId: Long = 0
    var startDate: Date? = null

    constructor() {}
    constructor(user_id: Long, start_date: Date?) {
        this.userId = user_id
        this.startDate = start_date
    }
}