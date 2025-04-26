import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../UserModel/User_Model.dart';
import '../../../data/Local/SharedKeys.dart';
import '../../../data/Local/SharedPerfrence.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of(context);

  // Sign-up form properties
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  late final TextEditingController signUpEmailController =
      TextEditingController();
  final TextEditingController signUpPasswordController =
      TextEditingController();
  final TextEditingController signUpConfirmPasswordController =
      TextEditingController();

  // Sign-in form properties
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  final TextEditingController signInEmailController = TextEditingController();
  final TextEditingController signInPasswordController =
      TextEditingController();

  UserModel? user;
  String currentUid = "";

  Future<void> signUpWithFire() async {
    emit(AuthLoading());
    debugPrint("⚡ AuthCubit: Starting signUpWithFire");

    try {
      // Validate password match first
      if (signUpPasswordController.text !=
          signUpConfirmPasswordController.text) {
        debugPrint("⚡ AuthCubit: Passwords don't match");
        emit(AuthError("Passwords do not match"));
        return;
      }

      debugPrint("⚡ AuthCubit: Creating user with Firebase");
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: signUpEmailController.text.trim(),
            password: signUpPasswordController.text.trim(),
          );

      debugPrint(
        "⚡ AuthCubit: User created successfully: ${userCredential.user?.uid}",
      );

      // Store the user's authentication data locally
      storeDataFirebase(userCredential);

      // Skip Firestore completely for now
      // We'll just use the authentication data

      // Important: Emit success state with the user
      debugPrint("⚡ AuthCubit: Emitting AuthSuccess state");
      emit(AuthSuccess(userCredential.user!));
      debugPrint("⚡ AuthCubit: AuthSuccess state emitted");
    } catch (error) {
      debugPrint("⚡ AuthCubit: Error during signup: $error");
      emit(AuthError(mapFirebaseError(error.toString())));
    }
  }

  Future<void> signInWithFire() async {
    emit(AuthLoading());
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: signInEmailController.text.trim(),
            password: signInPasswordController.text.trim(),
          );
      storeDataFirebase(userCredential);
      emit(AuthSuccess(userCredential.user!));
    } catch (error) {
      emit(AuthError(mapFirebaseError(error.toString())));
    }
  }

  // This method is now a no-op - it doesn't actually try to access Firestore
  Future<void> addUserToFireStore(UserCredential userCredential) async {
    // Do nothing - we're bypassing Firestore completely
    return;
  }

  void storeDataFirebase(UserCredential value) {
    debugPrint("⚡ AuthCubit: Using StoreDataFirebase");
    LocalData.setData(key: SharedKey.uid, value: value.user?.uid);
    LocalData.setData(key: SharedKey.email, value: value.user?.email);
    LocalData.setData(key: SharedKey.isLogin, value: true);
  }

  Future<void> getUserInfoFire() async {
    emit(GetUserInfoLoading());
    try {
      final uid = LocalData.getData(key: SharedKey.uid);
      final email = LocalData.getData(key: SharedKey.email);

      if (uid == null) {
        emit(GetUserInfoError('No user ID found'));
        return;
      }

      // Create user model directly from local data
      // Skip Firestore completely
      if (email != null) {
        user = UserModel(email: email);
        currentUid = uid;
        emit(GetUserInfoSuccess());
      } else {
        emit(GetUserInfoError('User email not found'));
      }
    } catch (e) {
      emit(GetUserInfoError('Failed to get user info: $e'));
    }
  }

  Future<void> signOut() async {
    emit(SignOutLoading());
    try {
      await FirebaseAuth.instance.signOut();
      LocalData.clearData();
      emit(SignOutSuccess());
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  String mapFirebaseError(String error) {
    if (error.contains('email-already-in-use')) {
      return 'This email is already registered';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('user-not-found') ||
        error.contains('wrong-password')) {
      return 'Invalid email or password';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak';
    } else {
      return 'An error occurred: $error';
    }
  }

  void clearControllers() {
    signUpEmailController.clear();
    signUpPasswordController.clear();
    signUpConfirmPasswordController.clear();
    signInEmailController.clear();
    signInPasswordController.clear();
  }

  @override
  Future<void> close() {
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    signInEmailController.dispose();
    signInPasswordController.dispose();
    return super.close();
  }
}
