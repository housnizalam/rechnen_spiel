import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rechnen_spiel/bloc/app_bloc.dart';

class ApBar extends StatelessWidget {
  const ApBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        return AppBar(
          title:
              Text(state.title, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
          actions: [
            Center(
              child: Text(state.calcOperation,
                  style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold)),
            ),
            Center(
                child: IconButton(
              icon: const Icon(
                Icons.change_circle_sharp,
                color: Colors.black,
              ),
              onPressed: () {
                BlocProvider.of<AppBloc>(context).add(ChooseOperationEvent());
              },
            ))
          ],
        );
      },
    );
  }
}
