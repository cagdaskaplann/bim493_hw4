import 'package:flutter/material.dart';
import 'product_model.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshProductList();
  }

  Future<void> _refreshProductList() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllProducts();
    setState(() {
      _products = data;
      _isLoading = false;
    });
  }

  Future<void> _searchProduct() async {
    String barcode = _searchController.text.trim();
    if (barcode.isEmpty) {
      _refreshProductList();
      return;
    }

    final product = await DatabaseHelper.instance.getProductByBarcode(barcode);

    if (product != null) {
      setState(() {
        _products = [product];
      });
    } else {
      _showNotFoundDialog(barcode);
    }
  }

  void _showNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Product not found"),
        content: const Text("Would you like to add a new product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showFormDialog(initialBarcode: barcode);
            },
            child: const Text("Add New"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String barcode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DatabaseHelper.instance.delete(barcode);
              Navigator.of(ctx).pop();
              _refreshProductList();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showFormDialog({Product? product, String? initialBarcode}) {
    final _formKey = GlobalKey<FormState>();
    final barcodeController = TextEditingController(text: product?.barcodeNo ?? initialBarcode);
    final nameController = TextEditingController(text: product?.productName);
    final categoryController = TextEditingController(text: product?.category);
    final unitPriceController = TextEditingController(text: product?.unitPrice.toString());
    final taxRateController = TextEditingController(text: product?.taxRate.toString());
    final priceController = TextEditingController(text: product?.price.toString());
    final stockController = TextEditingController(text: product?.stockInfo?.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product == null ? "Add Product" : "Edit Product"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: barcodeController,
                  decoration: const InputDecoration(labelText: 'Barcode No'),
                  readOnly: product != null,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: unitPriceController,
                  decoration: const InputDecoration(labelText: 'Unit Price'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: taxRateController,
                  decoration: const InputDecoration(labelText: 'Tax Rate'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock Info (Optional)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newProduct = Product(
                  barcodeNo: barcodeController.text,
                  productName: nameController.text,
                  category: categoryController.text,
                  unitPrice: double.parse(unitPriceController.text),
                  taxRate: int.parse(taxRateController.text),
                  price: double.parse(priceController.text),
                  stockInfo: stockController.text.isNotEmpty ? int.parse(stockController.text) : null,
                );

                if (product == null) {
                  await DatabaseHelper.instance.create(newProduct);
                } else {
                  await DatabaseHelper.instance.update(newProduct);
                }

                Navigator.of(ctx).pop();
                _refreshProductList();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Store Inventory")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: "Enter Barcode",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searchProduct,
                  child: const Text("Search"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Barcode')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Stock')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _products.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item.barcodeNo)),
                        DataCell(Text(item.productName)),
                        DataCell(Text(item.price.toStringAsFixed(2))),
                        DataCell(Text(item.stockInfo?.toString() ?? '-')),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFormDialog(product: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(item.barcodeNo),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}