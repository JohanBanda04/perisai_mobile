import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perisai_mobile/helpers/api_endpoints.dart';
import 'package:perisai_mobile/helpers/app_colors.dart';

class FormBeritaPage extends StatefulWidget {
  const FormBeritaPage({super.key});

  @override
  State<FormBeritaPage> createState() => _FormBeritaPageState();
}

class _FormBeritaPageState extends State<FormBeritaPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController namaBeritaController = TextEditingController();
  TextEditingController facebookController = TextEditingController(text: '-');
  TextEditingController websiteController = TextEditingController(text: '-');
  TextEditingController instagramController = TextEditingController(text: '-');
  TextEditingController twitterController = TextEditingController(text: '-');
  TextEditingController tiktokController = TextEditingController(text: '-');
  TextEditingController sippnController = TextEditingController(text: '-');
  TextEditingController youtubeController = TextEditingController(text: '-');

  String? kodeSatker;
  String? selectedDivisi;
  String? selectedPrioritas;

  List<Map<String, String>> mediaLokalList = [];
  List<Map<String, String>> mediaNasionalList = [];

  List<dynamic> divisiList = [];
  List<dynamic> prioritasList = [];
  List<dynamic> mediaList = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    kodeSatker = prefs.getString('kode_satker');
    await _fetchDropdownData();
    setState(() {});
  }

  Future<void> _fetchDropdownData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(ApiEndpoints.dataBerita),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      divisiList = data['divisi'] ?? [];
      prioritasList = data['prioritas'] ?? [];
      mediaList = data['media_partner'] ?? [];
    }
  }

  void _addMediaLokal() {
    setState(() {
      mediaLokalList.add({'kode_media': '', 'judul': '', 'link': ''});
    });
  }

  void _addMediaNasional() {
    setState(() {
      mediaNasionalList.add({'kode_media': '', 'judul': '', 'link': ''});
    });
  }

  void _removeMediaLokal(int index) {
    setState(() {
      mediaLokalList.removeAt(index);
    });
  }

  void _removeMediaNasional(int index) {
    setState(() {
      mediaNasionalList.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.dataBerita),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'kode_satker': kodeSatker,
          'nama_berita': namaBeritaController.text,
          'facebook': facebookController.text,
          'website': websiteController.text,
          'instagram': instagramController.text,
          'twitter': twitterController.text,
          'tiktok': tiktokController.text,
          'sippn': sippnController.text,
          'youtube': youtubeController.text,
          'kode_divisi': selectedDivisi ?? '',
          'prioritas_id': selectedPrioritas ?? '',
          'media_lokal': jsonEncode(mediaLokalList),
          'media_nasional': jsonEncode(mediaNasionalList),
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berita berhasil disimpan!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal simpan (${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildMediaList(String label, List<Map<String, String>> list, bool isLokal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: isLokal ? Colors.green : Colors.orange),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
              onPressed: isLokal ? _addMediaLokal : _addMediaNasional,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(list.length, (index) {
          final item = list[index];
          final mediaFiltered = mediaList
              .where((m) => m['jenis_media'] == (isLokal ? 'media_lokal' : 'media_nasional'))
              .toList();
          return Card(
            color: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: item['kode_media'],
                    decoration: const InputDecoration(labelText: 'Nama Media', labelStyle: TextStyle(color: Colors.white)),
                    items: mediaFiltered.map((m) {
                      return DropdownMenuItem<String>(
                        value: m['kode_media'],
                        child: Text(m['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => item['kode_media'] = value ?? ''),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Judul Berita'),
                    onChanged: (v) => item['judul'] = v,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Link Berita'),
                    onChanged: (v) => item['link'] = v,
                  ),
                  TextButton.icon(
                    onPressed: () => isLokal
                        ? _removeMediaLokal(index)
                        : _removeMediaNasional(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Data Berita'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                readOnly: true,
                initialValue: kodeSatker ?? '-',
                decoration: const InputDecoration(labelText: 'Kode Satker'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: namaBeritaController,
                decoration: const InputDecoration(labelText: 'Judul Berita'),
                validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Divisi'),
                value: selectedDivisi,
                items: divisiList.map((d) {
                  return DropdownMenuItem<String>(
                    value: d['kode_divisi'],
                    child: Text(d['nama_divisi']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedDivisi = v),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Prioritas'),
                value: selectedPrioritas,
                items: prioritasList.map((p) {
                  return DropdownMenuItem<String>(
                    value: p['id_prioritas'].toString(),
                    child: Text(p['nama_prioritas_lengkap']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedPrioritas = v),
              ),
              const SizedBox(height: 20),
              buildMediaList("Media Lokal", mediaLokalList, true),
              const SizedBox(height: 20),
              buildMediaList("Media Nasional", mediaNasionalList, false),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.save),
                label: const Text("Simpan Berita"),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
