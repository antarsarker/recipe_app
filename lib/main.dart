import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true; // State to toggle between login and signup

  @override
  Widget build(BuildContext context) {
    // Building the login/signup page without the image
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Removed the image widget to avoid asset loading issues

              SizedBox(height: 20),
              Text(
                _isLogin ? 'Login' : 'Sign Up',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Text color matching the theme
                ),
              ),
              SizedBox(height: 30),
              _buildTextField(_emailController, 'Email', Icons.email),
              SizedBox(height: 15),
              _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: true),
              SizedBox(height: 30),
              _buildAuthButton(),
              SizedBox(height: 15),
              _buildToggleText(),
            ],
          ),
        ),
      ),
    );
  }

  // Build TextFields for Email and Password with Icons
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green), // Leading icon in textfield
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none, // No border for cleaner look
        ),
      ),
    );
  }

  // Build Login/Signup Button
  Widget _buildAuthButton() {
    return ElevatedButton(
      onPressed: _isLogin ? _login : _signUp,
      child: Text(
        _isLogin ? 'Login' : 'Sign Up',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50), // Button width matches the screen width
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.green, // Button color
      ),
    );
  }

  // Build the Text for switching between Login and Sign Up
  Widget _buildToggleText() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
      child: Text(
        _isLogin ? 'Create an account' : 'Already have an account?',
        style: TextStyle(color: Colors.green, fontSize: 16),
      ),
    );
  }

  // Core login function (unchanged)
  void _login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPassword = prefs.getString(_emailController.text);

    if (storedPassword != null && storedPassword == _passwordController.text) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardPage(email: _emailController.text)),
      );
    } else {
      _showError('Invalid email or password');
    }
  }

  // Core signup function (unchanged)
  void _signUp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_emailController.text, _passwordController.text);
    // Initialize orders for new user
    prefs.setStringList('${_emailController.text}_orders', []);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => DashboardPage(email: _emailController.text)),
    );
  }

  // Core error display function (unchanged)
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }
}

// Dashboard and Profile page implementations remain unchanged

class DashboardPage extends StatefulWidget {
  final String email;

  DashboardPage({required this.email});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<String> foodItems = ['Pizza', 'Burger', 'Pasta', 'Sushi', 'Salad', 'Tacos', 'Steak', 'Ice Cream'];
  List<int> ordersCount = List.filled(8, 0); // To track orders for each food item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ProfilePage(email: widget.email)),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
        ),
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(foodItems[index], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ordersCount[index]++;
                    });
                    _saveOrder(foodItems[index]);
                  },
                  child: Text('Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Change made here
                  ),
                ),
                Text('Ordered: ${ordersCount[index]} times'),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveOrder(String foodItem) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? existingOrders = prefs.getStringList('${widget.email}_orders');
    existingOrders ??= [];
    existingOrders.add(foodItem);
    await prefs.setStringList('${widget.email}_orders', existingOrders);
  }
}

class ProfilePage extends StatelessWidget {
  final String email;

  ProfilePage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: FutureBuilder<List<String>>(
          future: _getOrders(email),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error loading orders');
            } else {
              List<String> orders = snapshot.data ?? [];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Email: $email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text('Previous Orders:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  if (orders.isEmpty)
                    Text('No orders placed yet.')
                  else
                    ...orders.map((order) => Text(order)).toList(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Logout functionality
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Change made here for logout button
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<String>> _getOrders(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('${email}_orders') ?? [];
  }
}
