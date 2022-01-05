package com.epitech.cashmanager.models

import java.sql.Timestamp
import java.time.LocalDateTime
import java.util.*
import javax.persistence.*

@Entity
@Table(name = "transactions")
class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0

    @Column(name = "user_id")
    var userId: Long = 0

    @Column(name = "total_bill")
    var totalBill = 0f

    @Column(name = "transaction_date")
    var transactionDate: Timestamp? = null

    @Column(name = "payment_mode")
    var paymentMode: String? = null

    constructor() {}
    constructor(total_bill: Float, payment_mode: String?, user_id: Long, transaction_date: LocalDateTime?) {
        this.totalBill = total_bill
        this.paymentMode = payment_mode
        this.userId = user_id
        this.transactionDate = Timestamp.valueOf(transaction_date)
    }
}