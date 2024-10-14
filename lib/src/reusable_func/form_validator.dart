import 'package:get/get.dart';

class FormValidator {
  static String? validateEmail(String? value) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';

    if (value == null || value.isEmpty) {
      return (locale == 'en'
          ? 'Please enter your email.'
          : 'Mohon masukkan email Anda.');
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      return (locale == 'en'
          ? 'Please enter a valid email address.'
          : 'Mohon masukkan alamat email yang valid.');
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';

    if (value == null || value.isEmpty) {
      return (locale == 'en'
          ? 'Please enter your password.'
          : 'Mohon masukkan kata sandi Anda.');
    } else if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return (locale == 'en'
          ? 'Password must contains non-numerical character(s).'
          : 'Kata sandi harus mengandung karakter non-numerik.');
    } else if (value.length < 8) {
      return (locale == 'en'
          ? 'Password must be at least 8 characters long.'
          : 'Kata sandi harus memiliki panjang minimal 8 karakter.');
    }
    return null;
  }

  static String? validateRePassword(String? password, String? retypePassword) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';

    if (retypePassword == null || retypePassword.isEmpty) {
      return locale == 'en'
          ? 'Please re-enter your password.'
          : 'Mohon masukkan ulang kata sandi Anda.';
    } else if (retypePassword != password) {
      return locale == 'en'
          ? 'Passwords do not match.'
          : 'Kata sandi tidak sama.';
    }
    return null;
  }

  static String? validateName(String? value) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    if (value == null || value.isEmpty) {
      return locale == 'en'
          ? 'Please enter your name.'
          : 'Mohon masukkan nama Anda.';
    }
    return null;
  }

  static String? validateTitle(String? value) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    if (value == null || value.isEmpty) {
      return locale == 'en'
          ? 'Please enter something.'
          : 'Mohon masukkan sesuatu.';
    } else if (value.length > 100) {
      return locale == 'en'
          ? 'Please enter the title no more than 100 characters.'
          : 'Mohon masukkan judul tidak lebih dari 100 karakter.';
    }
    return null;
  }

  static String? validateText(String? value) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    if (value == null || value.isEmpty) {
      return locale == 'en'
          ? 'Please enter something.'
          : 'Mohon masukkan sesuatu.';
    }
    return null;
  }

  static String? validatePayment(String? value) {
    final locale = Get.locale?.toLanguageTag() ?? 'en';
    if (value == null || value.isEmpty) {
      return locale == 'en'
          ? 'Please enter something.'
          : 'Mohon masukkan sesuatu.';
    } else if (!RegExp(r'^\d+$').hasMatch(value)) {
      return locale == 'en'
          ? 'Please don\'t enter non-digit character(s).'
          : 'Mohon jangan masukkan karakter non-digit.';
    } else if (int.tryParse(value) == null || int.parse(value) < 1000) {
      return locale == 'en'
          ? 'Please enter value at least 1000.'
          : 'Mohon masukkan nilai minimal 1000.';
    }
    return null;
  }
}
