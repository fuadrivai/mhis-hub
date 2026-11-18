import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_employee_card.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisitorMonitorSearchScreen extends StatefulWidget {
  const VisitorMonitorSearchScreen(
      {super.key, this.initialSelection = const []});

  final List<VisitorHost> initialSelection;

  @override
  State<VisitorMonitorSearchScreen> createState() =>
      _VisitorMonitorSearchScreenState();
}

class _VisitorMonitorSearchScreenState
    extends State<VisitorMonitorSearchScreen> {
  final _search = TextEditingController();
  late final Map<int, VisitorHost> _selected = {
    for (final employee in widget.initialSelection) employee.id: employee,
  };

  @override
  void initState() {
    super.initState();
    context
        .read<VisitorBloc>()
        .add(const SearchVisitorHosts(query: '', reset: true));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _searchEmployees() {
    context.read<VisitorBloc>().add(
          SearchVisitorHosts(query: _search.text.trim(), reset: true),
        );
  }

  void _loadMore() {
    context.read<VisitorBloc>().add(const SearchVisitorHosts());
  }

  void _toggle(VisitorHost employee) {
    setState(() {
      if (_selected.containsKey(employee.id)) {
        _selected.remove(employee.id);
      } else if (_selected.length < 50) {
        _selected[employee.id] = employee;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select up to 50 employees.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: 'Select monitors',
      subtitle: '${_selected.length} of 50 selected',
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: TextField(
              controller: _search,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchEmployees(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Employee name',
                suffixIcon: IconButton(
                  tooltip: 'Search employees',
                  onPressed: _searchEmployees,
                  icon: const Icon(Icons.search),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<VisitorBloc, VisitorState>(
              builder: (context, state) {
                final employees = state.hosts;
                if (employees.loading && employees.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (employees.error != null && employees.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Unable to load employees: ${employees.error}'),
                        TextButton(
                          onPressed: _searchEmployees,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (employees.items.isEmpty) {
                  return const Center(child: Text('No employees found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount:
                      employees.items.length + (employees.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == employees.items.length) {
                      return Center(
                        child: TextButton(
                          onPressed: employees.loading ? null : _loadMore,
                          child: Text(employees.loading
                              ? 'Loading...'
                              : 'Load more employees'),
                        ),
                      );
                    }
                    final employee = employees.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: VisitorEmployeeCard(
                        key: ValueKey('monitor-employee-${employee.id}'),
                        employee: employee,
                        selectionMode: true,
                        selected: _selected.containsKey(employee.id),
                        onTap: () => _toggle(employee),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(_selected.values.toList()),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: Text('Done (${_selected.length})'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
