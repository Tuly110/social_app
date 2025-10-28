import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../app/app_router.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: TextButton(
              onPressed: (){
                context.router.push(NotebookRoute());
              } , 
              child: Text('New notebook')),
          )
        ],
      ),
    );
  }
}