import 'package:flutter/material.dart';

class PasswordRecoveryStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;
  
  const PasswordRecoveryStepIndicator({
    super.key,
    required this.currentStep,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(stepTitles.length, (index) {
          final isActive = index <= currentStep;
          final isCompleted = index < currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Círculo del paso
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive ? Colors.white : theme.colorScheme.outline,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Título del paso
                      Text(
                        stepTitles[index],
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isActive 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.outline,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Línea conectora (excepto para el último paso)
                if (index < stepTitles.length - 1)
                  Container(
                    height: 2,
                    width: 20,
                    margin: const EdgeInsets.only(bottom: 24),
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
