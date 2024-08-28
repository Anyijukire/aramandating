import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dating_app/dialogs/progress_dialog.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/blocked_account_screen.dart';
import 'package:dating_app/screens/home_screen.dart';
import 'package:dating_app/screens/sign_up_screen.dart';
import 'package:dating_app/screens/update_location_sceen.dart';
import 'package:dating_app/screens/verification_code_screen.dart';
import 'package:dating_app/widgets/default_button.dart';
import 'package:dating_app/widgets/show_scaffold_msg.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shimmer/shimmer.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({Key? key}) : super(key: key);

  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  // Variables
  final _formKey = GlobalKey<FormState>();
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _numberController = TextEditingController();
  String? _phoneCode = '+256'; // Define yor default phone code
  final String _initialSelection = 'UG'; // Define yor default country code
  late AppLocalizations _i18n;
  late ProgressDialog _pr;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);

    return Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          title: Text(_i18n.translate("phone_number")),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor,
                child: const SvgIcon("assets/icons/call_icon.svg",
                    width: 60, height: 60, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text("Enter your Phone Number",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 25),
              const Text(
                  "It's easier to match with someone when you share your phone number.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 22),

              /// Form
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _numberController,
                      decoration: InputDecoration(
                          labelText: _i18n.translate("phone_number"),
                          hintText: _i18n.translate("enter_your_number"),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: CountryCodePicker(
                                alignLeft: false,
                                initialSelection: _initialSelection,
                                onChanged: (country) {
                                  /// Get country code
                                  _phoneCode = country.dialCode!;
                                }),
                          )),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                      ],
                      validator: (number) {
                        // Basic validation
                        if (number == null || number.isEmpty) {
                          return _i18n
                              .translate("please_enter_your_phone_number");
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.maxFinite,
                      child: DefaultButton(
                        child: Text(_i18n.translate("CONTINUE"),
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white)),
                        onPressed: () async {
                          /// Validate form
                          if (_formKey.currentState!.validate()) {
                            /// Sign in
                            _signIn(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }



  /// Navigate to next page
  void _nextScreen(screen) {
    // Go to next page route
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => screen), (route) => false);
    });
  }

  /// Helper function to show ScaffoldMessenger message
  void showScaffoldMessage({
    required BuildContext context,
    required String message,
    required Color bgcolor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: bgcolor,
    ));
  }
  /// Function to check if the user exists by phone number
  Future<DocumentSnapshot?> _checkIfUserExists(String phoneNumber) async {
    try {
      // Reference to the 'Users' collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');

      // Query to check if the user exists
      QuerySnapshot querySnapshot =
          await users.where('user_phone_number', isEqualTo: phoneNumber).get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      } else {
        return null;
      }
    } catch (e) {
       debugPrint("Error checking user existence: $e");
      return null;
    }
  }
  /// Function to migrate user data from old document to new document
  Future<void> _handleGoogleSignInAndMigrateUser(
      DocumentSnapshot oldUserDoc) async {
    try {
      // Assuming the user is already signed in with Google and their UID is available
      User? googleUser = FirebaseAuth.instance.currentUser;

      if (googleUser != null) {
        // Reference to the 'Users' collection
        CollectionReference users =
            FirebaseFirestore.instance.collection('Users');

        // Create a new document with the UID returned by Google
        DocumentReference newUserDoc = users.doc(googleUser.uid);

        // Copy all fields from the old document to the new one
        await newUserDoc.set({
          ...oldUserDoc.data() as Map<String, dynamic>,
          'isGoogleVerified': true, // Add the boolean value
        });

        // Delete the old document
        await oldUserDoc.reference.delete();

        // Show success message
        showScaffoldMessage(
            context: context,
            message: "User data migrated successfully.",
            bgcolor: Colors.green);

        // Proceed with further authentication or app flow
        await UserModel().authUserAccount(
            updateLocationScreen: () =>
                _nextScreen(const UpdateLocationScreen()),
            signUpScreen: () => _nextScreen(const SignUpScreen()),
            homeScreen: () => _nextScreen(const HomeScreen()),
            blockedScreen: () => _nextScreen(const BlockedAccountScreen()));
      } else {
        // Handle the case where the Google user is not found (unlikely if Google Auth was handled correctly)
        showScaffoldMessage(
            context: context,
            message: "Google user not found.",
            bgcolor: Colors.red);
      }
    } catch (e) {
       debugPrint("Error migrating user data: $e");
      showScaffoldMessage(
          context: context,
          message: "An error occurred during data migration.",
          bgcolor: Colors.red);
    }
  }

  /// Function to create a new user document
  Future<void> _createNewUser(String phoneNumber, BuildContext context) async {
    try {
      // Get the current Firebase user
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // Reference to the 'Users' collection
        CollectionReference users =
            FirebaseFirestore.instance.collection('Users');

        // Create a new document with the UID returned by Firebase Auth
        DocumentReference newUserDoc = users.doc(firebaseUser.uid);

        // Define the user data
        Map<String, dynamic> userData = {
          'user_phone_number': phoneNumber,
          'isGoogleVerified': true, // Set this to true if Google Auth is done
          'email': firebaseUser.email, // Get from Firebase user object
          'name': firebaseUser.displayName, // Get from Firebase user object
          // Add other fields as necessary
        };

        // Create the new user document
        await newUserDoc.set(userData);

        // Show success message
        showScaffoldMessage(
            context: context,
            message: "User account created successfully.",
            bgcolor: Colors.green);

        // Redirect to the desired screen, e.g., home screen
        _nextScreen(const  SignUpScreen());
      } else {
        // Handle the case where the Firebase user is not found (unlikely after auth)
        showScaffoldMessage(
            context: context,
            message: "Unable to create user account.",
            bgcolor: Colors.red);
      }
    } catch (e) {
       debugPrint("Error creating new user: $e");
      showScaffoldMessage(
          context: context,
          message: "An error occurred while creating the user account.",
          bgcolor: Colors.red);
    }
  }

  void _signIn(BuildContext context) async {
    try {
      // Show progress dialog
      _pr.show(_i18n.translate("processing"));

      // Get the full phone number and remove leading zero if present
      String phoneNumber = _numberController.text.trim();
      if (phoneNumber.startsWith('0')) {
        phoneNumber = phoneNumber.substring(1); // Remove leading zero
      }
      phoneNumber = _phoneCode! + phoneNumber;
      debugPrint(phoneNumber);

      // Perform the search for the phone number
      DocumentSnapshot? userDoc = await _checkIfUserExists(phoneNumber);

      // Hide the progress dialog
      _pr.hide();

      if (userDoc != null) {
        // Show success message if the user exists
        showScaffoldMessage(
            context: context,
            message: "User with phone number $phoneNumber found.",
            bgcolor: Colors.green);

        // Check if the user is already Google verified or if the field is missing
        if (userDoc.data() != null &&
            (userDoc.data() as Map<String, dynamic>)
                .containsKey('isGoogleVerified')) {
          bool isGoogleVerified = userDoc.get('isGoogleVerified');

          if (isGoogleVerified) {
            // User is already Google verified, proceed to authentication
            await UserModel().authUserAccount(
                updateLocationScreen: () =>
                    _nextScreen(const UpdateLocationScreen()),
                signUpScreen: () => _nextScreen(const SignUpScreen()),
                homeScreen: () => _nextScreen(const HomeScreen()),
                blockedScreen: () => _nextScreen(const BlockedAccountScreen()));
          } else {
            // User is not yet Google verified, proceed with migration
            await _handleGoogleSignInAndMigrateUser(userDoc);
          }
        } else {
          // Field does not exist, proceed with migration
          await _handleGoogleSignInAndMigrateUser(userDoc);
        }
      } else {
        // Show error message if the user does not exist
        await _createNewUser(phoneNumber, context);
      }
    } catch (e) {
      debugPrint("Error signing in: $e");
      showScaffoldMessage(
          context: context,
          message: "An error occurred while signing in.",
          bgcolor: Colors.red);
    }
  }

}

class GoogleSignin extends StatefulWidget {
  @override
  _GoogleSigninState createState() => _GoogleSigninState();
}

class _GoogleSigninState extends State<GoogleSignin> {
   bool _isLoading = false;

  Future<User?> _signInWithGoogle({required BuildContext context}) async {
    setState(() {
      _isLoading = true;
    });

    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PhoneNumberScreen()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable back navigation
      ),
      body: _isLoading
          ? Center(child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 200,
                height: 20,
                color: Colors.grey,
              ),
            ))
          : Center(
              // This centers the button
              child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Signing you in...'),
                  ),
                );
                _signInWithGoogle(context: context);
              },
              child: Text('Continue with Google'),
            )),
    );
  }
}




