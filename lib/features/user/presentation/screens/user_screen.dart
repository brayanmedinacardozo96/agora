import 'package:flutter/material.dart';

class GestionUsuariosApp extends StatelessWidget {
  const GestionUsuariosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestionUsuariosScreen();
  }
}

// ---------------------------------------------------------------------------
// Modelos de datos (datos de ejemplo — reemplaza por tus datos reales)
// ---------------------------------------------------------------------------

enum RolUsuario { administrador, coordinador }

extension RolUsuarioX on RolUsuario {
  String get etiqueta {
    switch (this) {
      case RolUsuario.administrador:
        return 'Administrador';
      case RolUsuario.coordinador:
        return 'Coordinador';
    }
  }

  String get descripcion {
    switch (this) {
      case RolUsuario.administrador:
        return 'Acceso total: configuración, usuarios y resultados';
      case RolUsuario.coordinador:
        return 'Gestiona votaciones y consulta resultados asignados';
    }
  }

  IconData get icono {
    switch (this) {
      case RolUsuario.administrador:
        return Icons.admin_panel_settings_outlined;
      case RolUsuario.coordinador:
        return Icons.supervisor_account_outlined;
    }
  }
}

enum EstadoUsuario { pendiente, activo, inactivo }

extension EstadoUsuarioX on EstadoUsuario {
  String get etiqueta {
    switch (this) {
      case EstadoUsuario.pendiente:
        return 'Pendiente';
      case EstadoUsuario.activo:
        return 'Activo';
      case EstadoUsuario.inactivo:
        return 'Inactivo';
    }
  }

  Color get color {
    switch (this) {
      case EstadoUsuario.pendiente:
        return const Color(0xFFF59E0B);
      case EstadoUsuario.activo:
        return const Color(0xFF22C55E);
      case EstadoUsuario.inactivo:
        return const Color(0xFF64748B);
    }
  }
}

class UsuarioRegistrado {
  final String id;
  final String nombre;
  final String usuario;
  final String correo;
  final String telefono;
  EstadoUsuario estado;
  RolUsuario? rol;

  UsuarioRegistrado({
    required this.id,
    required this.nombre,
    required this.usuario,
    required this.correo,
    required this.telefono,
    this.estado = EstadoUsuario.pendiente,
    this.rol,
  });

  String get iniciales {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes[0].substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }
}

final List<UsuarioRegistrado> _usuariosEjemplo = [
  UsuarioRegistrado(
    id: '1',
    nombre: 'Diana Cárdenas',
    usuario: 'dcardenas',
    correo: 'diana.cardenas@ejemplo.com',
    telefono: '3201234567',
  ),
  UsuarioRegistrado(
    id: '2',
    nombre: 'Jorge Castro',
    usuario: 'jcastro',
    correo: 'jorge.castro@ejemplo.com',
    telefono: '3109876543',
  ),
  UsuarioRegistrado(
    id: '3',
    nombre: 'Ana Torres',
    usuario: 'atorres',
    correo: 'ana.torres@ejemplo.com',
    telefono: '3157654321',
    estado: EstadoUsuario.activo,
    rol: RolUsuario.administrador,
  ),
  UsuarioRegistrado(
    id: '4',
    nombre: 'Luis Pérez',
    usuario: 'lperez',
    correo: 'luis.perez@ejemplo.com',
    telefono: '3001112233',
    estado: EstadoUsuario.activo,
    rol: RolUsuario.coordinador,
  ),
  UsuarioRegistrado(
    id: '5',
    nombre: 'Marta Gómez',
    usuario: 'mgomez',
    correo: 'marta.gomez@ejemplo.com',
    telefono: '3123334455',
    estado: EstadoUsuario.inactivo,
    rol: RolUsuario.coordinador,
  ),
];

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  final List<UsuarioRegistrado> _usuarios = _usuariosEjemplo;
  final TextEditingController _busquedaCtrl = TextEditingController();

  EstadoUsuario? _filtroEstado; // null = todos

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  List<UsuarioRegistrado> get _usuariosFiltrados {
    final query = _busquedaCtrl.text.trim().toLowerCase();
    return _usuarios.where((u) {
      final coincideEstado = _filtroEstado == null || u.estado == _filtroEstado;
      final coincideBusqueda =
          query.isEmpty ||
          u.nombre.toLowerCase().contains(query) ||
          u.usuario.toLowerCase().contains(query) ||
          u.correo.toLowerCase().contains(query);
      return coincideEstado && coincideBusqueda;
    }).toList();
  }

  int _contar(EstadoUsuario estado) =>
      _usuarios.where((u) => u.estado == estado).length;

  // ---------- Acciones ----------

  Future<void> _abrirAsignacionRol(UsuarioRegistrado usuario) async {
    RolUsuario? rolTemporal = usuario.rol;

    final resultado = await showModalBottomSheet<RolUsuario>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue[400]!.withValues(alpha: 0.2),
                    child: Text(
                      usuario.iniciales,
                      style: TextStyle(
                        color: Colors.blue[200],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '@${usuario.usuario}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Asignar rol',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ...RolUsuario.values.map((rol) {
                final selected = rolTemporal == rol;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => setModalState(() => rolTemporal = rol),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.blue[400]!.withValues(alpha: 0.12)
                            : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Colors.blue[400]!
                              : const Color(0xFF334155),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            rol.icono,
                            color: selected ? Colors.blue[200] : Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rol.etiqueta,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 14,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  rol.descripcion,
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? Colors.blue[400]
                                  : Colors.transparent,
                              border: Border.all(
                                color: selected
                                    ? Colors.blue[400]!
                                    : Colors.white38,
                                width: 2,
                              ),
                            ),
                            child: selected
                                ? const Icon(
                                    Icons.check,
                                    size: 11,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    disabledBackgroundColor: const Color(0xFF334155),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: rolTemporal == null
                      ? null
                      : () => Navigator.pop(context, rolTemporal),
                  child: Text(
                    usuario.estado == EstadoUsuario.pendiente
                        ? 'Activar usuario'
                        : 'Guardar cambios',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (resultado == null || !mounted) return;

    setState(() {
      usuario.rol = resultado;
      usuario.estado = EstadoUsuario.activo;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${usuario.nombre} activado como ${resultado.etiqueta}'),
      ),
    );
  }

  Future<void> _desactivarUsuario(UsuarioRegistrado usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Desactivar usuario',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que deseas desactivar a ${usuario.nombre}? Perderá acceso a la plataforma.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red[400]),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    setState(() => usuario.estado = EstadoUsuario.inactivo);
  }

  void _reactivarUsuario(UsuarioRegistrado usuario) {
    setState(() => usuario.estado = EstadoUsuario.activo);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${usuario.nombre} reactivado')));
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    final usuarios = _usuariosFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildBuscador(),
            _buildFiltros(),
            Expanded(
              child: usuarios.isEmpty
                  ? _buildEstadoVacio()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: usuarios.length,
                      itemBuilder: (context, i) =>
                          _buildUsuarioCard(usuarios[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _busquedaCtrl,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, usuario o correo',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13.5),
          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
          suffixIcon: _busquedaCtrl.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white38,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _busquedaCtrl.clear()),
                ),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    final chips = <(String, EstadoUsuario?)>[
      ('Todos (${_usuarios.length})', null),
      (
        'Pendientes (${_contar(EstadoUsuario.pendiente)})',
        EstadoUsuario.pendiente,
      ),
      ('Activos (${_contar(EstadoUsuario.activo)})', EstadoUsuario.activo),
      (
        'Inactivos (${_contar(EstadoUsuario.inactivo)})',
        EstadoUsuario.inactivo,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final (etiqueta, estado) = chips[i];
            final selected = _filtroEstado == estado;
            return ChoiceChip(
              label: Text(etiqueta),
              selected: selected,
              onSelected: (_) => setState(() => _filtroEstado = estado),
              backgroundColor: const Color(0xFF1E293B),
              selectedColor: Colors.blue[400]!.withValues(alpha: 0.25),
              labelStyle: TextStyle(
                color: selected ? Colors.blue[100] : Colors.white70,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12.5,
              ),
              side: BorderSide(
                color: selected ? Colors.blue[400]! : const Color(0xFF334155),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, color: Colors.white24, size: 42),
          const SizedBox(height: 10),
          const Text(
            'No se encontraron usuarios',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuarioCard(UsuarioRegistrado usuario) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: usuario.estado.color.withValues(alpha: 0.18),
                child: Text(
                  usuario.iniciales,
                  style: TextStyle(
                    color: usuario.estado.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            usuario.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: usuario.estado.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            usuario.estado.etiqueta,
                            style: TextStyle(
                              color: usuario.estado.color,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${usuario.usuario}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      usuario.correo,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      usuario.telefono,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (usuario.estado == EstadoUsuario.pendiente)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _abrirAsignacionRol(usuario),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Activar y asignar rol'),
              ),
            )
          else if (usuario.estado == EstadoUsuario.activo)
            Row(
              children: [
                Icon(
                  usuario.rol?.icono ?? Icons.badge_outlined,
                  size: 16,
                  color: Colors.white54,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    usuario.rol?.etiqueta ?? 'Sin rol asignado',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () => _abrirAsignacionRol(usuario),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[300],
                  ),
                  child: const Text('Cambiar rol'),
                ),
                IconButton(
                  onPressed: () => _desactivarUsuario(usuario),
                  icon: Icon(
                    Icons.block_outlined,
                    color: Colors.red[300],
                    size: 20,
                  ),
                  tooltip: 'Desactivar usuario',
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  usuario.rol?.icono ?? Icons.badge_outlined,
                  size: 16,
                  color: Colors.white24,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    usuario.rol != null
                        ? '${usuario.rol!.etiqueta} · Inactivo'
                        : 'Inactivo',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _reactivarUsuario(usuario),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[400],
                    side: BorderSide(
                      color: Colors.green[400]!.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reactivar'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
