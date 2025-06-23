import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _dbRef = FirebaseDatabase.instance.ref();

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
    _emailOffsetAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_emailShakeController);
    _passwordOffsetAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_passwordShakeController);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
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

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      await _dbRef.child('users').child(uid).set({
        'name': name,
        'dob': dob,
        'gender': gender,
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful')));
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';
      if (e.code == 'email-already-in-use') {
        message = 'Email already registered';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      print('Registration Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unexpected error occurred')));
    }

    setState(() => _isLoading = false);
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
    const gradientStart = Color.fromARGB(255, 78, 149, 200);
    const gradientEnd = Color.fromARGB(255, 133, 169, 220);
    const primaryBlue = Color(0xFF244C98);

    InputDecoration buildInputDecoration(String hint, IconData icon, {String? errorText, Widget? suffixIcon}) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: errorText != null ? Colors.red : primaryBlue, width: 2),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
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
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join us by filling the details below!',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Name
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: buildInputDecoration('Full Name', Icons.person),
                  ),
                  const SizedBox(height: 16),

                  // DOB with date picker
                  GestureDetector(
                    onTap: () => _selectDOB(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dobController,
                        style: const TextStyle(color: Colors.white),
                        decoration: buildInputDecoration('Date of Birth', Icons.calendar_today),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    dropdownColor: gradientEnd,
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender, style: const TextStyle(color: Colors.white)),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Gender',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email field with shake animation
                  AnimatedBuilder(
                    animation: _emailShakeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_emailOffsetAnimation.value, 0),
                        child: TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: buildInputDecoration('Email', Icons.email, errorText: _emailError),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field with shake animation
                  AnimatedBuilder(
                    animation: _passwordShakeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_passwordOffsetAnimation.value, 0),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: buildInputDecoration(
                            'Password',
                            Icons.lock,
                            errorText: _passwordError,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                        shadowColor: primaryBlue.withOpacity(0.5),
                      ),
                      child: Text(
                        'Register',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      'Already have an account? Login',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
