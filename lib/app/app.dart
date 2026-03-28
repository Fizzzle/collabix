import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/features/create_group/bloc/create_group_bloc/create_group_bloc.dart';
import 'package:collabix/features/create_group/bloc/fetch_all_users_bloc/fetch_all_users_bloc.dart';
import 'package:collabix/features/create_group/data/datasource/create_group_remote_datasource.dart';
import 'package:collabix/features/create_group/data/datasource/user_remote_data_source.dart';
import 'package:collabix/features/create_group/data/repository/create_group_repository_impl.dart';
import 'package:collabix/features/create_group/data/repository/user_repo_impl.dart';
import 'package:collabix/features/create_group/domain/usecase/create_group_use_case.dart';
import 'package:collabix/features/create_group/domain/usecase/fetch_all_users_use_case.dart';
import 'package:collabix/features/home/presentation/home_screen.dart';
import 'package:collabix/features/login/presentation/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final createGroupRemote = GroupCreationRemoteDataSourceImpl(firestore);
    final createGroupRepository = CreateGroupRepositoryImpl(createGroupRemote);
    final createGroupUseCase = CreateGroupUseCase(createGroupRepository);

    final fetchAllUsersRemote = UserRemoteDataSourceImpl(firestore);
    final fetchAllUserRepository = UserRepoImpl(fetchAllUsersRemote);
    final fetchAllUsersUseCase = FetchAllUsersUseCase(fetchAllUserRepository);

    return ScreenUtilInit(
      designSize: const Size(412, 917),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MultiBlocProvider(
          providers: [
            //1. Create Chat Bloc
            BlocProvider<CreateGroupBloc>(
              create: (_) => CreateGroupBloc(createGroupUseCase),
            ),

            //2. Fetch All Users Bloc
            BlocProvider<FetchAllUsersBloc>(
              create: (_) => FetchAllUsersBloc(fetchAllUsersUseCase),
            ),
          ],
          child: MaterialApp(
            title: 'Collabix',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true),
            home: const _AuthGate(),
          ),
        );
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
