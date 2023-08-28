class DataRepository {
  // Singleton instance
  static final DataRepository _instance = DataRepository._internal();

  // Private constructor
  DataRepository._internal();

  // Access the instance using this getter
  static DataRepository get instance => _instance;

  // Map to store characteristic values for each metric
  Map<String, List<String>> _metricValuesMap = {};

  // Method to set characteristic values for a metric
  void setMetricValues(String metric, List<String> values) {
    _metricValuesMap[metric] = values;
  }

  // Method to get characteristic values for a metric
  List<String>? getMetricValues(String metric) {
    return _metricValuesMap[metric];
  }
}
