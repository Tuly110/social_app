import 'package:bloc/bloc.dart';

import '../notebook_cubit/notebook_cubit.dart';

enum CellState { stopped, running }

class CellCubit extends Cubit<({CellState state, String output})> {
  final int cellIndex;
  final NotebookCubit notebookCubit;

  CellCubit({required this.cellIndex, required this.notebookCubit})
      : super((state: CellState.stopped, output: ''));

  void runCode(String code) {
    emit((state: CellState.running, output: ''));
    notebookCubit.sendCodeToServer(code, cellIndex);
  }

  void receiveOutput(String data) {
    emit((state: state.state, output: "${state.output}\n$data"));
  }

  void completeExecution() {
    emit((state: CellState.stopped, output: "${state.output}\n✅ Execution Finished!"));
  }
}