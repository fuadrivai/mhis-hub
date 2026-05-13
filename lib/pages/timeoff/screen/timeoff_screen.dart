// ignore_for_file: deprecated_member_use

import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TimeoffScreen extends StatefulWidget {
  const TimeoffScreen({super.key});

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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 720;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: Container(
          padding: const EdgeInsets.only(left: 10),
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(Common.imageLogo),
        ),
        title: "Request Timeoff",
      ),
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.whiteshade,
                Color(0xFFEAF0FF),
                AppColors.white,
              ],
            ),
          ),
          child:
              BlocBuilder<TimeoffBloc, TimeoffState>(builder: (context, state) {
            if (state.isLoading) {
              return const LoadingWidget();
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TimeoffBloc>().add(const OnInit());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: _buildHeroCard(),
                    ),
                  ),
                  if (isTablet)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: size.width > 1100 ? 3 : 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.5,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildTimeoffCard((state.timeoffs ?? [])[index]),
                          childCount: (state.timeoffs ?? []).length,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverList.builder(
                        itemCount: (state.timeoffs ?? []).length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTimeoffCard(
                                (state.timeoffs ?? [])[index]),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          })),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: Common.redGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Timeoff',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a timeoff type to complete your request',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.85),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeoffCard(Timeoff item) {
    return InkWell(
      onTap: () {
        context.pushNamed("create-timeoff", extra: {
          "data": item,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grayshade),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.code ?? '-',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(item.isActive == true),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.name ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final background = isActive
        ? AppColors.primary.withOpacity(0.15)
        : AppColors.danger.withOpacity(0.12);
    final foreground = isActive ? AppColors.primary : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
