import 'package:go_router/go_router.dart';

import '../features/admin/admin_home_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_verify_screen.dart';
import '../features/auth/role_select_screen.dart';
import '../features/auth/user_role.dart';
import '../features/chambers/add_chamber_screen.dart';
import '../features/chambers/chambers_list_screen.dart';
import '../features/doctor/doctor_home_screen.dart';
import '../features/doctor/doctor_profile_editor_screen.dart';
import '../features/patient/my_bookings_screen.dart';
import '../features/patient/patient_chamber_queue_screen.dart';
import '../features/patient/patient_doctor_view_screen.dart';
import '../features/patient/patient_home_screen.dart';
import '../features/queue/queue_screen.dart';

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
    GoRoute(
      path: '/patient',
      builder: (_, _) => const PatientHomeScreen(),
      routes: [
        GoRoute(
          path: 'doctor/:doctorId',
          builder: (_, state) => PatientDoctorViewScreen(
            doctorId: state.pathParameters['doctorId']!,
          ),
        ),
        GoRoute(
          path: 'chamber/:chamberId',
          builder: (_, state) => PatientChamberQueueScreen(
            chamberId: state.pathParameters['chamberId']!,
          ),
        ),
        GoRoute(
          path: 'bookings',
          builder: (_, _) => const MyBookingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/doctor',
      builder: (_, _) => const DoctorHomeScreen(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (_, _) => const DoctorProfileEditorScreen(),
        ),
        GoRoute(
          path: 'chambers',
          builder: (_, _) => const ChambersListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (_, _) => const AddChamberScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/admin',
      builder: (_, _) => const AdminHomeScreen(),
      routes: [
        GoRoute(
          path: 'queue/:chamberId',
          builder: (_, state) => QueueScreen(
            chamberId: state.pathParameters['chamberId']!,
          ),
        ),
      ],
    ),
  ],
);
