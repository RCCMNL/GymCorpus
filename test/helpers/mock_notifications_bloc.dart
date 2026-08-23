import 'package:bloc_test/bloc_test.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:gym_corpus/features/notifications/presentation/bloc/notifications_state.dart';

/// Mock riutilizzabile di NotificationsBloc: GymHeader (usato come appBar in
/// molte schermate) legge internamente
/// `BlocBuilder<NotificationsBloc, NotificationsState>`, quindi qualsiasi
/// widget che lo include richiede questo provider nell'albero, anche se il
/// widget sotto test non ha nulla a che fare con le notifiche.
class MockNotificationsBloc
    extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}
