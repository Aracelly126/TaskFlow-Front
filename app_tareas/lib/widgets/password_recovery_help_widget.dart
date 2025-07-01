import 'package:flutter/material.dart';

class PasswordRecoveryHelpWidget extends StatelessWidget {
  const PasswordRecoveryHelpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Instrucciones',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep(
            context,
            '1.',
            'Ingresa tu correo electrónico registrado',
            Icons.email_outlined,
          ),
          const SizedBox(height: 8),
          _buildStep(
            context,
            '2.',
            'Recibirás un enlace de recuperación en tu correo',
            Icons.mark_email_read_outlined,
          ),
          const SizedBox(height: 8),
          _buildStep(
            context,
            '3.',
            'Haz clic en el enlace y establece tu nueva contraseña',
            Icons.key_outlined,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.amber[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child:                  Text(
                    'El enlace expira en 1 hora. Revisa tu carpeta de spam si no lo encuentras.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.amber[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
