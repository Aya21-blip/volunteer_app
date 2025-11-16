import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'family.dart';
import 'family_table_page.dart';

class ExportPage extends StatelessWidget {
  Future<void> exportToExcel(BuildContext context) async {
    if (FamilyTablePage.families.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا توجد بيانات لتصديرها')),
      );
      return;
    }

    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['العائلات'];

      // عناوين الأعمدة
      sheetObject.appendRow([
        'اسم رب الأسرة',
        'اسم الزوجة',
        'عدد الأفراد',
        'أسماء الأفراد',
        'أعمار الأفراد',
        'أرقام التواصل',
        'مكان التهجير',
        'مكان الإقامة الحالي',
        'نوع المنزل',
        'يوجد معيل',
        'الاحتياجات',
        'التلبية',
        'ملاحظات',
      ]);

      // إضافة بيانات كل عائلة
      for (var family in FamilyTablePage.families) {
        String membersStr = family.members
            .map((m) => '${m.name} (${m.gender}, ${m.age})')
            .join('; ');
        String agesStr = family.members.map((m) => '${m.age}').join(', ');
        String phonesStr = family.phoneNumbers.join(', ');
        String needsStr = family.needs.join(', ');
        String fulfillmentStr = family.fulfillment.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('; ');

        sheetObject.appendRow([
          family.headName,
          family.spouseName,
          family.memberCount,
          membersStr,
          agesStr,
          phonesStr,
          family.displacementPlace,
          family.currentResidence,
          family.homeType,
          family.hasProvider ? 'نعم' : 'لا',
          needsStr,
          fulfillmentStr,
          family.notes,
        ]);
      }

      // تحديد المسار بناءً على النظام
      Directory directory;
      if (Platform.isAndroid) {
        directory = (await getExternalStorageDirectory())!;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String path = directory.path;
      String fileName = '$path/families_export.xlsx';

      File(fileName)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم التصدير بنجاح: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التصدير: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            SizedBox(width: 10),
            Text('تصدير البيانات'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.file_download),
            label: Text('تصدير جميع البيانات إلى Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () => exportToExcel(context),
          ),
        ),
      ),
    );
  }
}