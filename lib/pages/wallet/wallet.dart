import 'dart:convert';
import 'package:animate_do/animate_do.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class Wallet extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (amount, unitPrice)
  final Function(String? amount, String? description)? onSubmitted;

  const Wallet({this.onSubmitted, super.key});

  @override
  State<Wallet> createState() => _SalePageState();
}

class _SalePageState extends State<Wallet> {
  late String amount, description;
  String? amountError, descriptionError;
  bool isLoading = false;
  String selectedLanguage = 'en'; // Default language
  Function(String? amount, String? description)? get onSubmitted =>
      widget.onSubmitted;

  @override
  void initState() {
    super.initState();
    amount = '';
    description = '';
    amountError = null;
    descriptionError = null;
    loadLanguagePreference();
  }

  Future<void> loadLanguagePreference() async {
    final box = GetStorage();
    setState(() {
      selectedLanguage = box.read('language') ?? 'en';
    });
  }

  void resetErrorText() {
    setState(() {
      amountError = null;
      descriptionError = null;
    });
  }

  String localize(String enText, String nyText) {
    return selectedLanguage == 'en' ? enText : nyText;
  }

  bool validate() {
    resetErrorText();
    bool isValid = true;
    if (amount.isEmpty) {
      setState(() {
        amountError =
            localize('Amount is required', 'Mukuyenera kulowetsa ndalama');
      });
      isValid = false;
    }
    if (description.isEmpty) {
      setState(() {
        descriptionError = localize(
          'Please enter your product description',
          'Chonde lowetsani chiyambi cha malonda anu',
        );
      });
      isValid = false;
    }
    return isValid;
  }

  Future<void> submit() async {
    final storage = GetStorage();
    String? token = storage.read('token'); // Retrieve the token
    if (token == null || token.isEmpty) {
      // Show error if token is missing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                child: Text(localize(
                  'Authentication token not found. Please log in again.',
                  'Sipezeka chizindikiritso chanu chobvomereza. Chonde lowaninso.',
                )),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (validate()) {
      setState(() {
        isLoading = true;
      });

      var url =
          Uri.parse('${apiurl}v1/loans/apply'); // Ensure apiurl is correct
      try {
        var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Correct key for authorization
          },
          body: jsonEncode({
            'amount_requested': amount,
            'reason': description,
          }),
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          var loan = responseBody['loan'];
          String dateApplied = loan['date_applied'] ?? 'Unknown';

          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      localize(
                        'Loan successfully applied on $dateApplied.',
                        'Ngongole yanu yalembetsedwa bwino pa $dateApplied.',
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          var responseBody = jsonDecode(response.body);
          String errorMessage = responseBody['error'] ?? 'An error occurred';

          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(errorMessage),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        // Show error snackbar for unexpected exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 10),
                Expanded(
                  child: Text(localize(
                    'An error occurred. Please try again.',
                    'Pachitika cholakwika. Chonde yesaninso.',
                  )),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // void submit() {
  //   if (validate()) {
  //     if (onSubmitted != null) {
  //       onSubmitted!(amount, description);
  //     }
  //   }
  //   QuickAlert.show(
  //     context: context,
  //     type: QuickAlertType.success,
  //     title: 'Successfully Submited',
  //     text: 'Your Loan has Successfully submitted and waiting for approval!',
  //     showConfirmBtn: true,
  //     confirmBtnText: 'OK',
  //     onConfirmBtnTap: () {
  //       Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) => BaseScreen()),
  //         (Route<dynamic> route) => false,
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: kPrimaryColor,
            expandedHeight: 150.0,
            pinned: true,
            flexibleSpace: const FlexibleSpaceBar(
              stretchModes: [StretchMode.zoomBackground],
              centerTitle: true,
              title: const Text(
                'Mlimi Wallet',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: Color.fromARGB(255, 235, 255, 234),
                ),
              ),
            ),
            leading: IconButton(
              icon: SvgPicture.asset(
                "assets/icons/back.svg",
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    margin: const EdgeInsets.only(top: 0.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.center,
                              heightFactor:
                                  0.4, // Adjust this value to display the center part
                              child: Lottie.asset(
                                'assets/icons/wallet.json', // Replace with your Lottie file path
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            localize(
                              'Enter the amount of money you would like to get as a loan and the purpose for getting a loan',
                              'Lowetsani ndalama zomwe mukufuna kubwereka ndi cholinga chanu chobwerekera',
                            ),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(.6),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * .025),
                        Text(
                          localize('Amount Requested', 'Ndalama Zofunikira'),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        InputField(
                          onChanged: (value) {
                            setState(() {
                              amount = value;
                            });
                          },
                          errorText: amountError,
                          textInputAction: TextInputAction.next,
                          autoFocus: true,
                        ),
                        SizedBox(height: screenHeight * .025),
                        Text(
                          localize('Purpose', 'Cholinga'),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              description = value;
                            });
                          },
                          onSubmitted: (value) => submit(),
                          maxLines: null,
                          minLines: 3,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: localize(
                              'Enter description',
                              'Lowetsani mafotokozedwe',
                            ),
                            errorText: descriptionError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * .055),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: submit,
                              icon: const Icon(Icons.check),
                              label: Text(localize('Submit', 'Tumizani')),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.cancel),
                              label: Text(localize('Cancel', 'Letsani')),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * .04),
                      ],
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FormButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  const FormButton({this.text = '', this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: onPressed as void Function()?,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: screenHeight * .02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String? labelText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final bool obscureText;
  const InputField({
    this.labelText,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autoFocus = false,
    this.obscureText = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autoFocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
