
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var castedState=(BlocProvider.of<UserAuthCubit>(context).state as UserAuthorized);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(8),
      child:  Row(
        children: [
          const SizedBox(width: 5),
          const Icon(
            Icons.account_circle,
            size: 50,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${castedState.user.fname} ${castedState.user.lname}",
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                castedState.user.companyName,
                style:const TextStyle(fontSize: 12),
              ),
              Text(
                castedState.user.phone,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }
}
