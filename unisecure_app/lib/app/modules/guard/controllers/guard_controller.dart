import 'package:get/get.dart';
import '../../../data/models/guard_models.dart';
import '../../../data/repositories/guard_repository.dart';

/// Controller managing Guard desk operational metrics, tab navigation,
/// gate transaction streams, and security audit log filtering.
class GuardController extends GetxController {
  final GuardRepository repository;

  GuardController({GuardRepository? repo})
    : repository = repo ?? GuardRepository();

  // Navigation tab state (0: Gate, 1: Visitors, 2: History, 3: Profile)
  final currentTabIndex = 0.obs;

  // Loading states
  final isLoading = true.obs;
  final isRefreshing = false.obs;

  // Data Observables
  final profile = Rxn<GuardProfile>();
  final deskSummary = Rxn<GateDeskSummary>();
  final recentTransactions = <GateTransaction>[].obs;
  final allTransactions = <GateTransaction>[].obs;

  // Audit History Filters
  final selectedEventFilter = 'All'.obs; // All, Entry, Exit
  final selectedSubjectFilter = 'All'.obs; // All, Student, Visitor
  final historySearchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
    if (index == 2) {
      loadHistory();
    }
  }

  Future<void> loadAll({bool showSpinner = true}) async {
    if (showSpinner) isLoading.value = true;
    try {
      final results = await Future.wait([
        repository.getProfile(),
        repository.getSummary(),
        repository.getRecentTransactions(limit: 8),
        repository.getTransactions(),
      ]);

      profile.value = results[0] as GuardProfile;
      deskSummary.value = results[1] as GateDeskSummary;
      recentTransactions.assignAll(results[2] as List<GateTransaction>);
      allTransactions.assignAll(results[3] as List<GateTransaction>);
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshDesk() async {
    isRefreshing.value = true;
    await loadAll(showSpinner: false);
  }

  Future<void> loadHistory() async {
    final list = await repository.getTransactions(
      eventTypeFilter: selectedEventFilter.value,
      subjectFilter: selectedSubjectFilter.value,
      query: historySearchQuery.value,
    );
    allTransactions.assignAll(list);
  }

  Future<void> filterHistoryEvent(String filter) async {
    selectedEventFilter.value = filter;
    await loadHistory();
  }

  Future<void> filterHistorySubject(String filter) async {
    selectedSubjectFilter.value = filter;
    await loadHistory();
  }

  Future<void> searchHistory(String query) async {
    historySearchQuery.value = query;
    await loadHistory();
  }
}
