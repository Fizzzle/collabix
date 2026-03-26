import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/features/create_chat/bloc/create_chat_bloc/create_chat_bloc.dart';
import 'package:collabix/features/create_chat/bloc/fetch_all_users_bloc/fetch_all_users_bloc.dart';
import 'package:collabix/features/create_chat/data/datasource/create_chat_remote_datasource.dart';
import 'package:collabix/features/create_chat/data/datasource/user_remote_data_source.dart';
import 'package:collabix/features/create_chat/data/repository/create_chat_repository_impl.dart';
import 'package:collabix/features/create_chat/data/repository/user_repo_impl.dart';
import 'package:collabix/features/create_chat/domain/usecase/create_chat_use_case.dart';
import 'package:collabix/features/create_chat/domain/usecase/fetch_all_users_use_case.dart';
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
    final createChatRemote = ChatCreationRemoteDataSourceImpl(firestore);
    final createChatRepository = CreateChatRepositoryImpl(createChatRemote);
    final createChatUseCase = CreateChatUseCase(createChatRepository);

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
            BlocProvider<CreateChatBloc>(
              create: (_) => CreateChatBloc(createChatUseCase),
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
