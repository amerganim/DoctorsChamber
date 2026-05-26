import 'package:go_router/go_router.dart';

import '../features/admin/admin_home_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_verify_screen.dart';
import '../features/auth/role_select_screen.dart';
import '../features/auth/user_role.dart';
import '../features/doctor/doctor_home_screen.dart';
import '../features/patient/patient_home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const RoleSelectScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, state) => LoginScreen(role: state.extra as UserRole),
      routes: [
        GoRoute(
          path: 'verify',
          builder: (_, state) {
            final args = state.extra as Map<String, dynamic>;
            return OtpVerifyScreen(
              role: args['role'] as UserRole,
              phone: args['phone'] as String,
              verificationId: args['verificationId'] as String,
            );
          },
        ),
      ],
    ),
    GoRoute(path: '/patient', builder: (_, _) => const PatientHomeScreen()),
    GoRoute(path: '/doctor', builder: (_, _) => const DoctorHomeScreen()),
    GoRoute(path: '/admin', builder: (_, _) => const AdminHomeScreen()),
  ],
);
