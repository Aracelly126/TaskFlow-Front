import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../widgets/password_recovery_step_indicator.dart';
import 'reset_password_screen.dart';
import 'login_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final int userId;

  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.userId,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  bool _resendingCode = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _isCodeComplete => _code.length == 6;

  Future<void> _verificarCodigo() async {
    if (!_isCodeComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el código completo')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final resultado = await validarCodigoVerificacion(_code, widget.userId);
      
      if (resultado != null && resultado['success'] == true) {
        if (resultado['valid'] == true) {
          // Código válido, ir a la pantalla de nueva contraseña
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(
                email: widget.email,
                userId: widget.userId,
                verificationCode: _code,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['message'] ?? 'Código inválido'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado?['message'] ?? 'Error al verificar el código'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _reenviarCodigo() async {
    setState(() => _resendingCode = true);

    try {
      final resultado = await solicitarRecuperacionPassword(widget.email);
      
      if (resultado != null && resultado['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha reenviado un nuevo código a tu correo electrónico'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Limpiar campos
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado?['message'] ?? 'Error al reenviar el código'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _resendingCode = false);
    }
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Mover al siguiente campo si no es el último
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Si es el último campo y está completo, verificar automáticamente
        _focusNodes[index].unfocus();
        if (_isCodeComplete) {
          _verificarCodigo();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [theme.colorScheme.primary.withOpacity(0.4), theme.colorScheme.surface]
                : [theme.colorScheme.primary.withOpacity(0.2), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const PasswordRecoveryStepIndicator(
                  currentStep: 1,
                  stepTitles: ['Solicitar código', 'Verificar código', 'Nueva contraseña'],
                ),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mark_email_read, size: 64, color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Verificar Código',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hemos enviado un código de 6 dígitos a:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        // Campos para el código de verificación
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 45,
                              height: 55,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onChanged: (value) => _onCodeChanged(value, index),
                                onTap: () {
                                  // Seleccionar todo el texto al hacer tap
                                  _controllers[index].selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: _controllers[index].text.length,
                                  );
                                },
                                onSubmitted: (_) {
                                  if (_isCodeComplete) {
                                    _verificarCodigo();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Botón de verificar
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            onPressed: (_loading || !_isCodeComplete) ? null : _verificarCodigo,
                            child: _loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Verificar Código'),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Botón para reenviar código
                        TextButton(
                          onPressed: _resendingCode ? null : _reenviarCodigo,
                          child: _resendingCode
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Reenviando...'),
                                  ],
                                )
                              : const Text('¿No recibiste el código? Reenviar'),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Botón para volver
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Volver al inicio de sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
