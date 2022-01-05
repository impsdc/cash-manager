package com.epitech.cashmanager.models

import javax.persistence.*


@Entity
@Table(name = "transaction_products")
class TransactionProduct {
    @EmbeddedId
    var id: TransactionProductKey? = null

    var quantity = 0

    constructor() {}
    constructor(id: TransactionProductKey?, quantity: Int) {
        this.id = id
        this.quantity = quantity
    }
}