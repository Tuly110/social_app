import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../notebook/domain/repository/notebook_repo.dart';
import '../../notebook/presentation/application/notebook_cubit/notebook_cubit.dart';

import '../../../common/utils/getit_utils.dart';
import 'application/cubit/cell_cubit.dart';
import 'component/code_cell_widget.dart';

@RoutePage()
class NotebookPage extends StatelessWidget {
  const NotebookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => NotebookCubit(getIt<NotebookRepo>()),
        child: BlocBuilder<NotebookCubit, NotebookState>(
          builder: (context, state) {
            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: List.generate(state.cellEntities.length, (i) {
                    return BlocProvider(
                      create: (context) => CellCubit(
                        cellIndex: i,
                        notebookCubit: context.read<NotebookCubit>(),
                      ),
                      child: CodeCellWidget(
                        controller: state.cellEntities[i].controller,
                        index: i.toString(),
                        output: state.cellEntities[i].output,
                      ),
                    );
                  }),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  context.read<NotebookCubit>().addCell();
                },
                backgroundColor: Colors.blue,
                child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            );
          },
        ));
  }
}
