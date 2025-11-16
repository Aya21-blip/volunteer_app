import 'package:flutter/material.dart';
import 'family.dart';
import 'family_table_page.dart';

class FormPage extends StatefulWidget {
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  // الحقول الأساسية
  final TextEditingController headController = TextEditingController();
  final TextEditingController spouseController = TextEditingController();
  final TextEditingController displacementController = TextEditingController();
  final TextEditingController residenceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  List<FamilyMember> members = [];
  List<String> phoneNumbers = [];

  // الاحتياجات
  Map<String, bool> needsMap = {
    'سلة غذائية': false,
    'بطانيات': false,
    'فرش': false,
    'أدوات منزلية': false,
    'حفاضات': false,
    'حليب': false,
    'مبلغ مالي': false,
    'ملابس أو أحذية': false,
    'حالة طبية': false,
    'شيء آخر': false,
  };

  // حقول إضافية عند اختيار شيء آخر أو حالة طبية
  Map<String, TextEditingController> extraNeedsControllers = {
    'حالة طبية': TextEditingController(),
    'شيء آخر': TextEditingController(),
  };

  // التلبية
  Map<String, dynamic> fulfillmentMap = {};

  // النوع والمنزل
  String homeType = 'ملك';
  bool hasProvider = false;

  void addMember() {
    String memberName = '';
    String memberGender = 'ذكر';
    int memberAge = 0;

    final memberFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة فرد جديد'),
        content: Form(
          key: memberFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'الاسم'),
                onChanged: (val) => memberName = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'الرجاء إدخال الاسم' : null,
              ),
              DropdownButtonFormField<String>(
                value: memberGender,
                items: ['ذكر', 'أنثى']
                    .map((e) => DropdownMenuItem(child: Text(e), value: e))
                    .toList(),
                onChanged: (val) => memberGender = val!,
                decoration: InputDecoration(labelText: 'الجنس'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'العمر'),
                keyboardType: TextInputType.number,
                onChanged: (val) => memberAge = int.tryParse(val) ?? 0,
                validator: (val) =>
                    val == null || val.isEmpty ? 'الرجاء إدخال العمر' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (memberFormKey.currentState!.validate()) {
                setState(() {
                  members.add(FamilyMember(
                      name: memberName, gender: memberGender, age: memberAge));
                });
                Navigator.pop(context);
              }
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void addPhone() {
    String phone = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة رقم تواصل'),
        content: TextFormField(
          keyboardType: TextInputType.number,
          onChanged: (val) => phone = val,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (phone.isNotEmpty) {
                setState(() {
                  phoneNumbers.add(phone);
                });
                Navigator.pop(context);
              }
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void saveFamily() {
    if (_formKey.currentState!.validate()) {
      // جمع الاحتياجات المختارة
      List<String> selectedNeeds = [];
      needsMap.forEach((key, value) {
        if (value) selectedNeeds.add(key);
      });

      FamilyTablePage.families.add(Family(
        headName: headController.text,
        spouseName: spouseController.text,
        memberCount: members.length,
        members: members,
        phoneNumbers: phoneNumbers,
        displacementPlace: displacementController.text,
        currentResidence: residenceController.text,
        homeType: homeType,
        hasProvider: hasProvider,
        needs: selectedNeeds,
        fulfillment: fulfillmentMap,
        notes: notesController.text,
        extraNeeds: extraNeedsControllers.map((k, v) => MapEntry(k, v.text)),
      ));

      Navigator.pop(context);
    }
  }

  // واجهة التلبية لكل احتياج
  Widget buildFulfillmentCard(String need) {
    switch (need) {
      case 'سلة غذائية':
      case 'فرش':
      case 'بطانيات':
      case 'مبلغ مالي':
        return TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'العدد لـ $need'),
          onChanged: (val) => fulfillmentMap[need] = val,
        );

      case 'حفاضات':
        if (!fulfillmentMap.containsKey(need)) fulfillmentMap[need] = [];
        return Column(
          children: [
            ...List.generate(fulfillmentMap[need].length, (index) {
              Map item = fulfillmentMap[need][index];
              return Card(
                child: ListTile(
                  title: Text('حفاضات ${item['type']}'),
                  subtitle: item['type'] == 'طفل'
                      ? Text('القياس: ${item['size']}')
                      : Text('العجزة: ${item['elder']}'),
                ),
              );
            }),
            ElevatedButton(
              onPressed: () {
                String type = 'طفل';
                String size = '';
                String elder = 'صغير';
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('إضافة حفاضات'),
                    content: StatefulBuilder(
                      builder: (context, setStateDialog) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: type,
                            items: ['طفل', 'عجزة']
                                .map((e) =>
                                    DropdownMenuItem(child: Text(e), value: e))
                                .toList(),
                            onChanged: (val) {
                              setStateDialog(() => type = val!);
                            },
                          ),
                          if (type == 'طفل')
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: 'القياس'),
                              onChanged: (val) => size = val,
                            ),
                          if (type == 'عجزة')
                            DropdownButton<String>(
                              value: elder,
                              items: ['صغير', 'وسط', 'كبير', 'كبير جدًا']
                                  .map((e) =>
                                      DropdownMenuItem(child: Text(e), value: e))
                                  .toList(),
                              onChanged: (val) => setStateDialog(() => elder = val!),
                            ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            fulfillmentMap[need].add({
                              'type': type,
                              'size': size,
                              'elder': elder,
                            });
                          });
                          Navigator.pop(context);
                        },
                        child: Text('إضافة'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('+'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        );

      case 'حليب':
        return DropdownButtonFormField<String>(
          value: 'حليب جينا',
          decoration: InputDecoration(labelText: 'اختر نوع الحليب'),
          items: ['حليب جينا', 'نان1', 'نان2']
              .map((e) => DropdownMenuItem(child: Text(e), value: e))
              .toList(),
          onChanged: (val) => fulfillmentMap[need] = val,
        );

      default:
        return Container();
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
            Text('إضافة عائلة جديدة'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الحقول الأساسية
              TextFormField(
                controller: headController,
                decoration: InputDecoration(labelText: 'اسم رب الأسرة'),
                validator: (val) =>
                    val!.isEmpty ? 'الرجاء إدخال اسم رب الأسرة' : null,
              ),
              TextFormField(
                controller: spouseController,
                decoration: InputDecoration(labelText: 'اسم الزوجة'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: addMember,
                child: Text('إضافة فرد جديد'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: addPhone,
                child: Text('إضافة رقم تواصل'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              TextFormField(
                controller: displacementController,
                decoration: InputDecoration(labelText: 'مكان التهجير'),
              ),
              TextFormField(
                controller: residenceController,
                decoration: InputDecoration(labelText: 'مكان الإقامة الحالي'),
              ),
              DropdownButtonFormField<String>(
                value: homeType,
                items: ['ملك', 'استضافة', 'إيجار']
                    .map((e) => DropdownMenuItem(child: Text(e), value: e))
                    .toList(),
                onChanged: (val) => setState(() => homeType = val!),
                decoration: InputDecoration(labelText: 'نوع المنزل'),
              ),
              SwitchListTile(
                title: Text('يوجد معيل'),
                value: hasProvider,
                onChanged: (val) => setState(() => hasProvider = val),
              ),
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'ملاحظات'),
              ),
              SizedBox(height: 20),
              // الاحتياجات بالـ Cards
              Text('الاحتياجات:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: needsMap.keys.map((need) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      needsMap[need] = !needsMap[need]!;
                    }),
                    child: Card(
                      color: needsMap[need]! ? Colors.green[200] : Colors.white,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(need),
                            if ((need == 'حالة طبية' || need == 'شيء آخر') &&
                                needsMap[need]!)
                              TextFormField(
                                controller: extraNeedsControllers[need],
                                decoration: InputDecoration(
                                  labelText: need == 'حالة طبية'
                                      ? 'شرح الحالة'
                                      : 'اذكر الحاجة',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              // التلبية
              Text('ستتم التلبية:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Column(
                children: needsMap.keys
                    .where((need) => needsMap[need]!)
                    .map((need) => buildFulfillmentCard(need))
                    .toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveFamily,
                child: Text('حفظ العائلة'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
