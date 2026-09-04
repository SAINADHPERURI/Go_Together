import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/join_request_model.dart';
import '../../../providers/join_request_provider.dart';
import '../widgets/host_request_card.dart';
import '../widgets/user_request_card.dart';

class RequestsManagementScreen extends ConsumerStatefulWidget {
  const RequestsManagementScreen({super.key});

  @override
  ConsumerState<RequestsManagementScreen> createState() => _RequestsManagementScreenState();
}

class _RequestsManagementScreenState extends ConsumerState<RequestsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _processingRequestId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept(JoinRequestModel request) async {
    setState(() => _processingRequestId = request.id);
    try {
      final reqRepo = ref.read(joinRequestRepositoryProvider);
      await reqRepo.acceptJoinRequest(request: request);
      if (mounted) {
        AppDialogs.showSnackBar(
          context,
          message: '${request.userName} accepted into the trip group!',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _processingRequestId = null);
    }
  }

  Future<void> _handleReject(JoinRequestModel request) async {
    final confirm = await AppDialogs.showConfirmDialog(
      context,
      title: 'Decline Request?',
      message: 'Are you sure you want to decline ${request.userName}\'s request?',
      confirmLabel: 'Decline',
      isDestructive: true,
    );

    if (confirm != true) return;

    setState(() => _processingRequestId = request.id);
    try {
      final reqRepo = ref.read(joinRequestRepositoryProvider);
      await reqRepo.rejectJoinRequest(request: request);
      if (mounted) {
        AppDialogs.showSnackBar(context, message: 'Request declined.');
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _processingRequestId = null);
    }
  }

  Future<void> _handleCancel(JoinRequestModel request) async {
    final confirm = await AppDialogs.showConfirmDialog(
      context,
      title: 'Cancel Join Request?',
      message: 'Withdraw your request to join the trip to ${request.tripDestination}?',
      confirmLabel: 'Withdraw Request',
      isDestructive: true,
    );

    if (confirm != true) return;

    try {
      final reqRepo = ref.read(joinRequestRepositoryProvider);
      await reqRepo.cancelJoinRequest(request.id);
      if (mounted) {
        AppDialogs.showSnackBar(context, message: 'Request withdrawn.');
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostRequestsAsync = ref.watch(hostIncomingRequestsStreamProvider);
    final userRequestsAsync = ref.watch(userOutboundRequestsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Requests'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? AppColors.textPrimaryDark : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
          tabs: const [
            Tab(text: 'Received (Host Inbox)'),
            Tab(text: 'Sent Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Received
          hostRequestsAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return AppEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No Received Requests',
                  description: 'When travelers in your community request to join your hosted trips, they will appear here.',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.space16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                    child: HostRequestCard(
                      request: req,
                      isProcessing: _processingRequestId == req.id,
                      onAccept: () => _handleAccept(req),
                      onReject: () => _handleReject(req),
                    ),
                  );
                },
              );
            },
            loading: () => const AppLoading(message: 'Loading requests...'),
            error: (e, _) => AppErrorState(message: e.toString()),
          ),

          // Tab 2: Sent
          userRequestsAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return AppEmptyState(
                  icon: Icons.send_outlined,
                  title: 'No Sent Requests',
                  description: 'You haven\'t requested to join any trips yet. Discover trips in your age group to get started!',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.space16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                    child: UserRequestCard(
                      request: req,
                      onCancel: () => _handleCancel(req),
                    ),
                  );
                },
              );
            },
            loading: () => const AppLoading(message: 'Loading sent requests...'),
            error: (e, _) => AppErrorState(message: e.toString()),
          ),
        ],
      ),
    );
  }
}
