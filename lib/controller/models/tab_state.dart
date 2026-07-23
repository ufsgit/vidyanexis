enum TabStatus { initial, loading, loaded, empty, error }

class TabState<T> {
  TabStatus status;
  T? data;
  String? errorMessage;

  TabState({
    this.status = TabStatus.initial,
    this.data,
    this.errorMessage,
  });

  void setInitial() {
    status = TabStatus.initial;
    data = null;
    errorMessage = null;
  }

  void setLoading() {
    status = TabStatus.loading;
  }

  void setLoaded(T data) {
    status = TabStatus.loaded;
    this.data = data;
    errorMessage = null;
  }

  void setEmpty() {
    status = TabStatus.empty;
    data = null;
    errorMessage = null;
  }

  void setError(String message) {
    status = TabStatus.error;
    errorMessage = message;
  }
}
