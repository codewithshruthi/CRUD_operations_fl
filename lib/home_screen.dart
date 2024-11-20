import 'package:crud_application/hive_functions.dart';
import 'package:flutter/material.dart';

class CrudApp extends StatefulWidget {
  const CrudApp({super.key});

  @override
  State<CrudApp> createState() => _CrudAppState();
}

class _CrudAppState extends State<CrudApp> {
  List myHiveData = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getHiveData();
  }

  getHiveData() {
    myHiveData = HiveFunctions.getAllUsers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Hive CRUD Operations',
          ),
          actions: [
            IconButton(
                onPressed: () {
                  HiveFunctions.deleteAllUsers();
                  getHiveData();
                },
                icon: const Icon(Icons.playlist_remove_outlined))
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showForm(null);
          },
          label: const Text('Add Data'),
          icon: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: myHiveData.isEmpty
              ? const Center(
                  child: Text(
                    'No data is available!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                )
              : Column(
                  children: List.generate(myHiveData.length, (index) {
                    final userData = myHiveData[index];
                    return Card(
                      child: ListTile(
                        title: Text("Name:${userData["name"]}"),
                        subtitle: Text("Email :${userData["email"]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () {
                                  showForm(userData["key"]);
                                },
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () {
                                  HiveFunctions.deleteUser(userData["key"]);
                                  getHiveData();
                                },
                                icon: const Icon(Icons.delete))
                          ],
                        ),
                      ),
                    );
                  }),
                ),
        ));
  }

  void showForm(int? itemKey) {
    if (itemKey != null) {
      final existingItem =
          myHiveData.firstWhere((element) => element['key'] == itemKey);
      nameController.text = existingItem['name'];
      emailController.text = existingItem['email'];
    } else {
      nameController.text = '';
      emailController.text = '';
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 15,
              left: 15,
              right: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  itemKey == null ? 'Create New' : 'Update',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text != '' && emailController.text != '') {
                    if (itemKey == null) {
                      HiveFunctions.createUser({
                        "name": nameController.text,
                        "email": emailController.text
                      });
                    }
                    if (itemKey != null) {
                      HiveFunctions.updateUser(itemKey, {
                        "name": nameController.text,
                        "email": emailController.text
                      });
                    }
                    nameController.text = '';
                    emailController.text = '';
                    Navigator.of(context).pop();
                    getHiveData();
                  } else {
                    Navigator.pop(context);
                    const snackBar = SnackBar(
                      content: Text('Enter the name and email'),
                      duration: Duration(seconds: 10),
                    );
                    print('Enter the name and email');
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Text(
                  itemKey == null ? 'Create New' : 'Update',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
