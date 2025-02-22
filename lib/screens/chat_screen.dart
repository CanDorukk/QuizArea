import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:quizarea/core/LocaleManager.dart';

class ChatScreen extends StatefulWidget {
  final String friendUid;
  final String friendFullName;

  ChatScreen({required this.friendUid, required this.friendFullName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendMessage() async {
    final localManager = Provider.of<LocalManager>(context, listen: false);
    final currentUserId = _auth.currentUser!.uid;
    final messageContent = _controller.text.trim();

    if (messageContent.isEmpty) return;

    try {
      // Add message to Firestore
      await FirebaseFirestore.instance.collection('chats').add({
        'senderId': currentUserId,
        'receiverId': widget.friendUid,
        'message': messageContent,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the text field after sending
      _controller.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localManager.translate("message_sended"))),
      );
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localManager.translate("error_occoured_message"))),
      );
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages() {
    final currentUserUid = _auth.currentUser!.uid;
    final friendUid = widget.friendUid;

    return FirebaseFirestore.instance
        .collection('chats')
        .where('senderId', whereIn: [currentUserUid, friendUid])
        .where('receiverId', whereIn: [currentUserUid, friendUid])
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
      'message': doc['message'],
      'senderId': doc['senderId'],
      'timestamp': doc['timestamp'],
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("${localManager.translate("messaging")} - ${widget.friendFullName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),  // Add 20px padding on top and bottom
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: getMessages(),  // Mesajları almak için getMessages() fonksiyonunu kullanıyoruz
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(localManager.translate("no_message_text")));
                  }

                  final messages = snapshot.data!;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index]['message'];
                      final senderId = messages[index]['senderId'];

                      bool isCurrentUser = senderId == _auth.currentUser!.uid;

                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight // Gönderen kişinin mesajı sağda
                            : Alignment.centerLeft, // Alıcı kişinin mesajı solda
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isCurrentUser ? Colors.lightBlueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: isCurrentUser ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),  // Yuvarlak kenarlar
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: localManager.translate("write_your_message"),
                            border: InputBorder.none, // Kenar çizgisi yok
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: isDarkMode ? Colors.white : Theme.of(context).primaryColor, // Ensure the send button is visible in dark mode
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
