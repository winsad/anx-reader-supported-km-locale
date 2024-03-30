import 'dart:io';
import 'package:anx_reader/dao/Book.dart';
import 'package:epub_view/epub_view.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/importBook.dart';

class Book {
  late int id;
  late String title;
  late String coverPath;
  late String filePath;
  late String lastReadPosition;
  late String author;
  String? description;

  Book.byFile(File file) {
    id = -1;
    title = '';
    coverPath = '';
    filePath = '';
    lastReadPosition = '';
    author = '';
    description = '';
    _initializeBook(file);
  }

  Book(
      {required this.id,
      required this.title,
      required this.coverPath,
      required this.filePath,
      required this.lastReadPosition,
      required this.author,
      this.description});

  Future<void> _initializeBook(File file) async {
    EpubBook epubBookRef = await EpubDocument.openFile(file);
    author = epubBookRef.Author ?? 'Unknown Author';
    title = epubBookRef.Title ?? 'Unknown';
    final cover = epubBookRef.CoverImage;
    final newDirName = '$title - $author';
    final newFileName = '$newDirName.epub';

    Directory appDocDir = await getApplicationDocumentsDirectory();
    final subDir = Directory('${appDocDir.path}/$newDirName');
    await subDir.create(recursive: true);

    final savePath = '${subDir.path}/$newFileName';
    final coverPath = '${subDir.path}/cover.png';

    await file.copy(savePath);
    filePath = savePath;

    saveImageToLocal(cover!, coverPath);
    this.coverPath = coverPath;

    lastReadPosition = '';
    Future<int> id = insertToSql();
    this.id = id as int;
  }

  Map<String, Object?> toMap() {
    return {
      'title': title,
      'cover_path': coverPath,
      'file_path': filePath,
      'last_read_position': lastReadPosition,
      'author': author,
      'description': description,
    };
  }

  Future<int> insertToSql() async {
    return await insertBook(this);
  }
}
