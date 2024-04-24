import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http ;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class ChatPage extends StatefulWidget {
  static const routeName  = '/chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatHistory = [];
  FilePickerResult? result;
  PlatformFile? file ;
  File? pdf;

void getAnswer() async {
  final url = "https://api-chat-with-docs.onrender.com";
  final uri = Uri.parse(url);
final header = {'Content-Type': 'multipart/form-data'};
  List<Map<String, String>> msg = [];
  for (var i = 0; i < _chatHistory.length; i++) {
    msg.add({"content": _chatHistory[i]["message"]});
  }

  final request = http.MultipartRequest("POST", uri);
  request.headers.addAll(header);
  request.fields['prompt[messages]'] = jsonEncode(msg);
  request.fields['temperature'] = '0.25';
  request.fields['candidateCount'] = '1';
  request.fields['topP'] = '1';
  request.fields['topK'] = '1';

  final pdfFile = File(pdf!.path);
  final pdfLength = await pdfFile.length();
  final pdfStream = http.ByteStream(pdfFile.openRead());
  final pdfMultipartFile = http.MultipartFile('fileup', pdfStream, pdfLength,
      filename: pdfFile.path.split('/').last);

  request.files.add(pdfMultipartFile);

  final response = await request.send();
  final responseBody = await response.stream.transform(utf8.decoder).join();

  setState(() {
    _chatHistory.add({
      "message": jsonDecode(responseBody)["candidates"][0]["content"],
      "isSender": false,
    });
  });
}
Future pickedfile() async{
   result= await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  if (result!=null) return;
  file =result!.files.first;
  
  setState(() {
    pdf=File(file!.path!);
  });

}
void openFile(PlatformFile file){
  OpenFile.open(file.path);
}
 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Stack(
        children: [
          Container(
            //get max height
            height: MediaQuery.of(context).size.height - 160,
            child: ListView.builder(
              itemCount: _chatHistory.length,
              shrinkWrap: false,
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 10,bottom: 10),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index){
                return Container(
                  padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                  child: Align(
                    alignment: (_chatHistory[index]["isSender"]?Alignment.topRight:Alignment.topLeft),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        color: (_chatHistory[index]["isSender"]?Color(0xFFF69170):Colors.white),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(_chatHistory[index]["message"], style: TextStyle(fontSize: 15, color: _chatHistory[index]["isSender"]?Colors.white:Colors.black)),
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(width: 4.0,),
                  MaterialButton(
                    onPressed: (){
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                    padding: const EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF69170),
                              Color(0xFF7D96E6),
                            ]
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
                        alignment: Alignment.center,
                        child:  IconButton(onPressed: (){ 
                        pickedfile();
                         getAnswer();
                        }, icon: Icon(Icons.attach_file, color: Colors.white,))
                      ),
                    ),),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        
                         borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Type a message",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8.0),
                          ),
                          controller: _chatController,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0,),
                  MaterialButton(
                    onPressed: (){

                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                    padding: const EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF69170),
                              Color(0xFF7D96E6),
                            ]
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
                        alignment: Alignment.center,
                        child:  IconButton(onPressed: (){
  setState(() {
    if(_chatController.text.isNotEmpty){
      _chatHistory.add({
        
        "message": _chatController.text,
        "isSender": true,
      });
      _chatController.clear();

    }
  });
  _scrollController.jumpTo(
    _scrollController.position.maxScrollExtent,
  );
}, icon: Icon(Icons.send, color: Colors.white,))
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
