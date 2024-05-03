import 'package:flutter/material.dart';
import 'package:pacel_trans_app/color_themes.dart';


final primaryColor = new ColorTheme();
class PollBookingPage extends StatefulWidget {
  const PollBookingPage({super.key});

  @override
  State<PollBookingPage> createState() => _PollBookingPageState();
}

class _PollBookingPageState extends State<PollBookingPage> {
  int _selectedIndex = 0;
  int _selectedPackageSizeIndex = 0;
  bool _isChecked = false;

  void _onCheckboxChanged(bool? value) {
    setState(() {
      _isChecked = value!;
    });
  }

  List<String> packageTypeList = [
    "Clothes",
    "Documents",
    "Funicture",
    "Electronics",
  ];
  List<String> packageSize = [
    "20x20",
    "20x40",
    "40x40",
    "other",
  ];

  _selectPackageType(index){
    setState(() {
      _selectedIndex = index;
    });
  }

  _selectPackageSize(index){
    setState(() {
      _selectedPackageSizeIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
        child: ListView(children: [
          Text("Package details",style: TextStyle(fontSize: 19,fontWeight: FontWeight.w600),),
          Text("what are you sending?",style: TextStyle(fontSize: 11,fontWeight: FontWeight.w600),),
          SizedBox(height: 20.0,),
          Container(
            width: double.infinity,
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:  packageTypeList.length,
              itemBuilder: (context, index){
              return PackageType(title: packageTypeList[index], ontap: (){
                _selectPackageType(index);
              }, index: index,selectedIndex: _selectedIndex,);
            },),
          ),
          SizedBox(height: 25,),
          Text("Package size",style: TextStyle(fontSize: 19,fontWeight: FontWeight.w600),),
          SizedBox(height: 10,),
          Container(
            width: double.infinity,
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:  packageSize.length,
              itemBuilder: (context, index){
                return PackageSize(title: packageSize[index], ontap: (){
                  _selectPackageSize(index);
                }, index: index,selectedIndex: _selectedPackageSizeIndex,);
              },),
          ),
          SizedBox(height: 30.0,),
          Row(children: [
            Checkbox(
              value: this._isChecked,
              onChanged: _onCheckboxChanged
            ),
            Text("Breakable items")
          ],
          ),
          Row(children: [
            Checkbox(
                value: this._isChecked,
                onChanged: _onCheckboxChanged
            ),
            Text("No prohibited items")
          ],
          ),

        ],),
      ),
    );
  }
}

class PackageType extends StatelessWidget {
  final String title;
  final Function()? ontap;
  final int index;
  final int selectedIndex;
  const PackageType({super.key,
    required this.title,
    required this.ontap,
    required this.index,
    required this.selectedIndex
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: 15),
        // width: 130,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
            border: (index==selectedIndex)?Border.all(width: 2, color:  Color.fromRGBO(47, 66, 96, 1.0)):Border.all(width: 1, color:  Colors.black12),
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [Icon(Icons.book),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title,style: TextStyle(fontWeight: FontWeight.w600),),
            ),
          ],),
      ),
    );
  }
}

class PackageSize extends StatelessWidget {
  final String title;
  final Function()? ontap;
  final int index;
  final int selectedIndex;
  const PackageSize({super.key,
    required this.title,
    required this.ontap,
    required this.index,
    required this.selectedIndex
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.all(18),
          width: 95,
          height: 95,
          decoration: BoxDecoration(
              color: Colors.white,
              border: (index==selectedIndex)?Border.all(width: 2, color:  Color.fromRGBO(47, 66, 96, 1.0)):Border.all(width: 1, color:  Colors.black12),
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Image.asset('assets/img/box.png'),
        ),
        Text(title,style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))
      ],)
    );
  }
}

