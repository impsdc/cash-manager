package com.epitech.cashmanager.models

import java.io.Serializable
import javax.persistence.Column

import javax.persistence.Embeddable


@Embeddable
class CartProductKey : Serializable {
    @Column(name = "cart_id")
    var cartId: Long? = null

    @Column(name = "product_id")
    var productId: Long? = null

    constructor() {}
    constructor(cart_id: Long?, product_id: Long?) {
        this.cartId = cart_id
        this.productId = product_id
    }
}