import 'package:chatify/models/conversation.dart';
import 'package:chatify/pages/conversation_page.dart';
import 'package:chatify/provider/auth_provider.dart';
import 'package:chatify/services/db_service.dart';
import 'package:chatify/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentConversationPage extends StatelessWidget {
  final double height;
  final double width;
  const RecentConversationPage({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: conversationListViewWidget(),
      ),
    );
  }

  Widget conversationListViewWidget() {
    return Builder(
      builder: (BuildContext _context) {
        var _auth = Provider.of<AuthProvider>(_context);

        return Container(
          height: height,
          width: width,
          child: StreamBuilder<List<ConversationSnippet>>(
            stream: DbService.instance.getUserConversations(_auth.user!.uid),
            builder: (_context, _snapshot) {
              if (!_snapshot.hasData || _snapshot.data == null) {
                return Center(
                  child: SpinKitWanderingCubes(
                    color: Colors.blue,
                    size: 50.0,
                    shape: BoxShape.circle,
                  ),
                );
              }

              var _userData = _snapshot.data!;

              return _userData.length != 0
                  ? ListView.builder(
                    itemCount: _userData.length,
                    itemBuilder: (_context, _index) {
                      return ListTile(
                        title: Text(_userData[_index].name!),
                        subtitle: Text(_userData[_index].lastMessage!),
                        onTap: () {
                          NavigationService.instance.navigateToRoute(
                            MaterialPageRoute(
                              builder: (BuildContext _context) {
                                return ConversationPage(
                                  _userData[_index].conversationID!,
                                  _userData[_index].id!,
                                  _userData[_index].name!,
                                  _userData[_index].image!,
                                );
                              },
                            ),
                          );
                        },
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(_userData[_index].image!),
                            ),
                          ),
                        ),
                        trailing: listTileTrailingWidget(
                          _userData[_index].timeStamp!,
                        ),
                      );
                    },
                  )
                  : Center(
                    child: Text(
                      'No Conversations yet!',
                      style: TextStyle(fontSize: 20, color: Colors.white30),
                    ),
                  );
            },
          ),
        );
      },
    );
  }

  Widget listTileTrailingWidget(Timestamp lastMessageTimeStamp) {
    var _timeDifference = lastMessageTimeStamp.toDate().difference(
      DateTime.now(),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Last Message', style: TextStyle(fontSize: 15)),
        Text(
          timeago.format(lastMessageTimeStamp.toDate()),
          style: TextStyle(fontSize: 15),
        ),
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: _timeDifference.inHours > 1 ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }
}
