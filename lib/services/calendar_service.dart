import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
// extension_google_sign_in_as_googleapis_auth not required; using account.authHeaders
import 'package:http/http.dart' as http;

enum VisitScheduleType {
  quarterly,
  annual,
}

class CalendarService {
  CalendarService._privateConstructor();
  static final CalendarService instance = CalendarService._privateConstructor();

  static const quarterlyMonths = [3, 6, 9, 12];
  static const annualMonth = 12;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      gcal.CalendarApi.calendarEventsScope,
      gcal.CalendarApi.calendarScope,
    ],
  );

  Future<GoogleSignInAccount?> ensureSignedIn() async {
    try {
      final current = _googleSignIn.currentUser;
      if (current != null) return current;
      return await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<gcal.Event>> scheduleVisits({
    required String bankName,
    required String branchName,
    required String machineType,
    required String serialNumber,
    required VisitScheduleType scheduleType,
    required DateTime startDate,
    required int visitDurationHours,
  }) async {
    try {
      final account = await ensureSignedIn();
      if (account == null) return [];

      final headers = await account.authHeaders;
      final client = _AuthClient(headers);
      final calendar = gcal.CalendarApi(client);

      final events = _generateVisitEvents(
        bankName: bankName,
        branchName: branchName,
        machineType: machineType,
        serialNumber: serialNumber,
        scheduleType: scheduleType,
        startDate: startDate,
        visitDurationHours: visitDurationHours,
      );

      final scheduledEvents = <gcal.Event>[];
      for (final event in events) {
        final inserted = await calendar.events.insert(event, 'primary');
        scheduledEvents.add(inserted);
      }

      client.close();
      return scheduledEvents;
    } catch (e) {
      rethrow;
    }
  }

  List<gcal.Event> _generateVisitEvents({
    required String bankName,
    required String branchName,
    required String machineType,
    required String serialNumber,
    required VisitScheduleType scheduleType,
    required DateTime startDate,
    required int visitDurationHours,
  }) {
    final events = <gcal.Event>[];
    final endOfYear = DateTime(startDate.year, 12, 31);
    var currentDate = startDate;

    while (currentDate.isBefore(endOfYear)) {
      if (_shouldScheduleVisit(currentDate, scheduleType)) {
        final event = gcal.Event()
          ..summary = 'Service Visit: $bankName - $branchName'
          ..description = '''
Machine Type: $machineType
Serial Number: $serialNumber
Visit Type: ${scheduleType.name}
'''
          ..start = (gcal.EventDateTime()
            ..date = currentDate
            ..timeZone = 'Asia/Kolkata')
          ..end = (gcal.EventDateTime()
            ..date = currentDate.add(Duration(hours: visitDurationHours))
            ..timeZone = 'Asia/Kolkata')
          ..reminders = (gcal.EventReminders()
            ..useDefault = false
            ..overrides = [
              gcal.EventReminder()
                ..method = 'email'
                ..minutes = 24 * 60, // 1 day before
              gcal.EventReminder()
                ..method = 'popup'
                ..minutes = 60, // 1 hour before
            ]);

        events.add(event);
      }

      // Move to next month
      currentDate = DateTime(
        currentDate.year,
        currentDate.month + 1,
        currentDate.day,
      );
    }

    return events;
  }

  bool _shouldScheduleVisit(DateTime date, VisitScheduleType scheduleType) {
    return switch (scheduleType) {
      VisitScheduleType.quarterly => quarterlyMonths.contains(date.month),
      VisitScheduleType.annual => date.month == annualMonth,
    };
  }

  Future<List<gcal.Event>> getScheduledVisits({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final account = await ensureSignedIn();
      if (account == null) return [];

      final headers = await account.authHeaders;
      final client = _AuthClient(headers);
      final calendar = gcal.CalendarApi(client);

      final events = await calendar.events.list(
        'primary',
        timeMin: startDate?.toUtc(),
        timeMax: endDate?.toUtc(),
        q: 'Service Visit:', // Search for our service visit events
        orderBy: 'startTime',
        singleEvents: true,
      );

      client.close();
      return events.items ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<gcal.Event?> createAllDayEvent({
    required DateTime date,
    required String title,
    required String description,
  }) async {
    try {
      final account = await ensureSignedIn();
      if (account == null) return null;

      final headers = await account.authHeaders;
      final client = _AuthClient(headers);
      final calendar = gcal.CalendarApi(client);

      final start = gcal.EventDateTime()
        ..date = DateTime(date.year, date.month, date.day);
      final end = gcal.EventDateTime()
        ..date = date.add(const Duration(days: 1));

      final event = gcal.Event(
        summary: title,
        description: description,
        start: start,
        end: end,
      );

      final inserted = await calendar.events.insert(event, 'primary');
      client.close();
      return inserted;
    } catch (e) {
      rethrow;
    }
  }

}

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
