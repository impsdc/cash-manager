package com.epitech.cashmanager.models

import java.io.Serializable
import javax.persistence.Column

import javax.persistence.Embeddable


@Embeddable
class TransactionProductKey : Serializable {
    @Column(name = "transaction_id")
    var transactionId: Long? = null

    @Column(name = "product_id")
    var productId: Long? = null

    constructor() {}
    constructor(transaction_id: Long?, product_id: Long?) {
        this.transactionId = transaction_id
        this.productId = product_id
    }
}