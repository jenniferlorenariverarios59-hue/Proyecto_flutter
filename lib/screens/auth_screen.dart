import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Pantalla de Autenticación Real (Inicio de Sesión y Registro de Usuarios)
/// con validaciones completas de formularios y almacenamiento persistente
/// sincronizado con la API REST y SharedPreferences.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  bool _isLoginMode = true;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  // Controladores del formulario
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(text: 'admin@glamstudio.com');
  final _passCtrl = TextEditingController(text: 'admin123');
  final _confirmPassCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Bogotá');
  String _selectedSkinType = 'Mixta';

  static const List<String> _skinTypes = [
    'Mixta',
    'Seca',
    'Grasa',
    'Sensible',
    'Normal',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _fillDemoCredentials({required bool isAdmin}) {
    setState(() {
      _isLoginMode = true;
      if (isAdmin) {
        _emailCtrl.text = 'admin@glamstudio.com';
        _passCtrl.text = 'admin123';
      } else {
        _emailCtrl.text = 'camila@correo.com';
        _passCtrl.text = 'glam2026';
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    late final AuthResult result;
    if (_isLoginMode) {
      result = await _auth.login(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
    } else {
      result = await _auth.register(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
        phone: _phoneCtrl.text,
        city: _cityCtrl.text,
        skinType: _selectedSkinType,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            result.success ? AppTheme.secondary : AppTheme.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(
              result.success
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                result.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 1040 : 490),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildEditorialBrandPanel(context),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          flex: 5,
                          child: _buildFormCard(context),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildMobileHeader(context),
                        const SizedBox(height: 18),
                        _buildFormCard(context),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Panel editorial izquierdo para pantallas de computador / navegador Web
  Widget _buildEditorialBrandPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4E1624),
            Color(0xFF6B2737),
            Color(0xFF9C475B),
          ],
        ),
        boxShadow: AppTheme.luxuryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: AppTheme.softGold.withValues(alpha: 0.5),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: AppTheme.softGold, size: 16),
                SizedBox(width: 6),
                Text(
                  'BOUTIQUE DE ALTA COSMÉTICA',
                  style: TextStyle(
                    color: AppTheme.softGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Glam Studio\nBeauty & Makeup',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 14),
          Text(
            'Descubre nuestra colección curada de labiales de terciopelo, bases sérum luminosas, paletas de sombras, máscaras de pestañas, cuidado facial y accesorios profesionales.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          _buildFeatureBullet(
            Icons.verified_outlined,
            '6 Categorías Especializadas',
            'Labiales, Bases y correctores, Sombras, Pestañas, Skincare y Accesorios.',
          ),
          const SizedBox(height: 14),
          _buildFeatureBullet(
            Icons.storage_rounded,
            'Almacenamiento Persistente + API REST',
            'Usuarios, inventario y carrito sincronizados en Android y Web.',
          ),
          const SizedBox(height: 14),
          _buildFeatureBullet(
            Icons.shopping_bag_outlined,
            'Experiencia de Compra Real',
            'Selección de tonos cosméticos, control de stock y panel de administración.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.softGold, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Encabezado compacto para dispositivos móviles
  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryContainer],
            ),
            shape: BoxShape.circle,
            boxShadow: AppTheme.luxuryShadow,
          ),
          child: const Icon(
            Icons.spa_rounded,
            color: AppTheme.softGold,
            size: 34,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Glam Studio',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryContainer,
                fontSize: 28,
              ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tienda Virtual de Maquillaje & Productos de Belleza',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.onSurfaceVariant,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Tarjeta del formulario de Inicio de Sesión / Registro con validación
  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: AppTheme.luxuryShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de pestaña Iniciar Sesión vs Crear Cuenta
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLoginMode = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: _isLoginMode
                              ? AppTheme.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          'Iniciar Sesión',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: _isLoginMode
                                ? Colors.white
                                : AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLoginMode = false;
                          _emailCtrl.clear();
                          _passCtrl.clear();
                          _confirmPassCtrl.clear();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: !_isLoginMode
                              ? AppTheme.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          'Crear Cuenta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: !_isLoginMode
                                ? Colors.white
                                : AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              _isLoginMode
                  ? 'Bienvenida a tu Boutique'
                  : 'Registro de Nueva Usuaria',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 21,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _isLoginMode
                  ? 'Ingresa tus credenciales para acceder al catálogo, carrito y administración.'
                  : 'Completa el formulario para crear tu cuenta persistente en Glam Studio.',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),

            // Campos exclusivos de Registro
            if (!_isLoginMode) ...[
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo *',
                  hintText: 'Ej. Valentina Gómez',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Por favor ingresa tu nombre completo.';
                  }
                  if (val.trim().length < 3) {
                    return 'El nombre debe tener mínimo 3 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
            ],

            // Correo electrónico
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico *',
                hintText: 'usuario@correo.com',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'El correo electrónico es obligatorio.';
                }
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(val.trim())) {
                  return 'Ingresa un formato de correo válido (ej. ana@correo.com).';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Contraseña
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: 'Contraseña *',
                hintText: 'Mínimo 6 caracteres',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  icon: Icon(
                    _obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Ingresa tu contraseña.';
                }
                if (val.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres.';
                }
                return null;
              },
            ),

            if (!_isLoginMode) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña *',
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Confirma tu contraseña.';
                  }
                  if (val != _passCtrl.text) {
                    return 'Las contraseñas no coinciden.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 380;
                  final phoneField = TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono / Celular *',
                      hintText: '300 123 4567',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length < 7) {
                        return 'Teléfono válido requerido.';
                      }
                      return null;
                    },
                  );
                  final cityField = TextFormField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad *',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Ingresa tu ciudad.';
                      }
                      return null;
                    },
                  );
                  if (isCompact) {
                    return Column(
                      children: [
                        phoneField,
                        const SizedBox(height: 14),
                        cityField,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: phoneField),
                      const SizedBox(width: 10),
                      Expanded(child: cityField),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'Tu Tipo de Piel (para recomendaciones de belleza):',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _skinTypes.map((skin) {
                  final selected = _selectedSkinType == skin;
                  return ChoiceChip(
                    label: Text(skin),
                    selected: selected,
                    selectedColor: AppTheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _selectedSkinType = skin),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 22),

            // Botón Principal de Envío
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _isLoginMode
                            ? Icons.login_rounded
                            : Icons.person_add_alt_1_rounded,
                      ),
                label: Text(
                  _isSubmitting
                      ? 'Validando...'
                      : (_isLoginMode
                          ? 'Ingresar a Glam Studio'
                          : 'Registrarme y Entrar'),
                ),
              ),
            ),

            // Accesos rápidos para demostración en exposición SENA
            if (_isLoginMode) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 15,
                          color: AppTheme.primaryContainer,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Cuentas precargadas para demostración:',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          avatar: const Icon(
                            Icons.admin_panel_settings_outlined,
                            size: 16,
                            color: AppTheme.primaryContainer,
                          ),
                          label: const Text(
                            'Admin (admin@glamstudio.com)',
                            style: TextStyle(fontSize: 11.5),
                          ),
                          onPressed: () =>
                              _fillDemoCredentials(isAdmin: true),
                        ),
                        ActionChip(
                          avatar: const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppTheme.primaryContainer,
                          ),
                          label: const Text(
                            'Cliente (camila@correo.com)',
                            style: TextStyle(fontSize: 11.5),
                          ),
                          onPressed: () =>
                              _fillDemoCredentials(isAdmin: false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
