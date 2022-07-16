import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

final DynamicLibrary detectFacesLib = Platform.isAndroid
    ? DynamicLibrary.open("libcv_detect.so")
    : DynamicLibrary.process();


typedef _InitDetectionFunc = Pointer<Uint32> Function(Pointer logFunction, Pointer<Utf8> filename);
typedef _InitDetection = Pointer<Uint32> Function(Pointer logFunction, Pointer<Utf8> filename);
_InitDetection initDetection = detectFacesLib
    .lookup<NativeFunction<_InitDetectionFunc>>('initDetection')
    .asFunction<_InitDetection>();

typedef _DetectFunc = Pointer<Uint32> Function(Pointer<Uint32>, Int32, Int32, Pointer<Uint32>);
typedef Detect = Pointer<Uint32> Function(Pointer<Uint32>, int, int, Pointer<Uint32>);
Detect detectFaces = detectFacesLib
    .lookup<NativeFunction<_DetectFunc>>('detectFaces')
    .asFunction<Detect>();

typedef _FreeFunc = Pointer<Uint32> Function(Pointer<Uint32>);
typedef Free = Pointer<Uint32> Function(Pointer<Uint32>);
Free free = detectFacesLib
    .lookup<NativeFunction<_FreeFunc>>('freeBuffer')
    .asFunction<Free>();