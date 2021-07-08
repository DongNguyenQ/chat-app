import 'dart:io';

import 'package:chat_app/core/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class FileService {
  Future<Either<Failure, String>> uploadFile(File file, String fileName);
}

class FileServiceImpl extends FileService {

  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<Either<Failure, String>> uploadFile(File file, String fileName) async {
    try {
      Reference reference = _storage.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();
      if (imageUrl == null || imageUrl.length == 0) {
        throw Exception('No image url found');
      }
      return Right(imageUrl);
    } on FirebaseException catch (e) {
      return Left(Failure('FIREBASE ERROR : ' + e.message!));
    } catch (e) {
      return Left(Failure('UNDETECTED ERROR : ' + e.toString()));
    }
  }
}