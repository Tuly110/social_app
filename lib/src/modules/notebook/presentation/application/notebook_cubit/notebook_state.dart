part of 'notebook_cubit.dart';

@freezed
class NotebookState with _$NotebookState {
  const factory NotebookState.initial(List<CellEntity> cellEntities) = _Initial;
}
