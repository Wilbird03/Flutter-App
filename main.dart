import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';


final List<Map<String, String>> registeredUsers = [];

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => MyHomePage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  String _searchQuery = '';

  List<Product> hotSalesProducts = [
    Product(
      title: 'Salted Potato Chips',
      imageUrl: 'https://shop.tonggarden.com.my/media/catalog/product/cache/f2d087d5bbbebd2a5cd5b6c7e4ff7913/n/o/noi_potato_chips_salted_1_1.jpg',
      price: 2.99,
      stock: 50,
    ),
    Product(
      title: 'Vanilla Ice Cream',
      imageUrl: 'https://www.degrocery.com/de-grocery/2020/08/Nestle-vanilla-Flavour-Ice-Cream-1.5L.jpg',
      price: 4.99,
      stock: 20,
    ),
    Product(
      title: 'MieSedaap Instant Noodle',
      imageUrl: 'https://down-my.img.susercontent.com/file/9de9917f69619bc9af4a04e45f81b0ee',
      price: 5.99,
      stock: 15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Cart _cart = Cart(context: context);

    return Scaffold(
      appBar: AppBar(
        title: Text('GrabNGo'),
        titleTextStyle: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo[400],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('All'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Snacks'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Beverages'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Others'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Card(
            elevation: 4.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Hot Sales',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (var product in hotSalesProducts)
                  if (_searchQuery.isEmpty || product.title.contains(_searchQuery))
                    buildProductTile(product, _cart),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRCodePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage(cart: _cart)),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Qrcode',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Bill',
          ),
        ],
      ),
    );
  }

  Widget buildProductTile(Product product, Cart cart) {
    return Card(
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            title: Text(product.title),
            subtitle: Text(product.subtitle),
            leading: Image.network(
              product.imageUrl,
              height: 80,
              width: 80,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (product.stock > 0) {
                      cart.add(product);
                      product.stock--;

                      updateStock(product.title, 1);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.title} added to the cart'),
                        ),
                      );
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No more stock for ${product.title}'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateStock(String productId, int quantity) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/update_stock'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      print('Stock updated successfully');
    } else {
      print('Failed to update stock');
    }
  }
}

class QRCodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String imageUrl = 'https://i.imgur.com/2IaePHC.jpg';

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          height: 300.0,
          width: 300.0,
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final Cart cart;

  CartPage({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = cart.items[index];
                return ListTile(
                  title: Text(cartItem.product.title),
                  subtitle: Text(
                      'Quantity: ${cartItem.quantity}, Total: \$${cartItem.totalPrice.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Quantity: ${cart.totalQuantity}, Total Price: \$${cart.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Cart {
  final List<CartItem> _items = [];
  final BuildContext context;

  Cart({required this.context});

  List<CartItem> get items => _items;

  int get totalQuantity => _items.fold(0, (total, item) => total + item.quantity);

  double get totalPrice => _items.fold(0, (total, item) => total + item.totalPrice);

  void add(Product product) {
    final existingItem = _items.firstWhere(
          (item) => item.product == product,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity < product.stock) {
      existingItem.quantity++;
      existingItem.totalPrice = existingItem.quantity * product.price;

      if (!_items.contains(existingItem)) {
        _items.add(existingItem);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No more stock for ${product.title}'),
        ),
      );
    }
  }
}

class CartItem {
  final Product product;
  int quantity;
  double totalPrice;

  CartItem({
    required this.product,
    required this.quantity,
    this.totalPrice = 0,
  });
}

class Product {
  final String title;
  final String imageUrl;
  double price;
  int stock;

  Product({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.stock,
  });

  String get subtitle => 'Price: \$${this.price} | Stocks Left: ${this.stock}';
}

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: usernameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final enteredUsername = usernameController.text;
                    final enteredPassword = passwordController.text;

                    final user = registeredUsers.firstWhere(
                          (user) => user['username'] == enteredUsername,
                      orElse: () => <String, String>{},
                    );

                    if (user.isNotEmpty && user['password'] == enteredPassword) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid username or password.'),
                        ),
                      );
                    }
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  'New user? Register here',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Register',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              _selectedImage != null
                  ? Image.file(
                _selectedImage!,
                height: 100,
                width: 100,
              )
                  : Container(),
              ElevatedButton(
                onPressed: () async {
                  await _getImage();
                },
                child: Text('Select Image'),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: fullNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: usernameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Choose a username',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Choose a password',
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    registeredUsers.add({
                      'username': usernameController.text,
                      'password': passwordController.text,
                      'imagePath': _selectedImage?.path ?? '',

                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}