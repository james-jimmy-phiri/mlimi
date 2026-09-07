import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/pages/product_request/homepage.dart';

/// Screen that receives the OTP entered by the user, verifies it,
/// and then completes registration using the returned [verification_token].
class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final Map<String, dynamic> registrationData;
  final Function(String? name, String? pin)? onRegistered;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.registrationData,
    this.onRegistered,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  // 6 individual OTP digit controllers
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;
  String get _selectedLanguage => GetStorage().read('language') ?? 'en';

  // Resend cooldown
  int _resendCooldown = 60;
  Timer? _resendTimer;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-submit when all 6 digits filled
    if (_otpValue.length == 6) {
      _verifyAndRegister();
    }
  }

  void _shakeError(String message) {
    setState(() => _errorMessage = message);
    _shakeController.forward(from: 0);
  }

  // ──────────────────────────────────────────
  // API Calls
  // ──────────────────────────────────────────

  Future<void> _verifyAndRegister() async {
    final otp = _otpValue;
    if (otp.length != 6) {
      _shakeError(_selectedLanguage == 'en'
          ? 'Please enter the 6-digit code'
          : 'Lowetsani nambala ya manambala 6');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Verify OTP
      print('>>> [OTP] Verifying OTP for phone: ${widget.phone}, otp: $otp');
      final verifyUrl = Uri.parse('${apiurl}v1/auth/verify-otp');
      final verifyResponse = await http.post(
        verifyUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': widget.phone,
          'otp': otp,
        }),
      );

      print('>>> [OTP] verify-otp status: ${verifyResponse.statusCode}');
      print('>>> [OTP] verify-otp body: ${verifyResponse.body}');

      final verifyBody = jsonDecode(verifyResponse.body);

      if (verifyResponse.statusCode != 200) {
        final msg = verifyBody['message'] ??
            (_selectedLanguage == 'en'
                ? 'Invalid or expired code. Try again.'
                : 'Nambala yolakwika kapena yatha. Yesaninso.');
        setState(() => _isVerifying = false);
        _shakeError(msg);
        return;
      }

      final verificationToken = verifyBody['verification_token'];
      if (verificationToken == null) {
        setState(() => _isVerifying = false);
        _shakeError(_selectedLanguage == 'en'
            ? 'Verification failed. Please try again.'
            : 'Kutsimikizira kulephera. Yesaninso.');
        return;
      }

      // Step 2: Register with verification_token
      final registerUrl = Uri.parse('${apiurl}v1/auth/register');
      final registerBody = {
        ...widget.registrationData,
        'verification_token': verificationToken,
      };
      print('>>> [OTP] Registering with body: ${jsonEncode(registerBody)}');

      final registerResponse = await http.post(
        registerUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registerBody),
      );

      print('>>> [OTP] register status: ${registerResponse.statusCode}');
      print('>>> [OTP] register body: ${registerResponse.body}');

      setState(() => _isVerifying = false);

      if (registerResponse.statusCode == 200) {
        final data = jsonDecode(registerResponse.body);
        final token = data['token'];
        final client = data['client'];

        final box = GetStorage();
        box.write('token', token);
        box.write('client_id', client['id']);
        box.write('phone', widget.phone);
        box.write('name', client['name']);
        box.write('district', client['district']);
        box.write('client_type', client['type'] ?? 'individual');

        if (widget.onRegistered != null) {
          widget.onRegistered!(client['name'], null);
        }

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Homepage()),
          (_) => false,
        );
      } else {
        final data = jsonDecode(registerResponse.body);
        final errors = data['errors'] as Map<String, dynamic>?;
        String msg = data['message'] ?? 'Registration failed.';

        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            msg = firstError.first.toString();
          }
        }
        _shakeError(msg);
      }
    } catch (e, st) {
      print('>>> [OTP] Error: $e\n$st');
      setState(() => _isVerifying = false);
      _shakeError(_selectedLanguage == 'en'
          ? 'An error occurred. Please try again.'
          : 'Pali vuto. Yesaninso.');
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0 || _isResending) return;
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      print('>>> [OTP] Resending OTP to ${widget.phone}');
      final url = Uri.parse('${apiurl}v1/auth/request-otp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': widget.phone}),
      );
      print('>>> [OTP] resend status: ${response.statusCode}');
      print('>>> [OTP] resend body: ${response.body}');

      setState(() => _isResending = false);

      if (response.statusCode == 200) {
        _startResendCooldown();
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes.first.requestFocus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_selectedLanguage == 'en'
                ? 'A new code has been sent to ${widget.phone}'
                : 'Nambala yatsopano yatumizidwa kwa ${widget.phone}'),
            backgroundColor: kPrimaryColor,
          ));
        }
      } else {
        final body = jsonDecode(response.body);
        _shakeError(body['message'] ??
            (_selectedLanguage == 'en'
                ? 'Failed to resend code.'
                : 'Kutumiza katsopano kulephera.'));
      }
    } catch (e) {
      setState(() => _isResending = false);
      _shakeError(_selectedLanguage == 'en'
          ? 'An error occurred. Please try again.'
          : 'Pali vuto. Yesaninso.');
    }
  }

  // ──────────────────────────────────────────
  // UI
  // ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lang = _selectedLanguage;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Illustration
              Center(
                child: Lottie.asset(
                  'assets/icons/login.json',
                  width: size.width * 0.45,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                lang == 'en'
                    ? 'Verify Your Number'
                    : 'Tsimikizani Nambala Yanu',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                lang == 'en'
                    ? 'Enter the 6-digit code sent to\n${widget.phone}'
                    : 'Lowetsani nambala ya manambala 6 yotumizidwa kwa\n${widget.phone}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.55),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // OTP boxes with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                    _shakeAnimation.value *
                        ((_shakeController.value < 0.5) ? 1 : -1),
                    0,
                  ),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) => _buildOtpBox(i)),
                ),
              ),

              // Error message
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade600, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyAndRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    disabledBackgroundColor: kPrimaryColor.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          lang == 'en'
                              ? 'Verify & Register'
                              : 'Tsimikizani & Lembani',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Resend row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lang == 'en'
                        ? "Didn't receive the code? "
                        : 'Simunalandire nambala? ',
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.55), fontSize: 13),
                  ),
                  _isResending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  kPrimaryColor)),
                        )
                      : GestureDetector(
                          onTap: _resendCooldown == 0 ? _resendOtp : null,
                          child: Text(
                            _resendCooldown > 0
                                ? (lang == 'en'
                                    ? 'Resend in ${_resendCooldown}s'
                                    : 'Tumizaninso pa ${_resendCooldown}s')
                                : (lang == 'en'
                                    ? 'Resend Code'
                                    : 'Tumizaninso'),
                            style: TextStyle(
                              color: _resendCooldown == 0
                                  ? kPrimaryColor
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              decoration: _resendCooldown == 0
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        width: 46,
        height: 56,
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: _errorMessage != null
                      ? Colors.red.shade300
                      : Colors.grey.shade300,
                  width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
          onChanged: (val) => _onDigitChanged(index, val),
          onTap: () {
            // Clear the field on tap so user can re-enter
            _controllers[index].clear();
          },
        ),
      ),
    );
  }
}
