import 'package:chatify/models/contact.dart';
import 'package:chatify/provider/auth_provider.dart';
import 'package:chatify/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchPage extends StatefulWidget {
  final double height;
  final double width;

  SearchPage({super.key, required this.height, required this.width});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? searchText;
  late AuthProvider _auth;

  _SearchPageState() {
    searchText = '';
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _searchPageUI(),
      ),
    );
  }

  Widget _searchPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_userSearchField(), Expanded(child: _userListView())],
        );
      },
    );
  }

  Widget _userSearchField() {
    return Container(
      height: widget.height * 0.08,
      width: widget.width,
      padding: EdgeInsets.symmetric(vertical: widget.height * 0.02),
      child: Builder(
        builder: (context) {
          return TextField(
            autocorrect: false,
            style: TextStyle(color: Colors.white),
            onSubmitted: (_input) {
              Provider.of<AuthProvider>(
                context,
                listen: false,
              ).setSearchText(_input);
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.white),
              labelStyle: TextStyle(color: Colors.white),
              label: Text('Search'),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          );
        },
      ),
    );
  }

  Widget _userListView() {
    return StreamBuilder<List<Contact>>(
      stream: DbService.instance.getUsersInDB(_auth.searchText!),
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

        var _usersData = _snapshot.data!;
        _usersData.removeWhere((_contact) => _contact.id == _auth.user!.uid);
        return Container(
          height: this.widget.height * 0.75,
          child: ListView.builder(
            itemCount: _usersData.length,
            itemBuilder: (BuildContext _context, int _index) {
              var _userData = _usersData[_index];
              var _currentTime = DateTime.now();
              var _isUserActive =
                  !_userData.lastSeen!.toDate().isAfter(
                    _currentTime.subtract(Duration(hours: 1)),
                  );

              return ListTile(
                title: Text(_userData.name!),
                leading: Container(
                  height: 50,
                  width: 50,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    image: DecorationImage(
                      image: NetworkImage(
                        _userData.image ??
                            'https://cdn-icons-png.flaticon.com/512/10771/10771017.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _isUserActive
                        ? Text('Active Now', style: TextStyle(fontSize: 15))
                        : Text('Last Seen', style: TextStyle(fontSize: 15)),
                    _isUserActive
                        ? Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        )
                        : Text(
                          timeago.format(_userData.lastSeen!.toDate()),
                          style: TextStyle(fontSize: 15),
                        ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
