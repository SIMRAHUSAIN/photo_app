// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_null_comparison, avoid_print, unused_catch_clause, unused_element, sized_box_for_whitespace

import 'dart:io';
import 'package:demo_app/detail_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late File image;
  final picker = ImagePicker();
 final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  
  _upload() async {
   XFile? pickedImage = await picker.pickImage(
      source: ImageSource.camera,
    );
   File imageFile = File(pickedImage!.path);
   final String fileName = basename(pickedImage.path);

   try{
     
      await _firebaseStorage.ref(fileName).putFile(
       imageFile,
     );
     
     setState(() {
       
     });
   }on FirebaseException catch (error) {
     if(kDebugMode) {
       print(error.toString());
     }
   }
   catch(err) {
     if(kDebugMode) {
       print(err.toString());
     }
   }
  }

  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await _firebaseStorage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      print("==imageurl==>" +fileUrl);
      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl.toString(),
        "path": file.fullPath,
        "date": DateFormat.yMMMd().format(DateTime.now()),
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description'
      });
    });

    return files;
  }

  Future<void> _delete(String ref) async {
    await _firebaseStorage.ref(ref).delete();
  
    setState(() {});
  }


  
  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: const Text("Photo App", style: TextStyle(color: Colors.white),),
         centerTitle: true,
         backgroundColor: Colors.black,
       ),   
       floatingActionButton: FloatingActionButton(
         onPressed: () {
                      _upload();
                    },
                    backgroundColor: Colors.black,
        child: const Icon(Icons.camera, color: Colors.white,),
       ),
       body: Container(
        color: Colors.black.withOpacity(0.1),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _loadImages(),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> image =
                            snapshot.data![index];
        
                        return  Card(
                          elevation: 2,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>
                                  DetailScreen(imagesource: image['url'],)
                                  )
                                  );
                                },
                                child: Hero(
                                  tag: "Demo Tag",
                                  child: Container(
                                  height: 80,
                                  width: 80,
                                  margin: EdgeInsets.only(top:20),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300]
                                                             ),
                                                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.network(
                                    image['url'],
                                    fit: BoxFit.fill,
                                      ),
                                                              )
                                  ),
                                ),
                              ),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                             
                             Container(
                               width: MediaQuery.of(context).size.width * 0.46,
                               child: Text(
                                 image['date'].toString(),
                                 style: TextStyle(
                                 color: Colors.black,
                                 fontWeight: FontWeight.w500,
                                 fontSize: 16
                               ),),
                             ),
                             Container(
                               width:  MediaQuery.of(context).size.width * 0.1,
                               child: IconButton(
                                 onPressed: () => _delete(image['path']),
                                 icon: Icon(Icons.delete, color: Colors.black,),
                               ),
                             )
                           ],)
                            ],
                          ),
                        );
                      },
                    );
                  }
        
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            //  Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     ElevatedButton(
            //       onPressed: () {
            //           _upload();
            //       },
            //       child: const Icon(Icons.camera, color: Colors.white,),
            //     )  
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}