import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thingsboard_app/controllers/user_base.dart';
import 'package:data_table_2/data_table_2.dart';

import '../localization/localization.dart';
import '../models/models.dart';
import 'pages.dart';

class UserList extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onUserList;
  final VoidCallback onPreferences;
  const UserList({
    super.key,
    required this.onLogout,
    required this.onUserList,
    required this.onPreferences,
  });

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late final List<Users> _users;
  int columnCount = 2;
  int aspectWidth = 2;
  int aspectHeight = 1;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  final _passwordController = TextEditingController();
  late TextEditingController _roleController;
  Authority? authUserAuthority;
  String viewType = 'gridview';

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _loadUserInfo();
  }

  void _loadUserInfo() async {
    _users = [];
    _usersForSearch = [];
    var userBaseProvider =
        Provider.of<UserBaseProvider>(context, listen: false);
    var userBaseController = userBaseProvider.userBaseController;
    var userApiController = userBaseProvider.userApiController;
    //print('Current AuthUser: ${userBaseController.getAuthUser()}');
    if (userBaseController.isSystemAdmin()) {
      var users = await userApiController.getAllUsers();
      for (var user in users) {
        _users.add(user);
      }
      authUserAuthority = Authority.sysAdmin;
    } else {
      var authemail = userBaseController.getAuthUser()!.email;
      var authUser = await userApiController.getUser(authemail!);
      _users.add(authUser!);
      authUserAuthority = Authority.customerUser;
    }

    _userNameController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');
    _roleController = TextEditingController(text: '');

    setState(() {
      _users;
      authUserAuthority;
      viewType = 'gridview';
    });
  }

  @override
  Widget build(BuildContext context) {
    //print('UserInfo : $_users');
    if (_users.isEmpty) {
      return _showCircularProgressIndicator(context);
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //backgroundColor: Colors.transparent,
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppTranslations.of(context)!.text('drawerUsers')),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: MyDrawer(
        onLogout: () => widget.onLogout(),
        onUserList: () => widget.onUserList(),
        onPreferences: () => widget.onPreferences(),
      ),
      body: viewType == 'gridview'
          ? (columnCount == 2
              ? createGridBody(context)
              : createListBody(context))
          : createDataTableBody(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ExpandableFab(
        distance: 80.0,
        children: [
          ActionButton(
            onPressed: (() {
              changeMode();
            }),
            icon: columnCount == 2
                ? const Icon(Icons.view_list)
                : const Icon(Icons.grid_view),
          ),
          ActionButton(
            onPressed: (() {
              setState(() {
                viewType = 'datatableview';
              });
            }),
            icon: const Icon(Icons.table_rows),
          ),
          authUserAuthority == Authority.sysAdmin
              ? ActionButton(
                  onPressed: (() {
                    _showEditUserDialog(
                        context, 'ADD', "", "", "", _users.length - 1);
                  }),
                  icon: const Icon(Icons.add),
                )
              : const SizedBox(),
        ],
      )
      /*Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
              heroTag: "viewModule",
              tooltip: AppTranslations.of(context)!.text('usersFloatActionViewModule'),
              elevation: 0.0,
              backgroundColor: const Color.fromARGB(255, 102, 168, 223),
              onPressed: () => changeMode(),
              hoverColor: Colors.orange,
              child: columnCount == 2
                  ? const Icon(Icons.view_list)
                  : const Icon(Icons.grid_view)),
          const SizedBox(width: 35.0),
          authUserAuthority == Authority.sysAdmin
              ? FloatingActionButton(
                  heroTag: "addUser",
                  tooltip:
                      AppTranslations.of(context)!.text('usersFloatActionAddUser'),
                  elevation: 0.0,
                  backgroundColor: const Color.fromARGB(255, 102, 168, 223),
                  onPressed: () {
                    _showEditUserDialog(
                        context, 'ADD', "", "", "", _users.length - 1);
                  },
                  hoverColor: Colors.orange,
                  child: const Icon(Icons.add))
              : const SizedBox(),
        ],
      )*/
      ,
    );
  }

  Widget _showCircularProgressIndicator(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          alignment: Alignment.center,
          image: AssetImage('assets/images/welcome_bg.png'),
          fit: BoxFit.fill,
        )),
        child: const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator(),
            )));
  }

  changeMode() {
    if (columnCount == 2) {
      setState(() {
        columnCount = 1;
        aspectWidth = 3;
        aspectHeight = 1;
        viewType = 'gridview';
      });
    } else {
      setState(() {
        columnCount = 2;
        aspectWidth = 2;
        aspectHeight = 1;
        viewType = 'gridview';
      });
    }
  }

  Widget createGridBody(BuildContext context) {
    return GridView.builder(
        itemCount: _users.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            childAspectRatio: (aspectWidth / aspectHeight)),
        itemBuilder: (context, index) {
          return Card(
              elevation: 0,
              color: Colors.blue.shade200,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.white70, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.account_circle,
                            size: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _users[index].email,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _users[index].role,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 35.0),
                            IconButton(
                              onPressed: () {
                                _showEditUserDialog(
                                    context,
                                    'EDIT',
                                    _users[index].userName,
                                    _users[index].email,
                                    _users[index].role,
                                    index);
                              },
                              icon: const Align(
                                child: Icon(
                                  Icons.edit,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                              constraints:
                                  BoxConstraints.tight(const Size(32, 32)),
                            ),
                            authUserAuthority == Authority.sysAdmin
                                ? IconButton(
                                    alignment: Alignment.center,
                                    onPressed: () {
                                      deleteUser(
                                          context, _users[index].email, index);
                                    },
                                    icon: const Align(
                                      child: Icon(
                                        Icons.delete,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                    constraints: BoxConstraints.tight(
                                        const Size(32, 32)),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ));
        });
  }

  Widget createListBody(BuildContext context) {
    return GridView.builder(
        itemCount: _users.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            childAspectRatio: (aspectWidth / aspectHeight)),
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            color: Colors.blue.shade200,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white70, width: 1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              //crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {},
                  constraints: BoxConstraints.tight(const Size(40, 72)),
                  icon: const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.account_circle,
                        size: 60, color: Colors.white),
                  ),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _users[index].userName,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _users[index].email,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _users[index].role,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        _showEditUserDialog(
                            context,
                            'EDIT',
                            _users[index].userName,
                            _users[index].email,
                            _users[index].role,
                            index);
                      },
                      icon: const Align(
                        child: Icon(
                          Icons.edit,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      constraints: BoxConstraints.tight(const Size(32, 48)),
                    ),
                    const SizedBox(height: 15.0),
                    authUserAuthority == Authority.sysAdmin
                        ? IconButton(
                            alignment: Alignment.center,
                            onPressed: () {
                              deleteUser(context, _users[index].email, index);
                            },
                            icon: const Align(
                              child: Icon(
                                Icons.delete,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            constraints:
                                BoxConstraints.tight(const Size(32, 48)),
                          )
                        : const SizedBox(),
                  ],
                ),
              ],
            ),
          );
        });
  }

  void _showEditUserDialog(BuildContext context, String medth, String name,
      String email, String role, int index) {
    _userNameController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);
    _roleController = TextEditingController(text: role);
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        elevation: 0,
        title: Text(AppTranslations.of(context)!.text('usersUpdateDialogTitle'),
            textAlign: TextAlign.center),
        content: SingleChildScrollView(
            child: Column(
          children: [
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                  labelText: AppTranslations.of(context)!
                      .text('usersUpdateDialogName'),
                  hintText: AppTranslations.of(context)!
                      .text('usersUpdateDialogName')),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  labelText: AppTranslations.of(context)!
                      .text('usersUpdateDialogEmail'),
                  hintText: AppTranslations.of(context)!
                      .text('usersUpdateDialogEmail')),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText: AppTranslations.of(context)!
                      .text('usersUpdateDialogPassword'),
                  hintText: AppTranslations.of(context)!
                      .text('usersUpdateDialogPassword')),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(
                  labelText: AppTranslations.of(context)!
                      .text('usersUpdateDialogRole'),
                  hintText: AppTranslations.of(context)!
                      .text('usersUpdateDialogRole')),
            ),
          ],
        )),
        actions: <Widget>[
          TextButton(
            child: Text(
                AppTranslations.of(context)!.text('usersUpdateDialogCancel')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
                AppTranslations.of(context)!.text('usersUpdateDialogSave')),
            onPressed: () {
              setState(() {
                _userNameController.text;
                _emailController.text;
                _roleController.text;
              });
              medth == 'EDIT'
                  ? updateUser(
                      context,
                      index,
                      _userNameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _roleController.text)
                  : createUser(
                      context,
                      index,
                      _userNameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _roleController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Future<void> updateUser(BuildContext context, int index, String name,
      String email, String password, String role) async {
    var userBaseProvider =
        Provider.of<UserBaseProvider>(context, listen: false);
    if (authUserAuthority == Authority.sysAdmin) {
      var userApiController = userBaseProvider.userApiController;
      var response = await userApiController.updateUser(
          _users[index].email, name, email, password, role);
      inspect(response);
      if (response != null) {
        setState(() {
          _users[index].userName = response.userName;
          _users[index].email = response.email;
          _users[index].role = response.role;
        });
      }
    }
  }

  Future<void> deleteUser(BuildContext context, String email, int index) async {
    var userBaseProvider =
        Provider.of<UserBaseProvider>(context, listen: false);
    var userBaseController = userBaseProvider.userBaseController;
    if (userBaseController.isSystemAdmin()) {
      var userApiController = userBaseProvider.userApiController;
      await userApiController.deleteUser(email);
      setState(() {
        _users.removeAt(index);
      });
    }
  }

  Future<void> createUser(BuildContext context, int index, String name,
      String email, String password, String role) async {
    var userBaseProvider =
        Provider.of<UserBaseProvider>(context, listen: false);
    if (authUserAuthority == Authority.sysAdmin) {
      var userApiController = userBaseProvider.userApiController;
      var response =
          await userApiController.createUser(name, email, password, role);
      inspect(response);
      if (response != null) {
        setState(() {
          _users.add(response);
        });
      }
    }
  }

  int _currentSortColumn = 0;
  bool _isAscending = true;
  TextEditingController searchController = TextEditingController();
  bool _isSearching = false;
  String searchType = 'email';
  late final List<Users> _usersForSearch;

  Widget createDataTableBody(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (value) {
            filterSearchResults(value);
          },
          controller: searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            labelText: searchType == 'email'
                ? (AppTranslations.of(context)!
                    .text('usersDataTableSearchbyEmail'))
                : (searchType == 'name'
                    ? AppTranslations.of(context)!
                        .text('usersDataTableSearchbyName')
                    : AppTranslations.of(context)!
                        .text('usersDataTableSearchbyAuthority')),
            hintText: searchType == 'email'
                ? (AppTranslations.of(context)!
                    .text('usersDataTableSearchbyEmail'))
                : (searchType == 'name'
                    ? AppTranslations.of(context)!
                        .text('usersDataTableSearchbyName')
                    : AppTranslations.of(context)!
                        .text('usersDataTableSearchbyAuthority')),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            suffixIcon: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: (() {
                    searchController.clear();
                    _isSearching = false;
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  }),
                  icon: const Icon(Icons.clear),
                ),
                PopupMenuButton(
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.white70),
                      borderRadius: BorderRadius.circular(10)),
                  color: const Color.fromARGB(255, 45, 160, 189),
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: ((context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 'email',
                          child: ListTile(
                            title: Text(AppTranslations.of(context)!
                                .text('usersDataTableSearchbyEmail')),
                            textColor: searchType == 'email'
                                ? const Color.fromARGB(255, 204, 47, 47)
                                : Colors.white,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'name',
                          child: ListTile(
                            title: Text(AppTranslations.of(context)!
                                .text('usersDataTableSearchbyName')),
                            textColor: searchType == 'name'
                                ? const Color.fromARGB(255, 204, 47, 47)
                                : Colors.white,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'authority',
                          child: ListTile(
                            title: Text(AppTranslations.of(context)!
                                .text('usersDataTableSearchbyAuthority')),
                            textColor: searchType == 'authority'
                                ? const Color.fromARGB(255, 204, 47, 47)
                                : Colors.white,
                          ),
                        ),
                      ]),
                  onSelected: (value) {
                    setState(() {
                      searchType = '$value';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      Expanded(
        child: DataTable2(
          columnSpacing: 6,
          horizontalMargin: 30,
          minWidth: 600,
          fixedTopRows: 1,
          fixedLeftColumns: 1,
          headingRowColor: MaterialStateProperty.all(
              const Color.fromARGB(255, 197, 168, 40)),
          sortAscending: _isAscending,
          sortColumnIndex: _currentSortColumn,
          headingTextStyle: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          dataTextStyle: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          dataRowColor: MaterialStateProperty.all(
              const Color.fromARGB(255, 134, 135, 139)),
          columns: _createColumns(),
          rows: _createRows(),
        ),
      )
    ]);
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
          label: Text(
              AppTranslations.of(context)!.text('usersDataTableHeaderName'))),
      DataColumn(
          label: Text(
              AppTranslations.of(context)!.text('usersDataTableHeaderEmail')),
          onSort: ((columnIndex, _) {
            setState(() {
              _currentSortColumn = columnIndex;
              if (_isAscending == true) {
                _isAscending = false;
                _users.sort((a, b) => b.email.compareTo(a.email));
              } else {
                _isAscending = true;
                _users.sort((a, b) => a.email.compareTo(b.email));
              }
            });
          })),
      DataColumn(
          label: Text(AppTranslations.of(context)!
              .text('usersDataTableHeaderAuthority'))),
    ];
  }

  List<DataRow> _createRows() {
    List<DataRow> rows = [];
    for (var user in _isSearching ? _usersForSearch : _users) {
      rows.add(DataRow(cells: [
        DataCell(Text(user.userName)),
        DataCell(Text(user.email)),
        DataCell(Text(user.role)),
      ]));
    }
    return rows;
  }

  void filterSearchResults(String query) {
    List<Users> dummySearchUser = [];
    dummySearchUser.addAll(_users);
    if (query.isNotEmpty) {
      List<Users> dummyUserData = [];
      dummySearchUser.forEach(((item) {
        switch (searchType) {
          case 'email':
            if (item.email.contains(query)) {
              dummyUserData.add(item);
            }
            break;
          case 'name':
            if (item.userName.contains(query)) {
              dummyUserData.add(item);
            }
            break;
          case 'authority':
            if (item.role.contains(query)) {
              dummyUserData.add(item);
            }
            break;
          default:
            if (item.email.contains(query)) {
              dummyUserData.add(item);
            }
            break;
        }
      }));
      setState(() {
        _isSearching = true;
        _usersForSearch.clear();
        _usersForSearch.addAll(dummyUserData);
      });
    } else {
      setState(() {
        _isSearching = false;
        _usersForSearch.clear();
      });
    }
  }
}
