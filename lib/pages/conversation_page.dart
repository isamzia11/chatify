import 'dart:async';

import 'package:chatify/models/conversation.dart';
import 'package:chatify/models/message.dart';
import 'package:chatify/provider/auth_provider.dart';
import 'package:chatify/services/cloud_storage_service.dart';
import 'package:chatify/services/db_service.dart';
import 'package:chatify/services/media_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationPage extends StatefulWidget {
  late String _conversationID;
  late String _receiverID;
  late String _receiverName;
  late String _receiverImage;

  ConversationPage(
    this._conversationID,
    this._receiverID,
    this._receiverName,
    this._receiverImage,
  );

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthProvider _auth;
  String? messageText;
  late GlobalKey<FormState> _formKey;
  late ScrollController _listViewController;

  _ConversationPageState() {
    _formKey = GlobalKey<FormState>();
    _listViewController = ScrollController();
    messageText = "";
  }
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(this.widget._receiverName),

        centerTitle: true,
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: conversationPageUI(),
      ),
    );
  }

  Widget conversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            _messageListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(_context),
            ),
          ],
        );
      },
    );
  }

  Widget _messageListView() {
    return Container(
      height: _deviceHeight * 0.75,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DbService.instance.getConversation(this.widget._conversationID),

        builder: (BuildContext _context, _snapshot) {
          var _conversationData = _snapshot.data;

          return _conversationData != null
              ? ListView.builder(
                controller: _listViewController,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                itemCount: _conversationData.messages.length,
                itemBuilder: (BuildContext _context, int _index) {
                  Timer(Duration(milliseconds: 50), () {
                    _listViewController.jumpTo(
                      _listViewController.position.maxScrollExtent,
                    );
                  });
                  var _message = _conversationData.messages[_index];
                  bool isOwnMessage = _message.senderID == _auth.user!.uid;
                  return _messageListViewChild(isOwnMessage, _message);
                },
              )
              : SpinKitWanderingCubes(color: Colors.blue, size: 50.0);
        },
      ),
    );
  }

  Widget _messageListViewChild(bool isOwnMessage, Message _message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          !isOwnMessage ? _userImageWidget() : Container(),
          SizedBox(width: _deviceWidth * 0.02),
          _message.type == MessageType.Text
              ? _textMessageBubble(
                isOwnMessage,
                _message.content,
                _message.timestamp,
              )
              : _imageMessageBubble(
                isOwnMessage,
                _message.content,
                _message.timestamp,
              ),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    double _imageRadius = _deviceHeight * 0.05;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),

        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(this.widget._receiverImage),
        ),
      ),
    );
  }

  Widget _textMessageBubble(
    bool _isOwnMessage,
    String _message,
    Timestamp _timestamp,
  ) {
    List<Color> _colorScheme =
        _isOwnMessage
            ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
            : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return Container(
      height: _deviceHeight * 0.08 + (_message.length / 20 * 5.0),
      width: _deviceWidth * 0.75,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_message),
          Text(
            timeago.format(_timestamp.toDate()),
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
    bool _isOwnMessage,
    String _imageURL,
    Timestamp _timestamp,
  ) {
    List<Color> _colorScheme =
        _isOwnMessage
            ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
            : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    DecorationImage _image = DecorationImage(
      image: NetworkImage(_imageURL),
      fit: BoxFit.cover,
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceWidth * 0.40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: _image,
            ),
          ),
          Text(
            timeago.format(_timestamp.toDate()),
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.04,
        vertical: _deviceHeight * 0.03,
      ),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _messageTextField(),
            _sendMessageButton(_context),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        autocorrect: false,
        validator: (_input) {
          if (_input!.isEmpty) {
            return "Please enter a message";
          }
          return null;
        },
        onChanged: (_input) {
          _formKey.currentState!.save();
        },
        onSaved: (_input) {
          messageText = _input;
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Type a message",
        ),
      ),
    );
  }

  Widget _sendMessageButton(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceWidth * 0.05,
      child: IconButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            DbService.instance.sendMessage(
              this.widget._conversationID,
              Message(
                senderID: _auth.user!.uid,
                content: messageText!,
                timestamp: Timestamp.now(),
                type: MessageType.Text,
              ),
            );
            _formKey.currentState!.reset();
            FocusScope.of(_context).unfocus();
          }
        },
        icon: Icon(Icons.send, color: Colors.white),
      ),
    );
  }

  Widget _imageMessageButton() {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      decoration: BoxDecoration(
        color:
            Colors
                .blue, // You can keep it green or change to blue if you prefer
        borderRadius: BorderRadius.circular(
          25.0,
        ), // <-- ADDED THIS LINE to make it rounded
        // 25.0 should make it a perfect circle if height/width are 50x50.
        // Or you can use 100.0 or more for an arbitrarily large radius to ensure a circle.
      ),
      child: IconButton(
        onPressed: () async {
          var _image = await MediaService.instance.getImageFromLibrary();
          if (_image != null) {
            var _result = await CloudStorageService.instance.uploadMediaMessage(
              _auth.user!.uid,
              _image,
            );

            var _imageURL = await _result.ref.getDownloadURL();
            DbService.instance.sendMessage(
              this.widget._conversationID,
              Message(
                senderID: _auth.user!.uid,
                content: _imageURL,
                timestamp: Timestamp.now(),
                type: MessageType.Image,
              ),
            );
          }
        },
        icon: Icon(Icons.camera_enhance, color: Colors.white),
      ),
    );
  }
}
