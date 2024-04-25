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
  
  
  File? pdf;

Future pickedfile() async{
 final result= await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  if (result!=null) 
  { 
   return uploadFile (pdf!);
  }
final file=result!.files.first;
  
  setState(() {
    pdf=File(file.path!);
  });
if (result!=null) 
  { 
   return uploadFile (pdf!);
  }
}
void openFile(PlatformFile file){
  OpenFile.open(file.path);
}
Future<void> uploadFile(File file) async {
  var request = http.MultipartRequest('POST', Uri.parse('https://api-chat-with-docs.onrender.com/docs#/default/upload_pdf_upload__post'));
  request.files.add(await http.MultipartFile.fromPath('fileup', file.path));
  
  try {
    final streamedResponse = await request.send();
    if (streamedResponse.statusCode == 200) {
      // File uploaded successfully
      print('File uploaded');
    } else {
      // Handle error
      print('Error uploading file: ${streamedResponse.reasonPhrase}');
    }
  } catch (e) {
    // Handle error
    print('Error uploading file: $e');
  }
}

Future questionFromUser() async{
  final uri=Uri.parse("https://api-chat-with-docs.onrender.com/chatpdf/");
  List<Map<String,String>>msg=[];
  for(var i=0;i< -_chatHistory[i].length;i++){
    msg.add({"content": _chatHistory[i]["message"]});
  }
  Map<String,dynamic>request={
"prompt":{
  "messages":[msg]
    }  };
    final response = await http.post(uri,body: jsonEncode(request));
    if(response.statusCode==201){
     print("success sent");
    }else{
      print("failed to load a question");
    };
}
Future UrlFromUser() async{
  final uri=Uri.parse("https://api-chat-with-docs.onrender.com/chaturl/");
  List<Map<String,String>>msg=[];
  for(var i=0;i< -_chatHistory[i].length;i++){
    msg.add({"content": _chatHistory[i]["message"]});
  }
  Map<String,dynamic>request={
"prompt":{
  "messages":[msg]
    }  };
    final response = await http.post(uri,body: jsonEncode(request));
    if(response.statusCode==201){
     print("success sent");
    }else{
      print("failed to load a question");
    };
}



Future answerfromchat()async{

final uri=Uri.parse("https://api-chat-with-docs.onrender.com/");
final response= await http.get(uri);

setState(() {
  _chatHistory.add({
    "message":json.decode(response.body)["candidates"][0]["content"],
    "isSender":false
  });  
});

_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
                        constraints: const BoxConstraints(minWidth: 70.0, minHeight: 36.0), // min sizes for Material buttons
                        alignment: Alignment.center,
                        child:  IconButton(onPressed: (){
                         pickedfile();
                       
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
                        constraints: const BoxConstraints(minWidth: 70.0, minHeight: 36.0), // min sizes for Material buttons
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