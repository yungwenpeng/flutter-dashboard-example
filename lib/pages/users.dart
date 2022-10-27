import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thingsboard_app/controllers/user_base.dart';

import '../models/models.dart';
import 'pages.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

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

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _loadUserInfo();
  }

  void _loadUserInfo() async {
    _users = [];
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
      backgroundColor: Colors.transparent,
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.drawerUsers),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: const MyDrawer(),
      body:
          columnCount == 2 ? createGridBody(context) : createListBody(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
              heroTag: "viewModule",
              tooltip: AppLocalizations.of(context)!.usersFloatActionViewModule,
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
                      AppLocalizations.of(context)!.usersFloatActionAddUser,
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
      ),
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
      });
    } else {
      setState(() {
        columnCount = 2;
        aspectWidth = 2;
        aspectHeight = 1;
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
        title: Text(AppLocalizations.of(context)!.usersUpdateDialogTitle,
            textAlign: TextAlign.center),
        content: SingleChildScrollView(
            child: Column(
          children: [
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.usersUpdateDialogName,
                  hintText:
                      AppLocalizations.of(context)!.usersUpdateDialogName),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.usersUpdateDialogEmail,
                  hintText:
                      AppLocalizations.of(context)!.usersUpdateDialogEmail),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.usersUpdateDialogPassword,
                  hintText:
                      AppLocalizations.of(context)!.usersUpdateDialogPassword),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.usersUpdateDialogRole,
                  hintText:
                      AppLocalizations.of(context)!.usersUpdateDialogRole),
            ),
          ],
        )),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.usersUpdateDialogCancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.usersUpdateDialogSave),
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
}
