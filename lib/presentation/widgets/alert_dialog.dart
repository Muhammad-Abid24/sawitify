import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class MyAlertDialog {
  static Future<void> show({
    required BuildContext context,
    required QuickAlertType type,
    required String text,
    String? title,
    String? titleConfirm,
    String? titleCancel,
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
    bool? visibleCancel,
  }) {
    return QuickAlert.show(
      context: context,
      type: type,
      text: text,
      title: title,
      confirmBtnText: titleConfirm ?? 'Okay',
      onConfirmBtnTap: onConfirmBtnTap,
      showCancelBtn: visibleCancel ?? true,
      onCancelBtnTap: onCancelBtnTap,
      cancelBtnText: titleCancel ?? 'Cancel'
    );
  }
}


/*
Cara penggunaan:
AlertDialog.show(
context: context,
type: QuickAlertType.success,
text: 'Sukses',
);

// Atau dengan parameter tambahan:
AlertDialog.show(
context: context,
type: QuickAlertType.confirm,
title: 'Konfirmasi',
text: 'Apakah Anda yakin?',
onConfirmBtnTap: () {
// aksi konfirmasi
},
onCancelBtnTap: () {
Navigator.pop(context);
},
);*/
