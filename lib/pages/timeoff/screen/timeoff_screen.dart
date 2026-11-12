import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimeoffScreen extends StatefulWidget {
  const TimeoffScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  State<TimeoffScreen> createState() => _TimeoffScreenState();
}

class _TimeoffScreenState extends State<TimeoffScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TimeoffBloc>().add(const OnInit());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top + 220,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: Common.homeHeaderGradient),
            ),
          ),
          SafeArea(
            bottom: false,
            child: BlocBuilder<TimeoffBloc, TimeoffState>(
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TimeoffBloc>().add(const OnInit());
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                          child: Row(
                            children: [
                              if (widget.showBack) ...[
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                  icon: const Icon(Icons.arrow_back),
                                  color: Colors.white,
                                  tooltip: 'Back',
                                ),
                                const SizedBox(width: 4),
                              ],
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Request Timeoff',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Choose a timeoff type to continue',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.isLoading)
                        const SliverToBoxAdapter(
                          child: Column(
                            children: [
                              LoadingShimmer(height: 100),
                              LoadingShimmer(height: 100),
                              LoadingShimmer(height: 100),
                            ],
                          ),
                        )
                      else ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: _TimeoffIntroCard(),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              'Available Timeoff',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                        ),
                        if (state.isError)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.errorMessage ??
                                        'Unable to load timeoff types. Pull down to retry.',
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                  TextButton(
                                    onPressed: () => context
                                        .read<TimeoffBloc>()
                                        .add(const OnInit()),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if ((state.timeoffs ?? []).isEmpty && !state.isError)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              child: const Text(
                                'No timeoff types available.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          )
                        else if ((state.timeoffs ?? []).isNotEmpty)
                          TimeoffListWidget(timeoffs: state.timeoffs ?? []),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeoffIntroCard extends StatelessWidget {
  const _TimeoffIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              color: AppColors.danger,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan your time off',
                  style: TextStyle(
                    color: AppColors.dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Select a type below to start your request.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
