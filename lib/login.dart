import 'package:flutter/material.dart';
import 'package:hedieaty/signup.dart';
import '/controllers/authentication_controller.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = AuthController();

  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final user = await authController.logIn(
      emailController.text,
      passwordController.text,
    );

    if (user != null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.card_giftcard, color: Colors.green, size: 30),
            SizedBox(width: 8), // Space between icon and title
            Text('Hedieaty', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the column
            children: [
              SizedBox(height: 40),
              Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // Center the text
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text(
                        'Log In',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        textStyle: TextStyle(fontSize: 25),
                        backgroundColor: Colors.green, // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                child: Text(
                  'Don\'t have an account? Sign Up',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}