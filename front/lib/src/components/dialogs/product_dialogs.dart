import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/src/components/dialogs/app_dialog.dart';
import 'package:front/src/services/product_service.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({Key? key, required this.barcode}) : super(key: key);

  final String barcode;

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isProcessing = false;
  bool _nameEmpty = false;
  bool _quantityEmpty = false;
  bool _priceEmpty = false;

  @override
  initState() {
    _imageController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  bool _requiredInputFields() {
    if (_nameController.text == "") {
      setState(() {
        _nameEmpty = true;
      });
    }
    if (_quantityController.text == "") {
      setState(() {
        _quantityEmpty = true;
      });
    }
    if (_priceController.text == "") {
      setState(() {
        _priceEmpty = true;
      });
    }

    if (_nameController.text == "" ||
        _quantityController.text == "" ||
        _priceController.text == "") {
      return false;
    }
    return true;
  }

  void _onSubmit() async {
    if (!_requiredInputFields()) return;

    setState(() {
      _isProcessing = true;
    });

    Response response = await ProductService().addProduct({
      "code": widget.barcode,
      "name": _nameController.text,
      "description": _descriptionController.text,
      "imgUrl": _imageController.text,
      "price": double.parse(_priceController.text),
      "quantity": int.parse(_quantityController.text),
    });
    print(response);

    setState(() {
      _isProcessing = false;
    });

    if (response.statusCode == 200) {
      print("product successfully added");
      Navigator.of(context).pop();
    } else {
      print("Error while adding the product");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error while adding a product",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: Navigator.of(context).pop,
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Add Product",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("Code: ${widget.barcode}"),
            ),
            DialogTextField(
              controller: _nameController,
              hint: "Name*",
              label: "Name*",
              error: _nameEmpty,
            ),
            Row(
              children: [
                Expanded(
                  child: DialogTextField(
                    controller: _quantityController,
                    hint: "Quantity*",
                    label: "Quantity*",
                    error: _quantityEmpty,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
                Expanded(
                  child: DialogTextField(
                    controller: _priceController,
                    hint: "Price*",
                    label: "Price*",
                    suffix: "€",
                    error: _priceEmpty,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^([0-9]+([.][0-9]*)?|[.][0-9]+)$'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            DialogTextField(
              controller: _descriptionController,
              hint: "Description",
              label: "Description",
              maxLines: 5,
            ),
            DialogTextField(
              controller: _imageController,
              hint: "Image (url)",
              label: "Image (url)",
              maxLines: 1,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
              child: Text(
                "* Required fields",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
            DialogSubmitButton(
              text: "Add Product",
              isProcessing: _isProcessing,
              onSubmit: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class EditProductDialog extends StatefulWidget {
  const EditProductDialog({Key? key, required this.product}) : super(key: key);

  final Map<String, dynamic> product;

  @override
  _EditProductDialogState createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  @override
  initState() {
    _nameController = TextEditingController(text: widget.product["name"]);
    _descriptionController =
        TextEditingController(text: widget.product["description"]);
    _imageController = TextEditingController(text: widget.product["imgUrl"]);
    _quantityController =
        TextEditingController(text: widget.product["quantity"].toString());
    _priceController =
        TextEditingController(text: widget.product["price"].toString());

    _imageController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  bool _isProcessing = false;
  bool _nameEmpty = false;
  bool _quantityEmpty = false;
  bool _priceEmpty = false;

  bool _requiredInputFields() {
    if (_nameController.text == "") {
      setState(() {
        _nameEmpty = true;
      });
    }
    if (_quantityController.text == "") {
      setState(() {
        _quantityEmpty = true;
      });
    }
    if (_priceController.text == "") {
      setState(() {
        _priceEmpty = true;
      });
    }

    if (_nameController.text == "" ||
        _quantityController.text == "" ||
        _priceController.text == "") {
      return false;
    }
    return true;
  }

  void _onSubmit() async {
    if (!_requiredInputFields()) return;

    setState(() {
      _isProcessing = true;
    });

    Response response =
        await ProductService().editProduct(widget.product["id"], {
      "code": widget.product["code"],
      "name": _nameController.text,
      "description": _descriptionController.text,
      "imgUrl": _imageController.text,
      "price": double.parse(_priceController.text),
      "quantity": int.parse(_quantityController.text),
    });

    setState(() {
      _isProcessing = false;
    });

    if (response.statusCode == 200) {
      print("product successfully modified");
      Navigator.of(context).pop();
    } else {
      print("Error while editing the product");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error while editing the product",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: Navigator.of(context).pop,
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Edit Product",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("Code: ${widget.product["code"]}"),
            ),
            DialogTextField(
              controller: _nameController,
              hint: "Name*",
              label: "Name*",
              error: _nameEmpty,
              maxLines: 1,
            ),
            Row(
              children: [
                Expanded(
                  child: DialogTextField(
                    controller: _quantityController,
                    hint: "Quantity*",
                    label: "Quantity*",
                    error: _quantityEmpty,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
                Expanded(
                  child: DialogTextField(
                    controller: _priceController,
                    hint: "Price*",
                    label: "Price*",
                    suffix: "€",
                    error: _priceEmpty,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^([0-9]+([.][0-9]*)?|[.][0-9]+)$'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            DialogTextField(
              controller: _descriptionController,
              hint: "Description",
              label: "Description",
              maxLines: 5,
            ),
            DialogTextField(
              controller: _imageController,
              hint: "Image (url)",
              label: "Image (url)",
              maxLines: 1,
            ),
            Image.network(
              _imageController.text,
              fit: BoxFit.contain,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
              child: Text(
                "* Required fields",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
            DialogSubmitButton(
              text: "Edit Product",
              isProcessing: _isProcessing,
              onSubmit: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
