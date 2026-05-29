import '../auth/current_user.dart';

const _platformOwnerEmails = <String>{
  'doctorschamberhub@gmail.com',
  'ganimtruthfinder@gmail.com',
};

bool isPlatformOwner() {
  final email = currentUserEmail();
  if (email == null) return false;
  return _platformOwnerEmails.contains(email);
}
