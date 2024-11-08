import 'dart:async';
import 'dart:developer' as dev;

import 'package:pizza_calc/services/yeast_db.dart';

Future<double> calculateFermentationPercentage(
    List<Map<String, dynamic>> lookupTable,
    double temp,
    double hours,
    double yeast) async {
  final proofingTable = ProofingTimeTable(lookupTable);
  double totalTime = proofingTable.getProofingTime(yeast, temp);
  dev.log("Total fermentation time for $yeast at $temp: $totalTime");
  return (hours / totalTime) * 100;
}

Future<double> adjustYeast(
  List<List<double>> fermentationSteps,
  List<Map<String, dynamic>> lookupTable, // Preloaded lookup table
  {
    double initialYeast = 0.3,
    double tolerance = 0.5,
  }
) async {
  double yeast = initialYeast;
  double bestYeast = initialYeast;            // To track the best yeast value found
  double bestPercentage = double.infinity;    // To track the best total percentage found
  final Set<double> previousYeastValues = {}; // To store previous yeast values
  int iteration = 0;                          // To count iterations for debugging

  while (yeast > 0) {
    double totalPercentage = 0.0;

    for (var step in fermentationSteps) {
      double hours = step[0];
      double temp = step[1];

      double percentage = await calculateFermentationPercentage(lookupTable, temp, hours, yeast);
      totalPercentage += percentage;

      // Debug information for each step
      dev.log("Step: $step, Yeast: $yeast, Percentage: $percentage");
    }

    // Debug information for the total percentage
    dev.log("Iteration: $iteration, Total Percentage: $totalPercentage");

    // Check if this is the best percentage found so far
    if ((totalPercentage - 100).abs() < bestPercentage) {
      bestPercentage = totalPercentage;
      bestYeast = yeast;
    }

    if ((totalPercentage - 100).abs() < tolerance) {
      dev.log("Desired percentage achieved within tolerance: ${(totalPercentage - 100).abs()}");
      return yeast; // Break if we are within the tolerance
    }

    // Check for oscillation in yeast values (with small tolerance for floating point comparison)
    bool oscillationDetected = previousYeastValues.any(
      (previousYeast) => (previousYeast - yeast).abs() < 0.0001
    );
    
    if (oscillationDetected) {
      dev.log("Oscillation detected in yeast values, best total percentage $bestPercentage, returning best yeast value: $bestYeast");
      return bestYeast; // Return the best yeast value found
    } else {
      // Store the current yeast value
      previousYeastValues.add(yeast);
    }

    // Adjust yeast based on the total percentage
    if (totalPercentage < 100) {
      yeast += 0.02; // Increase yeast
    } else {
      yeast -= 0.02; // Decrease yeast
    }
    iteration++; // Increment the iteration count
    if (iteration > 30) break; // Stop if the iteration count exceeds custom threshold
  }
  
  if (iteration > 30) {
    dev.log("Reached maximum iterations. Best yeast value: $bestYeast");
  } else {
    dev.log("Yeast value reached zero. Best yeast value: $bestYeast");
  }
  return bestYeast; // Return the best yeast value after maximum iterations
}

double prefermentYeastCalc(double hours) {
  // Define the known points
  final List<List<double>> points = [
    [3.0, 0.015],   // 3 hours -> 1.5%
    [8.0, 0.007],   // 8 hours -> 0.7%
    [13.0, 0.003],  // 13 hours -> 0.3%
  ];
  
  // If hours is before first point or after last point, clamp to nearest value
  if (hours <= points.first[0]) return points.first[1];
  if (hours >= points.last[0]) return points.last[1];
  
  // Find the two points to interpolate between
  for (int i = 0; i < points.length - 1; i++) {
    if (hours >= points[i][0] && hours <= points[i + 1][0]) {
      double x1 = points[i][0];
      double y1 = points[i][1];
      double x2 = points[i + 1][0];
      double y2 = points[i + 1][1];
      
      // Linear interpolation formula: y = y1 + (x - x1) * (y2 - y1) / (x2 - x1)
      return y1 + (hours - x1) * (y2 - y1) / (x2 - x1);
    }
  }
  
  // Should never reach here due to earlier bounds checking
  return 0.0;
}

Future<double> yeastCalc(
  List<List<double>> fermentationSteps,
  List<Map<String, dynamic>> lookupTable, // Pass the preloaded lookup table
  {
    double initialYeast = 0.3,
    double tolerance = 0.5,
  }
) async {
  double yeastAmount = await adjustYeast(
    fermentationSteps,
    lookupTable,
    initialYeast: initialYeast,
    tolerance: tolerance,
  );
  return yeastAmount;
}

