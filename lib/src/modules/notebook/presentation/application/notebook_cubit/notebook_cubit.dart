import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/model/response_model.dart';
import '../../../domain/entity/cell_entity.dart';
import '../../../domain/entity/socket_type.dart';
import '../../../domain/repository/notebook_repo.dart';
import '../cubit/cell_cubit.dart';

part 'notebook_state.dart';
part 'notebook_cubit.freezed.dart';

class NotebookCubit extends Cubit<NotebookState> {
  final NotebookRepo _notebookRepo;
  NotebookCubit(this._notebookRepo) : super(NotebookState.initial([])) {
    addCell();
    _listenToServerResponses();
  }

  int currentRunningCell = 1;
  final Map<int, CellCubit> cellCubits = {};

  void addCell() {
    final newCell = CellEntity(controller: TextEditingController());
    final List<CellEntity> newCells = List.of(state.cellEntities);
    newCells.add(newCell);
    emit(state.copyWith(cellEntities: newCells));
  }

  void removeCell(int index) {
    final List<CellEntity> newState = List.of(state.cellEntities);
    newState.removeAt(index);
    cellCubits.remove(index);
    emit(state.copyWith(cellEntities: newState));
  }

  void sendCodeToServer(String code, int cellIndex) {
    currentRunningCell = cellIndex;
    // cellCubits[cellIndex]?.runCode(code); // change cell state to `running`
    _notebookRepo.request(code);
  }

  void _listenToServerResponses() {
    _notebookRepo.response().listen((response) {
      if (currentRunningCell != null) {
        updateCellOutput(currentRunningCell!, response);
      }
    });
  }

  void updateCellOutput(int cellIndex, ResponseModel response) {
    if (response.type == SocketType.response) {
      cellCubits[cellIndex]?.receiveOutput(response.data ?? '');
    } else if (response.type == SocketType.response ||
        response.type == SocketType.pause) {
      cellCubits[cellIndex]?.receiveOutput(response.data ?? '');
    } else if (response.type == SocketType.error) {
      cellCubits[cellIndex]?.receiveOutput("🔴 Error: ${response.data ?? ''}");
    }
  }

  void completeExecution(int cellIndex) {
    cellCubits[cellIndex]?.completeExecution();
  }
}
