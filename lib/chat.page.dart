import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<dynamic> data = [
    {'message': 'Hello', 'type': 'user'},
    {'message': 'How can I help you', 'type': 'assistant'},
  ];

  TextEditingController queryController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Page"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: data.length,
              itemBuilder: (context, index) {
                bool isUser = data[index]['type'] == 'user';
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Row(
                          children: [
                            SizedBox(
                              width: isUser ? 100 : 0,
                            ),
                            Expanded(
                              child: Card(
                                child: Container(
                                  child: Text(
                                    data[index]['message'],
                                  ),
                                  padding: EdgeInsets.all(10),
                                  color: isUser
                                      ? Color.fromARGB(50, 0, 255, 0)
                                      : Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isUser ? 0 : 100,
                            )
                          ],
                        ),
                        leading: (!isUser) ? Icon(Icons.support_agent) : null,
                        trailing: (isUser) ? Icon(Icons.person_2) : null,
                      ),
                    ),
                    Divider(
                      height: 1,
                    )
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: queryController,
                    obscureText: false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage();
                  },
                  icon: Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage() async {
    String query = queryController.text;
    var prompt = {
      "model": "gpt-3.5-turbo",
      "messages": [{"role": "user", "content": query}],
      "temperature": 0.7
    };
    setState(() {
      data.add({'message': query, 'type': 'user'});
    });

    var url = Uri.https("api.openai.com", "/v1/chat/completions");
    Map<String, String> userHeaders = {
      "Content-type": "application/json",
      "Authorization": "Bearer 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"
    };

    try {
      var resp = await http.post(
        url,
        headers: userHeaders,
        body: json.encode(prompt),
      );

      if (resp.statusCode == 200) {
        var result = json.decode(resp.body);
        if (result != null &&
            result['choices'] != null &&
            result['choices'].isNotEmpty) {
            setState(() {
            data.add({
              "message": result['choices'][0]['message']['content'],
              "type": "assistant"
            });
            scrollController.jumpTo(scrollController.position.maxScrollExtent +
                60);
          });
        } else {
          print("Error: Invalid response format");
        }
      } else {
        print("Error: ${resp.body}");
      }
    } catch (err) {
      print("-------------------- ERROR ------------");
      print(err);
    }
  }
}
