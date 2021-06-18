// @dart=2.9
import 'dart:async';

import 'package:flutter/material.dart';

import '../model/model.dart';
import '../util/dbhelper.dart';
import '../util/utils.dart' as _utils;
import './docdetail.dart';

// Menu item
const menuReset = "Reset Local Data";
List<String> menuOptions = const <String>[menuReset];

// ignore: use_key_in_widget_constructors
class DocList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DocListState();
}

class DocListState extends State<DocList> {
  DbHelper dbh = DbHelper();
  List<Doc> docs;
  int count = 0;
  DateTime cDate;

  @override
  void initState() {
    super.initState();
  }

  Future getData() async {
    final dbFuture = dbh.initializeDb();
    dbFuture.then(
        // result here is the actual reference to the database object
        (result) {
      final docsFuture = dbh.getDocs();
      docsFuture.then(
          // result here is the list of docs in the database
          (result) {
        // ignore: prefer_is_empty
        if (result.length >= 0) {
          List<Doc> docList = <Doc>[];
          var count = result.length;
          for (int i = 0; i <= count - 1; i++) {
            docList.add(Doc.fromOject(result[i]));
          }
          setState(() {
            if (docs.isNotEmpty) {
              docs.clear();
            }

            docs = docList;
            this.count = count;
          });
        }
      });
    });
  }

  void _checkDate() {
    const secs = Duration(seconds: 10);

    Timer.periodic(secs, (Timer t) {
      DateTime nw = DateTime.now();

      if (cDate.day != nw.day ||
          cDate.month != nw.month ||
          cDate.year != nw.year) {
        getData();
        cDate = DateTime.now();
      }
    });
  }

  void navigateToDetail(Doc doc) async {
    bool r = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => DocDetail(doc)));

    if (r == true) {
      getData();
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset"),
          content: const Text("Do you want to delete all local data?"),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // ignore: deprecated_member_use
            FlatButton(
              child: const Text("OK"),
              onPressed: () {
                Future f = _resetLocalData();
                f.then((result) {
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future _resetLocalData() async {
    final dbFuture = dbh.initializeDb();
    dbFuture.then((result) {
      final dDocs = dbh.deleteRows(DbHelper.tblDocs);
      dDocs.then((result) {
        setState(() {
          docs.clear();
          count = 0;
        });
      });
    });
  }

  void _selectMenu(String value) async {
    switch (value) {
      case menuReset:
        _showResetDialog();
    }
  }

  ListView docListItems() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        String dd = _utils.Val.GetExpiryStr(docs[position].expiration);
        String dl = (dd != "1") ? " days left" : " day left";
        return Card(
          color: Colors.white,
          elevation: 1.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  (_utils.Val.GetExpiryStr(docs[position].expiration) != "0")
                      ? Colors.blue
                      : Colors.red,
              child: Text(
                docs[position].id.toString(),
              ),
            ),
            title: Text(docs[position].title),
            subtitle: Text(_utils.Val.GetExpiryStr(docs[position].expiration) +
                dl +
                "\nExp: " +
                _utils.DateUtils.convertToDateFull(docs[position].expiration)),
            onTap: () {
              navigateToDetail(docs[position]);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    cDate = DateTime.now();

    if (docs == null) {
      docs = <Doc>[];
      getData();
    }

    _checkDate();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("DocExpire"), actions: <Widget>[
        PopupMenuButton(
          onSelected: _selectMenu,
          itemBuilder: (BuildContext context) {
            return menuOptions.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ]),
      body: Center(
        child: Scaffold(
          body: Stack(children: <Widget>[
            docListItems(),
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              navigateToDetail(Doc.withId(-1, "", "", 1, 1, 1, 1));
            },
            tooltip: "Add new doc",
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
