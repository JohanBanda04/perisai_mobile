import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perisai_mobile/helpers/app_colors.dart';
import 'package:perisai_mobile/helpers/api_endpoints.dart';

class DataMasterPage extends StatefulWidget {
  const DataMasterPage({super.key});

  @override
  State<DataMasterPage> createState() => _DataMasterPageState();
}

class _DataMasterPageState extends State<DataMasterPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  /// 🔍 Debounce pencarian
  void onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchUsers(query: searchController.text);
    });
  }

  /// 🔹 Ambil data pengguna
  Future<void> fetchUsers({String? query}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() => isLoading = true);

    try {
      final uri = Uri.parse(
        ApiEndpoints.dataSatker,
      ).replace(queryParameters: {'search': query ?? ''});

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data (${response.statusCode})');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// 🔹 Ambil kode satker baru
  Future<String?> getNewKodeSatker() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.dataSatker),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['kode_baru'];
      }
    } catch (e) {
      debugPrint('Gagal ambil kode satker baru: $e');
    }
    return null;
  }

  /// 🟣 Tambah / Update pengguna
  Future<void> submitSatker(
    Map<String, String> fields, {
    File? foto,
    int? id,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = id == null
        ? Uri.parse(ApiEndpoints.dataSatker)
        : Uri.parse('${ApiEndpoints.dataSatker}/$id');

    final request = http.MultipartRequest(id == null ? 'POST' : 'POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll(fields);

    if (id != null) request.fields['_method'] = 'PUT';
    if (foto != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    }

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            id == null
                ? 'Data berhasil ditambahkan'
                : 'Data berhasil diperbarui',
          ),
        ),
      );
      fetchUsers();
      Navigator.pop(context);
    } else {
      final res = await response.stream.bytesToString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: $res')));
    }
  }

  /// 🧩 Form Tambah / Edit
  Future<void> showForm({Map<String, dynamic>? user}) async {
    final nameController = TextEditingController(text: user?['name'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final kodeController = TextEditingController(
      text: user?['kode_satker'] ?? '',
    );
    final noHpController = TextEditingController(text: user?['no_hp'] ?? '');
    final passwordController = TextEditingController();
    String? selectedRole = user?['roles'];
    File? fotoFile;

    final picker = ImagePicker();

    if (user == null) {
      final newKode = await getNewKodeSatker();
      if (newKode != null) kodeController.text = newKode;
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user == null ? 'Tambah Satker Baru' : 'Edit Satker',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (picked != null) {
                        setModalState(() => fotoFile = File(picked.path));
                      }
                    },
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: fotoFile != null
                          ? FileImage(fotoFile!)
                          : (user?['foto'] != null
                                    ? NetworkImage(
                                        ApiEndpoints.fotoSatker(user!['foto']),
                                      )
                                    : null)
                                as ImageProvider?,
                      child: fotoFile == null && user?['foto'] == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Satker'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: kodeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Kode Satker',
                      suffixIcon: Icon(Icons.lock, color: Colors.grey),
                    ),
                  ),
                  TextField(
                    controller: noHpController,
                    decoration: const InputDecoration(labelText: 'Nomor HP'),
                  ),
                  if (user == null)
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'humas_satker',
                        child: Text('Humas Satker'),
                      ),
                      DropdownMenuItem(
                        value: 'humas_kanwil',
                        child: Text('Humas Kanwil'),
                      ),
                      DropdownMenuItem(
                        value: 'superadmin',
                        child: Text('Administrator'),
                      ),
                    ],
                    onChanged: (v) => setModalState(() => selectedRole = v),
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          kodeController.text.isEmpty ||
                          selectedRole == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Harap isi semua field wajib!'),
                          ),
                        );
                        return;
                      }

                      final data = {
                        'name': nameController.text,
                        'email': emailController.text,
                        'kode_satker': kodeController.text,
                        'no_hp': noHpController.text,
                        'roles': selectedRole!,
                      };
                      if (passwordController.text.isNotEmpty) {
                        data['password'] = passwordController.text;
                      }

                      submitSatker(
                        data,
                        foto: fotoFile,
                        id: user != null ? user['id'] : null,
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: Text(user == null ? 'Simpan' : 'Perbarui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🔴 Konfirmasi dan hapus data
  Future<void> confirmDelete(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      deleteUser(id);
    }
  }

  Future<void> deleteUser(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${ApiEndpoints.dataSatker}/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Berhasil dihapus')));
      fetchUsers();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Data Master Pengguna'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Satker',
            onPressed: () => showForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama / kode / email ...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          color: Colors.white.withOpacity(0.1),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              backgroundImage: user['foto'] != null
                                  ? NetworkImage(
                                      ApiEndpoints.fotoSatker(user['foto']),
                                    )
                                  : null,
                              child: user['foto'] == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            title: Text(
                              user['name'] ?? 'Tanpa Nama',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${user['kode_satker']} • ${user['roles']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed: () => showForm(user: user),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () =>
                                      confirmDelete(user['id'], user['name']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
