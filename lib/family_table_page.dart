import 'package:flutter/material.dart';
import 'family.dart';

class FamilyTablePage extends StatefulWidget {
  static List<Family> families = [];

  @override
  State<FamilyTablePage> createState() => _FamilyTablePageState();
}

class _FamilyTablePageState extends State<FamilyTablePage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    List<Family> filtered = FamilyTablePage.families.where((f) {
      return f.headName.contains(search) ||
          f.spouseName.contains(search) ||
          f.fulfillment.keys.any((k) => k.contains(search));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            SizedBox(width: 10),
            Text('قائمة العائلات'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'ابحث باسم رب الأسرة أو الزوجة أو التلبية',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => search = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                Family f = filtered[index];
                return Card(
                  child: ListTile(
                    title: Text(f.headName),
                    subtitle: Text('عدد الأفراد: ${f.memberCount}'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('تفاصيل العائلة'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('اسم الزوجة: ${f.spouseName}'),
                                Text('الأفراد: ${f.members.map((m) => m.name).join(', ')}'),
                                Text('أعمار الأفراد: ${f.members.map((m) => m.age).join(', ')}'),
                                Text('أرقام التواصل: ${f.phoneNumbers.join(', ')}'),
                                Text('مكان التهجير: ${f.displacementPlace}'),
                                Text('مكان الإقامة الحالي: ${f.currentResidence}'),
                                Text('نوع المنزل: ${f.homeType}'),
                                Text('يوجد معيل: ${f.hasProvider ? 'نعم' : 'لا'}'),
                                Text('الاحتياجات: ${f.needs.join(', ')}'),
                                Text('التلبية: ${f.fulfillment.entries.map((e) => '${e.key}: ${e.value}').join('; ')}'),
                                Text('ملاحظات: ${f.notes}'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('إغلاق'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}