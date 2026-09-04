import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Stream of raw Firebase Auth user state
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

/// Stream of current user's Firestore profile
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateChangesProvider).value;
  if (authState == null) return Stream.value(null);

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getUserStream(authState.uid);
});

enum AuthStatus { initial, unauthenticated, authenticatedNoProfile, authenticatedWithProfile }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  AuthNotifier({
    required this._authRepo,
    required this._userRepo,
  })  : super(const AuthState());

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _authRepo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final profile = await _userRepo.getUserProfile(credential.user!.uid);
      if (profile != null) {
        state = state.copyWith(
          status: AuthStatus.authenticatedWithProfile,
          user: profile,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticatedNoProfile,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _authRepo.signInWithGoogle();
      if (credential.user != null) {
        final profile = await _userRepo.getUserProfile(credential.user!.uid);
        if (profile != null) {
          state = state.copyWith(
            status: AuthStatus.authenticatedWithProfile,
            user: profile,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.authenticatedNoProfile,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> register({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepo.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticatedNoProfile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> completeProfileOnboarding({
    required String fullName,
    required DateTime dateOfBirth,
    required String city,
    String? stateName,
    String bio = '',
    List<String> preferredLanguages = const ['English'],
    List<String> travelInterests = const [],
    List<String> travelStyles = const [],
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final authUser = _authRepo.currentUser;
      if (authUser == null) throw Exception('No authenticated user session found.');

      final newUser = UserModel.create(
        id: authUser.uid,
        email: authUser.email ?? '',
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        city: city,
        state: stateName,
        bio: bio,
        preferredLanguages: preferredLanguages,
        travelInterests: travelInterests,
        travelStyles: travelStyles,
      );

      await _userRepo.createUserProfile(newUser);

      state = state.copyWith(
        status: AuthStatus.authenticatedWithProfile,
        user: newUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _userRepo.updateUserProfile(updatedUser);
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepo.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepo.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true);
    try {
      final uid = _authRepo.currentUser?.uid;
      if (uid != null) {
        await _userRepo.deleteUserProfile(uid);
      }
      await _authRepo.deleteAccount();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  return AuthNotifier(authRepo: authRepo, userRepo: userRepo);
});
