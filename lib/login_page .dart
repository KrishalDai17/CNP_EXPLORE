import 'package:cnp_navigator/forget_passsword_page.dart';
import 'package:flutter/material.dart';
import 'signup_page1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true; // track password visibility
  final _formKey = GlobalKey<FormState>();

  // Controllers to get input values
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Logo
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF7CFF4E),
                child: Icon(
                  Icons.eco,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),

              // White card container with Form
              Container(
                width: 330,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "CNP EXPLOREE",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phone or Email field with validation
                      TextFormField(
                        controller: phoneController, // keep controller as it is
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Phone Number or Email',
                          hintText: '+977 9800000000 or ram@gmail.com',
                          hintStyle: const TextStyle(
                            fontSize: 10, // smaller hint text
                            color: Colors.grey,
                          ),
                          /*prefixIcon: Row(    //two icons need to be shown so hidden
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(width: 8),
                              Icon(Icons.phone, size:20),
                              SizedBox(width: 6),
                              Icon(Icons.email, size: 20),
                            ],
                          ),*/
                          filled: true,
                          fillColor: const Color(0xFFEFF5EB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number or email';
                          }

                          final input = value.trim();

                          // Nepali phone number
                          final phoneRegex = RegExp(r'^(?:\+977\s?)?\d{10}$');

                          // Gmail email validation
                          final emailRegex = RegExp(r'^[\w.-]+@gmail\.com$');

                          bool isValidPhone = phoneRegex.hasMatch(input);
                          bool isValidEmail = emailRegex.hasMatch(input);

                          if (!isValidPhone && !isValidEmail) {
                            return 'Enter a valid Nepali phone number or Gmail address';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // Password field with validation
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEFF5EB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ForgetPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.green,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Login button with validation check
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              print("Contact/Email: ${phoneController.text}");
                              print("Password: ${passwordController.text}");
                              // TODO: Add login logic (OTP or Firebase)
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7CFF4E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don’t have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupPage1(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
