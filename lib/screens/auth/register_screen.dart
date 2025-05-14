import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedGender = 'Female';
  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  late AnimationController _emailShakeController;
  late AnimationController _passwordShakeController;
  late Animation<double> _emailOffsetAnimation;
  late Animation<double> _passwordOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _emailShakeController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _passwordShakeController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _emailOffsetAnimation = Tween<double>(begin: 0, end: 10).chain(CurveTween(curve: Curves.elasticIn)).animate(_emailShakeController);
    _passwordOffsetAnimation = Tween<double>(begin: 0, end: 10).chain(CurveTween(curve: Curves.elasticIn)).animate(_passwordShakeController);
  }

  @override
  void dispose() {
    _emailShakeController.dispose();
    _passwordShakeController.dispose();
    super.dispose();
  }

  bool isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email);
  }

  bool isPasswordStrong(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$').hasMatch(password);
  }

  Future<void> _register() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    String name = _nameController.text.trim();
    String dob = _dobController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String gender = _selectedGender;

    if (name.isEmpty || dob.isEmpty || email.isEmpty || password.isEmpty || gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    bool valid = true;

    if (!isEmailValid(email)) {
      _emailError = "Enter a valid email address";
      _emailShakeController.forward(from: 0);
      valid = false;
    }

    if (!isPasswordStrong(password)) {
      _passwordError = "Password must have upper, lower, number, and 6+ characters";
      _passwordShakeController.forward(from: 0);
      valid = false;
    }

    if (!valid) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DatabaseReference usersRef = _dbRef.child('users');
      DataSnapshot snapshot = await usersRef.get();

      bool emailExists = false;
      if (snapshot.exists) {
        Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;
        users.forEach((key, value) {
          if (value['email'] == email) {
            emailExists = true;
          }
        });
      }

      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email already registered')),
        );
      } else {
        await usersRef.push().set({
          'name': name,
          'dob': dob,
          'gender': gender,
          'email': email,
          'password': password,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful')),
        );

        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (error) {
      print('Registration Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDOB(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime(2015),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 78, 149, 200), Color.fromARGB(255, 133, 169, 220)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF244C98),
                    ),
                  ),
                  Text(
                    'Join us by filling the details below!',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(_nameController, 'Full Name', Icons.person),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectDOB(context),
                    child: AbsorbPointer(
                      child: _buildTextField(_dobController, 'Date of Birth', Icons.calendar_today),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Gender',
                      prefixIcon: Icon(Icons.person_outline),
                      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _emailShakeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_emailOffsetAnimation.value, 0),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            errorText: _emailError,
                            prefixIcon: Icon(Icons.email),
                            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: _emailError != null ? Colors.red : Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: _emailError != null ? Colors.red : Colors.blueAccent, width: 2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _passwordShakeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_passwordOffsetAnimation.value, 0),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            errorText: _passwordError,
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: _passwordError != null ? Colors.red : Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: _passwordError != null ? Colors.red : Colors.blueAccent, width: 2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  _isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _register,
                            child: Text(
                              'Register',
                              style: GoogleFonts.lexend(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF244C98),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      'Already have an account? Login',
                      style: GoogleFonts.lexend(
                        color: const Color(0xFF244C98),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}
