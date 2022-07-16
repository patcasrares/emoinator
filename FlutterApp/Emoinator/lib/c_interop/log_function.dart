import 'dart:developer';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

void _wrappedPrint(Pointer<Utf8> arg){
  log(
    arg.toDartString(),
    name: 'CascadeClassifier',
    time: DateTime.now(),
  );
}
typedef _WrappedPrintFunc = Void Function(Pointer<Utf8> a);

final loggerPointer = Pointer.fromFunction<_WrappedPrintFunc>(_wrappedPrint);