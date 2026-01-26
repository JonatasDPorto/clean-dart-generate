import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'external/datasources/user_model_datasource.dart';
import 'external/repositories/user_model_repository.dart';
import 'infra/model/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Dart Generate Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UserTestPage(),
    );
  }
}

class UserTestPage extends StatefulWidget {
  const UserTestPage({super.key});

  @override
  State<UserTestPage> createState() => _UserTestPageState();
}

class _UserTestPageState extends State<UserTestPage> {
  late final Dio dio;
  late final UserModelDatasource datasource;
  late final UserModelRepository repository;

  UserModel? _user;
  List<UserModel>? _users;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    datasource = UserModelDatasource(dio: dio);
    repository = UserModelRepository(datasource);
    _listUsers();
  }

  Future<void> _getUser(String id) async {
    setState(() {
      _loading = true;
      _error = null;
      _user = null;
    });

    final result = await repository.readUserModel(id);

    setState(() {
      _loading = false;
    });

    result.fold(
      (error) {
        setState(() {
          _error = error.message;
        });
      },
      (user) {
        setState(() {
          _user = user;
        });
      },
    );
  }

  Future<void> _listUsers() async {
    setState(() {
      _loading = true;
      _error = null;
      _user = null;
      _users = null;
    });

    final result = await repository.listAllUserModel();

    setState(() {
      _loading = false;
    });

    result.fold(
      (error) {
        setState(() {
          _error = error.message;
        });
      },
      (users) {
        setState(() {
          _users = users;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_user != null ? 'User Details' : 'Users List'),
        leading: _user != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _user = null;
                  });
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null && _users == null && _user == null)
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Error:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _listUsers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_users != null && _user == null)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _listUsers,
                  child: ListView.builder(
                    itemCount: _users!.length,
                    itemBuilder: (context, index) {
                      final user = _users![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email),
                              const SizedBox(height: 4),
                              Text(
                                '@${user.username}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '#${user.id}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            _getUser(user.id.toString());
                          },
                        ),
                      );
                    },
                  ),
                ),
              )
            else if (_user != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'User Data:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _user = null;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildUserInfo('ID', _user!.id.toString()),
                        _buildUserInfo('Name', _user!.name),
                        _buildUserInfo('Username', _user!.username),
                        _buildUserInfo('Email', _user!.email),
                        _buildUserInfo('Phone', _user!.phone),
                        _buildUserInfo('Website', _user!.website),
                        const SizedBox(height: 8),
                        const Text(
                          'Address:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        _buildUserInfo('Street', _user!.address.street),
                        _buildUserInfo('Suite', _user!.address.suite),
                        _buildUserInfo('City', _user!.address.city),
                        _buildUserInfo('Zipcode', _user!.address.zipcode),
                        _buildUserInfo(
                          'Geo',
                          '${_user!.address.geo.lat}, ${_user!.address.geo.lng}',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Company:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        _buildUserInfo('Name', _user!.company.name),
                        _buildUserInfo(
                          'Catch Phrase',
                          _user!.company.catchPhrase,
                        ),
                        _buildUserInfo('BS', _user!.company.bs),
                      ],
                    ),
                  ),
                ),
              )
            else if (_error == null && _users == null && _user == null)
              const Expanded(
                child: Center(
                  child: Text(
                    'Loading users...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
