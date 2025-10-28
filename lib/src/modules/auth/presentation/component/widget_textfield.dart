import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:jupyternotebook/generated/colors.gen.dart';


class WidgetTextfield extends StatefulWidget {
  const WidgetTextfield({super.key});

  @override
  State<WidgetTextfield> createState() => _WidgetTextfieldState();
}

class _WidgetTextfieldState extends State<WidgetTextfield> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h,)
            ),
            Text("Email", style: TextStyle(fontSize: 13.sp),),
            Gap(8.h),
            TextField(
                decoration: InputDecoration(
                    filled: true,
                    fillColor:ColorName.textfield,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    border: InputBorder.none,
                    // contentPadding: ,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                    ),
                    focusedBorder:  OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide.none,
                    ),
                ),
            ),
            Gap(8.h),
            Text("Password", style: TextStyle(fontSize: 13.sp),),
            TextField(
                obscureText: isObscure,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: ColorName.textfield,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                        onPressed: (){
                            setState(() {
                               isObscure = !isObscure;
                            });
                        }, 
                        icon: FaIcon(
                            isObscure ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                            size: 16.sp,
                        ),
                        
                    )
                ),
            ),
            
            
        ],
    );
  }
}