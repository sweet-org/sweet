

class CapacitorSimulationResults {
  final Duration ttl;
  final double peakRechargeRate;
  final double loadBalance;
  final double totalCapacitorNeeded;
  final double capacity;
  final double rechargeTimeMs;
  final double rechargeRate;

  double get delta => (peakRechargeRate - totalCapacitorNeeded) * 1000;
  double get deltaPercentage => peakRechargeRate > 0
      ? (peakRechargeRate - totalCapacitorNeeded) / peakRechargeRate
      : 0;
  Duration get rechargeTime => Duration(milliseconds: rechargeTimeMs.toInt());

  CapacitorSimulationResults({
    required this.capacity,
    required this.rechargeTimeMs,
    required this.rechargeRate,
    required this.ttl,
    required this.peakRechargeRate,
    required this.loadBalance,
    required this.totalCapacitorNeeded,
  });

  static CapacitorSimulationResults get zero => CapacitorSimulationResults(
        ttl: Duration.zero,
        peakRechargeRate: 0,
        loadBalance: 0,
        totalCapacitorNeeded: 0,
        capacity: 0,
        rechargeTimeMs: 0,
        rechargeRate: 0,
      );
}
