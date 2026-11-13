import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/models/v2/employee.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/employee/repository/employee_api.dart';
import 'package:fl_mhis_hr/pages/visitor/repository/visitor_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'visitor_event.dart';
part 'visitor_state.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  VisitorBloc({VisitorApi? api, Future<Employee> Function()? getProfile})
      : _api = api ?? VisitorApi(),
        _getProfile = getProfile ??
            (() => EmployeeApi.getEmployeeProfile(handleErrorsLocally: true)),
        super(const VisitorState()) {
    on<LoadVisitorList>(_loadList);
    on<LoadTodayVisitorList>(_loadTodayVisitorList);
    on<LoadVisitorForm>(_loadForm);
    on<LoadVisitorCurrentHost>(_loadCurrentHost);
    on<SubmitVisitorInvitation>(_submit);
    on<SearchVisitorHosts>(_searchHosts);
    on<LoadVisitorHostFilters>(_loadHostFilters);
    on<LoadVisitorDetail>(_loadDetail);
    on<CancelVisitorInvitation>(_cancel);
  }

  final VisitorApi _api;
  final Future<Employee> Function() _getProfile;
  final _listGenerations = <VisitorListType, int>{};
  int _hostGeneration = 0;
  int _hostFilterGeneration = 0;
  final _todayGenerations = <VisitorListType, int>{};
  final _homeTodayGenerations = <VisitorListType, int>{};
  int _formGeneration = 0;
  int _detailGeneration = 0;
  int _currentHostGeneration = 0;

  String _error(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['errors'] is Map) {
        final errors = (data['errors'] as Map)
            .values
            .expand((value) => value is List ? value : [value])
            .map((value) => value.toString())
            .join('\n');
        if (errors.isNotEmpty) return errors;
      }
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      return error.message ?? 'Unable to connect to the server.';
    }
    return 'Unexpected response or error. Please try again.';
  }

  void _emitList(Emitter<VisitorState> emit, VisitorListType type,
      VisitorListState<Visit> list) {
    emit(type == VisitorListType.invitations
        ? state.copyWith(invitations: list)
        : state.copyWith(monitoring: list));
  }

  void _emitToday(Emitter<VisitorState> emit, VisitorListType type,
      VisitorListState<Visit> list,
      {bool homeSummary = false}) {
    if (homeSummary) {
      emit(type == VisitorListType.invitations
          ? state.copyWith(homeTodayInvitations: list)
          : state.copyWith(homeTodayMonitoring: list));
      return;
    }
    emit(type == VisitorListType.invitations
        ? state.copyWith(todayInvitations: list)
        : state.copyWith(todayMonitoring: list));
  }

  Future<void> _loadList(
      LoadVisitorList event, Emitter<VisitorState> emit) async {
    try {
      var list = state.list(event.type);
      if (event.reset) {
        _listGenerations[event.type] = (_listGenerations[event.type] ?? 0) + 1;
        list = VisitorListState<Visit>(
          filters: event.filters ?? list.filters,
        );
      } else if (list.loading || !list.hasMore) {
        return;
      }
      final generation = _listGenerations[event.type] ?? 0;
      _emitList(emit, event.type, list.copyWith(loading: true));
      try {
        final page = await _api.visits(
          event.type.name,
          page: list.page + 1,
          filters: list.filters,
        );
        if (emit.isDone || generation != (_listGenerations[event.type] ?? 0)) {
          return;
        }
        _emitList(
            emit,
            event.type,
            list.copyWith(
              items: [...list.items, ...page.data],
              page: page.page,
              total: page.total,
              hasMore: page.hasMore,
              loading: false,
            ));
      } catch (error) {
        if (emit.isDone || generation != (_listGenerations[event.type] ?? 0)) {
          return;
        }
        _emitList(emit, event.type,
            list.copyWith(loading: false, error: _error(error)));
      }
    } finally {
      event.completion?.complete();
    }
  }

  Future<void> _loadTodayVisitorList(
      LoadTodayVisitorList event, Emitter<VisitorState> emit) async {
    final generations =
        event.homeSummary ? _homeTodayGenerations : _todayGenerations;
    var list = event.homeSummary
        ? event.type == VisitorListType.invitations
            ? state.homeTodayInvitations
            : state.homeTodayMonitoring
        : event.type == VisitorListType.invitations
            ? state.todayInvitations
            : state.todayMonitoring;
    if (event.reset) {
      generations[event.type] = (generations[event.type] ?? 0) + 1;
      list = VisitorListState<Visit>(filters: {
        'visit_date': event.date,
        if (event.query.trim().isNotEmpty) 'query': event.query.trim(),
        if (event.departureAfter != null)
          'departure_after': event.departureAfter,
      });
    } else if (list.loading || !list.hasMore) {
      return;
    }

    final generation = generations[event.type] ?? 0;
    _emitToday(
      emit,
      event.type,
      list.copyWith(loading: true),
      homeSummary: event.homeSummary,
    );
    try {
      final page = await _api.visits(
        event.type.name,
        page: list.page + 1,
        filters: list.filters,
      );
      if (emit.isDone || generation != (generations[event.type] ?? 0)) {
        return;
      }
      _emitToday(
        emit,
        event.type,
        list.copyWith(
          items: [...list.items, ...page.data],
          page: page.page,
          total: page.total,
          hasMore: page.hasMore,
          loading: false,
        ),
        homeSummary: event.homeSummary,
      );
    } catch (error) {
      if (emit.isDone || generation != (generations[event.type] ?? 0)) {
        return;
      }
      _emitToday(
        emit,
        event.type,
        list.copyWith(loading: false, error: _error(error)),
        homeSummary: event.homeSummary,
      );
    }
  }

  Future<void> _loadForm(
      LoadVisitorForm event, Emitter<VisitorState> emit) async {
    final generation = ++_formGeneration;
    emit(state.copyWith(form: const VisitorFormStatus(loading: true)));
    try {
      final options = await _api.formOptions();
      if (emit.isDone || generation != _formGeneration) return;
      emit(state.copyWith(form: VisitorFormStatus(options: options)));
    } catch (error) {
      if (emit.isDone || generation != _formGeneration) return;
      emit(
          state.copyWith(form: VisitorFormStatus(optionsError: _error(error))));
    }
  }

  Future<void> _submit(
      SubmitVisitorInvitation event, Emitter<VisitorState> emit) async {
    if (state.form.submitting) return;
    final generation = _formGeneration;
    final options = state.form.options;
    emit(state.copyWith(
        form: VisitorFormStatus(options: options, submitting: true)));
    try {
      await _api.create(event.fields, event.attachment);
      if (emit.isDone || generation != _formGeneration) return;
      emit(state.copyWith(
          form: VisitorFormStatus(options: options, created: true)));
    } catch (error) {
      if (emit.isDone || generation != _formGeneration) return;
      emit(state.copyWith(
          form: VisitorFormStatus(
              options: options, submissionError: _error(error))));
    }
  }

  Future<void> _loadCurrentHost(
      LoadVisitorCurrentHost event, Emitter<VisitorState> emit) async {
    final generation = ++_currentHostGeneration;
    emit(state.copyWith(
        currentHost: const VisitorCurrentHostStatus(loading: true)));
    try {
      final employee = await _getProfile();
      final name = employee.personal?.fullname?.trim();
      final userName = employee.user?.name?.trim();
      final displayName = name != null && name.isNotEmpty ? name : userName;
      if (employee.id == null || displayName == null || displayName.isEmpty) {
        throw const FormatException('Employee profile has no ID or name.');
      }
      if (emit.isDone || generation != _currentHostGeneration) return;
      emit(state.copyWith(
          currentHost: VisitorCurrentHostStatus(
              host: VisitorOption(id: employee.id!, name: displayName))));
    } catch (error) {
      if (emit.isDone || generation != _currentHostGeneration) return;
      emit(state.copyWith(
          currentHost: VisitorCurrentHostStatus(
              error:
                  error is FormatException ? error.message : _error(error))));
    }
  }

  Future<void> _searchHosts(
      SearchVisitorHosts event, Emitter<VisitorState> emit) async {
    var list = state.hosts;
    if (event.reset) {
      _hostGeneration++;
      list = VisitorListState<VisitorHost>(
        query: event.query ?? list.query,
        filters: event.filters ?? list.filters,
      );
    } else if (list.loading || !list.hasMore) {
      return;
    }
    final generation = _hostGeneration;
    emit(state.copyWith(hosts: list.copyWith(loading: true)));
    try {
      final page = await _api.hosts(
        list.query,
        page: list.page + 1,
        filters: Map<String, int?>.from(list.filters),
      );
      if (emit.isDone || generation != _hostGeneration) return;
      emit(state.copyWith(
          hosts: list.copyWith(
        items: [...list.items, ...page.data],
        page: page.page,
        hasMore: page.hasMore,
        loading: false,
      )));
    } catch (error) {
      if (emit.isDone || generation != _hostGeneration) return;
      emit(state.copyWith(
          hosts: list.copyWith(loading: false, error: _error(error))));
    }
  }

  Future<void> _loadHostFilters(
      LoadVisitorHostFilters event, Emitter<VisitorState> emit) async {
    if (state.hostFilters.loading || state.hostFilters.options != null) return;
    final generation = ++_hostFilterGeneration;
    emit(state.copyWith(
        hostFilters: const VisitorHostFilterStatus(loading: true)));
    try {
      final options = await _api.hostFilters();
      if (emit.isDone || generation != _hostFilterGeneration) return;
      emit(state.copyWith(
          hostFilters: VisitorHostFilterStatus(options: options)));
    } catch (error) {
      if (emit.isDone || generation != _hostFilterGeneration) return;
      emit(state.copyWith(
          hostFilters: VisitorHostFilterStatus(error: _error(error))));
    }
  }

  Future<void> _loadDetail(
      LoadVisitorDetail event, Emitter<VisitorState> emit) async {
    final generation = ++_detailGeneration;
    emit(state.copyWith(detail: const VisitorDetailStatus(loading: true)));
    try {
      final visit = await _api.detail(event.id);
      if (emit.isDone || generation != _detailGeneration) return;
      emit(state.copyWith(detail: VisitorDetailStatus(visit: visit)));
    } catch (error) {
      if (emit.isDone || generation != _detailGeneration) return;
      emit(state.copyWith(detail: VisitorDetailStatus(error: _error(error))));
    }
  }

  Future<void> _cancel(
      CancelVisitorInvitation event, Emitter<VisitorState> emit) async {
    if (state.detail.cancelling) return;
    final generation = _detailGeneration;
    final visit = state.detail.visit;
    emit(state.copyWith(
        detail: VisitorDetailStatus(visit: visit, cancelling: true)));
    try {
      await _api.cancel(event.id, event.reason);
      if (emit.isDone || generation != _detailGeneration) return;
      emit(state.copyWith(
          detail: VisitorDetailStatus(visit: visit, cancelled: true)));
    } catch (error) {
      if (emit.isDone || generation != _detailGeneration) return;
      emit(state.copyWith(
          detail:
              VisitorDetailStatus(visit: visit, cancelError: _error(error))));
    }
  }
}
