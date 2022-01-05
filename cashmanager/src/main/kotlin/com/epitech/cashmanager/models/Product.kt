package com.epitech.cashmanager.models

import javax.persistence.*
import javax.validation.constraints.NotBlank

@Entity
@Table(name = "products")
class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0

    var name: String? = null

    var code: String? = null
    var price: Float? = null

    var imgUrl: String? = null

    var description: String? = null
    var quantity: Int? = null

    constructor() {}
    constructor(id: Long, code: String?, name: String?, price: Float?, img_url: String?, description: String?, quantity: Int?) {
        this.id = id
        this.code = code
        this.name = name
        this.imgUrl = img_url
        this.price = price
        this.description = description
        this.quantity = quantity
    }
}