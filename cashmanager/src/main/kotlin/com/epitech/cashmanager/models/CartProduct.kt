package com.epitech.cashmanager.models

import javax.persistence.*


@Entity
@Table(name = "cart_products")
class CartProduct {
    @EmbeddedId
    var id: CartProductKey? = null

    var quantity = 0

    constructor() {}
    constructor(id: CartProductKey?, quantity: Int) {
        this.id = id
        this.quantity = quantity
    }
}