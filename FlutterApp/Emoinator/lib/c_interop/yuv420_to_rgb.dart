import 'dart:ffi';
import 'dart:io';

typedef _ConvertFunc = Pointer<Uint32> Function(Pointer<Uint32>, Pointer<Uint8>,
    Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);

typedef Convert = Pointer<Uint32> Function(Pointer<Uint32>, Pointer<Uint8>, Pointer<Uint8>,
    Pointer<Uint8>, int, int, int, int);

final DynamicLibrary convertImageLib = Platform.isAndroid
    ? DynamicLibrary.open("libconvertImage.so")
    : DynamicLibrary.process();

// Load the convertImage() function from the library
Convert yuvToRGB = convertImageLib
    .lookup<NativeFunction<_ConvertFunc>>('convertImage')
    .asFunction<Convert>();
