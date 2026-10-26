import '../models/notification_models.dart';

/// Realistic mock dataset for notifications across all campus roles.
class NotificationMockData {
  NotificationMockData._();

  static List<AppNotification> get initialNotifications {
    final now = DateTime.now();

    return [
      AppNotification(
        id: 'notif-101',
        title: 'Attendance Recorded: Advanced Algorithms',
        body:
            'Your attendance for CS-401 Lecture has been marked Present by Dr. Evelyn Reed.',
        details:
            'Session held in Block B, Lecture Hall 204 from 09:00 to 10:30. Current overall course attendance is 87.5% (28 of 32 sessions attended). Keep your attendance above 75% to remain eligible for end-semester examinations.',
        type: NotificationType.attendance,
        roleScope: 'student',
        createdAt: now.subtract(const Duration(minutes: 18)),
        isRead: false,
        actionLabel: 'View Course Attendance',
        actionRoute: '/student',
        sender: 'Academic Attendance System',
      ),
      AppNotification(
        id: 'notif-102',
        title: 'Campus Perimeter Security Protocol Update',
        body:
            'Gate 2 will be undergoing biometrics sensor maintenance from 14:00 to 16:00 today.',
        details:
            'All foot traffic and vehicle access during this window will be redirected through Main Gate 1 and West Gate 3. Duty officers are advised to expect increased queue volume during peak afternoon transitions.',
        type: NotificationType.security,
        roleScope: 'all',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 25)),
        isRead: false,
        actionLabel: 'Gate Status Overview',
        actionRoute: '/guard',
        sender: 'Campus Safety & Physical Security',
      ),
      AppNotification(
        id: 'notif-103',
        title: 'Session Pending Final Attendance Submission',
        body:
            'CS-401 Sec A (09:00 - 10:30) requires attendance finalization before 18:00.',
        details:
            'You marked 32 students Present, 3 Late, and 3 Absent. Please review unverified records and submit the final roster sign-off to sync with the university academic registrar.',
        type: NotificationType.academic,
        roleScope: 'teacher',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 10)),
        isRead: false,
        actionLabel: 'Open Attendance Roster',
        actionRoute: '/teacher/roster',
        sender: 'Faculty Course Coordinator',
      ),
      AppNotification(
        id: 'notif-104',
        title: 'VIP Guest Arrival Notice • Main Gate 1',
        body:
            'Dr. Jane Foster (Guest Speaker, CSE Symposium) expected at 11:30 AM.',
        details:
            'Security pass VIS-4099 has been pre-authorized. Host contact: Prof. Katherine Vance (Extension 4402). Escort to Dean of Research Office upon parking clearance.',
        type: NotificationType.gate,
        roleScope: 'guard',
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: true,
        actionLabel: 'View Visitor Queue',
        actionRoute: '/guard/visitors',
        sender: 'Campus Security Dispatch',
      ),
      AppNotification(
        id: 'notif-105',
        title: 'Room Change: Database Systems Lab',
        body:
            'Today’s CS-303 practical lab relocated from Lab 102 to Innovation Hub Block C.',
        details:
            'Due to scheduled server maintenance in Block A, all practical sessions for Database Systems will be hosted in Block C, Computing Lab 301. Machine IDs have been cloned with identical development environments.',
        type: NotificationType.academic,
        roleScope: 'student',
        createdAt: now.subtract(const Duration(hours: 5, minutes: 40)),
        isRead: true,
        actionLabel: 'View Timetable',
        actionRoute: '/student',
        sender: 'Department of Information Technology',
      ),
      AppNotification(
        id: 'notif-106',
        title: 'Gate Access Verified: Main Gate 1',
        body:
            'Digital badge BSIT-MC-0001 scanned for campus entry at 08:42 AM.',
        details:
            'Access verified via biometric facial verification scan at Main Gate 1 North Turnstile. Recorded by Officer Tariq Khan (SEC-2022-004).',
        type: NotificationType.gate,
        roleScope: 'student',
        createdAt: now.subtract(const Duration(hours: 6)),
        isRead: true,
        sender: 'Automated Access Control',
      ),
      AppNotification(
        id: 'notif-107',
        title: 'Mid-Semester Grade Rosters Opened',
        body:
            'Faculty grade submission portal is now active for Semester 6 courses.',
        details:
            'All continuous assessment marks and mid-term examination scores must be input and locked before the end of next week. Contact the Examination Cell for moderation inquiries.',
        type: NotificationType.system,
        roleScope: 'teacher',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
        sender: 'Office of the Academic Registrar',
      ),
      AppNotification(
        id: 'notif-108',
        title: 'Campus Weather & Evening Transport Advisory',
        body:
            'High wind advisory in effect. Campus shuttle departures operating every 15 minutes.',
        details:
            'Safety caution: Students and faculty departing after 18:00 are advised to board university shuttles from the North Transit Hub. East Pedestrian walkway will have enhanced perimeter lighting.',
        type: NotificationType.system,
        roleScope: 'all',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        sender: 'Campus Facilities Administration',
      ),
    ];
  }
}
