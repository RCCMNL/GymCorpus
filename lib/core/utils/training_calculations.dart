class TrainingCalculations {
  /// Calcola il massimale 1RM usando la formula di Brzycki:
  /// 1RM = peso / ( 1.0278 - ( 0.0278 * reps ) )
  static double calculateBrzycki1RM({required double weight, required int reps}) {
    if (reps <= 0) return 0.0;
    if (reps == 1) return weight;
    if (weight < 0) return 0.0;
    
    final denominator = 1.0278 - (0.0278 * reps);
    // Fallback matematico logico per safety divisoria se le rip. sono estreme.
    if (denominator <= 0) return weight; 
    
    return weight / denominator;
  }
}
