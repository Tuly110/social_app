import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../application/cubit/cell_cubit.dart';

class CodeCellWidget extends StatelessWidget {
  const CodeCellWidget(
      {super.key,
      required this.controller,
      required this.index,
      required this.output});

  final TextEditingController controller;
  final String index;
  final String output;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "In [$index]:",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Gap(8),
                      TextField(
                        controller: controller,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<CellCubit, ({CellState state, String output})>(
                  builder: (context, state) {
                    return IconButton(
                      onPressed: () {
                        if (state.state == CellState.stopped) {
                          context.read<CellCubit>().runCode(controller.text);
                        }
                      },
                      icon: state.state == CellState.running
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(Icons.play_arrow, color: Colors.white),
                    );
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                output,
                style: TextStyle(
                  color:
                      output.contains("Error") ? Colors.red : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
