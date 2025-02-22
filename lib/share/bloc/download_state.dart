part of 'download_bloc.dart';

enum DownloadStatus {
  idle,
  fetching,
  completed,
}

class DownloadState extends Equatable {
  const DownloadState({
    this.status = DownloadStatus.idle,
  });

  final DownloadStatus status;

  DownloadState copyWith({
    DownloadStatus? status,
  }) {
    return DownloadState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}
