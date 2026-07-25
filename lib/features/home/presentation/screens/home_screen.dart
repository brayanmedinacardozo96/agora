import 'package:flutter/material.dart';

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: HomeScreen());
  }

  /*
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inicio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
  */
}

// ---------------------------------------------------------------------------
// Modelos usados solo por la UI
// ---------------------------------------------------------------------------

enum TipoUsuario { votante, coordinador, administrador }

extension TipoUsuarioX on TipoUsuario {
  String get etiqueta {
    switch (this) {
      case TipoUsuario.votante:
        return 'Votante';
      case TipoUsuario.coordinador:
        return 'Coordinador';
      case TipoUsuario.administrador:
        return 'Administrador';
    }
  }
}

class AccesoRapido {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const AccesoRapido({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });
}

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Datos de ejemplo — en tu app real vendrían de la sesión autenticada.
  final String _nombreUsuario = 'Camilo Perdomo';
  TipoUsuario _tipoUsuario = TipoUsuario.administrador;
  bool _yaVoto = false;

  final String _tituloVotacion = 'Elecciones Regionales 2026 - Huila';
  final DateTime _cierreVotacion = DateTime.now().add(
    const Duration(hours: 5, minutes: 40),
  );

  String get _iniciales {
    final partes = _nombreUsuario.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes[0].substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }

  void _navegarA(String pantalla) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Abrir: $pantalla')));
    switch (pantalla) {
      case 'Votar':
        Navigator.pushNamed(context, '/voting');
        break;
      case 'Dashboard de resultados':
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 'Mapa de resultados':
        Navigator.pushNamed(context, '/map');
        break;
      case 'Exportar resultados':
        Navigator.pushNamed(context, '/export');
        break;
      case 'Configurar votación':
        Navigator.pushNamed(context, '/ballot');
        break;
      case 'Gestión de usuarios':
        Navigator.pushNamed(context, '/user');
        break;
      default:
    }
    // Reemplaza esto por tu navegación real, por ejemplo:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const VotarScreen()));
  }

  List<AccesoRapido> get _accesos {
    final comunes = [
      AccesoRapido(
        titulo: 'Emitir mi voto',
        subtitulo: _yaVoto ? 'Ya registraste tu voto' : 'Aún no has votado',
        icono: Icons.how_to_vote_outlined,
        color: Colors.blue[400]!,
        onTap: () => _navegarA('Votar'),
      ),
      AccesoRapido(
        titulo: 'Resultados en vivo',
        subtitulo: 'Dashboard con el conteo actual',
        icono: Icons.leaderboard_outlined,
        color: Colors.orange[400]!,
        onTap: () => _navegarA('Dashboard de resultados'),
      ),
      AccesoRapido(
        titulo: 'Mapa de resultados',
        subtitulo: 'Resultados por municipio',
        icono: Icons.map_outlined,
        color: Colors.green[400]!,
        onTap: () => _navegarA('Mapa de resultados'),
      ),
    ];

    final coordinacion = [
      AccesoRapido(
        titulo: 'Exportar resultados',
        subtitulo: 'Descarga en PDF o Excel',
        icono: Icons.ios_share_outlined,
        color: Colors.purple[300]!,
        onTap: () => _navegarA('Exportar resultados'),
      ),
    ];

    final administracion = [
      AccesoRapido(
        titulo: 'Configurar votación',
        subtitulo: 'Tarjetones, fechas y opciones',
        icono: Icons.tune_outlined,
        color: Colors.cyan[300]!,
        onTap: () => _navegarA('Configurar votación'),
      ),
      AccesoRapido(
        titulo: 'Gestión de usuarios',
        subtitulo: 'Activar cuentas y asignar roles',
        icono: Icons.manage_accounts_outlined,
        color: Colors.pink[300]!,
        onTap: () => _navegarA('Gestión de usuarios'),
      ),
    ];

    switch (_tipoUsuario) {
      case TipoUsuario.votante:
        return comunes;
      case TipoUsuario.coordinador:
        return [...comunes, ...coordinacion];
      case TipoUsuario.administrador:
        return [...comunes, ...coordinacion, ...administracion];
    }
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSelectorVistaDemo(),
              const SizedBox(height: 10),
              _buildEncabezado(),
              const SizedBox(height: 20),
              _buildEstadoVotacionCard(),
              const SizedBox(height: 24),
              const Text(
                'Accesos rápidos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildGridAccesos(),
              const SizedBox(height: 24),
              _buildCerrarSesion(),
            ],
          ),
        ),
      ),
    );
  }

  /// Selector solo para previsualizar cómo se ve el Home según el rol.
  /// En tu app real, `_tipoUsuario` vendría de la sesión y este widget no
  /// sería necesario — puedes eliminarlo.
  Widget _buildSelectorVistaDemo() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<TipoUsuario>(
            value: _tipoUsuario,
            dropdownColor: const Color(0xFF1E293B),
            icon: const Icon(
              Icons.expand_more,
              color: Colors.white38,
              size: 16,
            ),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            items: TipoUsuario.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text('Vista: ${t.etiqueta}'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _tipoUsuario = value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.blue[400]!.withValues(alpha: 0.2),
          child: Text(
            _iniciales,
            style: TextStyle(
              color: Colors.blue[200],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${_nombreUsuario.split(' ').first} 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[400]!.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _tipoUsuario.etiqueta,
                  style: TextStyle(
                    color: Colors.blue[200],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _navegarA('Notificaciones'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoVotacionCard() {
    final restante = _cierreVotacion.difference(DateTime.now());
    final horas = restante.inHours;
    final minutos = restante.inMinutes.remainder(60);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[400]!.withValues(alpha: 0.18),
            const Color(0xFF1E293B),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue[400]!.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'VOTACIÓN ACTIVA',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _tituloVotacion,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cierra en ${horas}h ${minutos}min',
            style: const TextStyle(color: Colors.white54, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          if (_tipoUsuario == TipoUsuario.votante) ...[
            if (_yaVoto)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[400]!.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green[400]!.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[400],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ya emitiste tu voto',
                      style: TextStyle(
                        color: Colors.green[300],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _navegarA('Votar'),
                  icon: const Icon(Icons.how_to_vote_outlined, size: 18),
                  label: const Text('Vota ahora'),
                ),
              ),
          ] else
            Row(
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  color: Colors.white54,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text(
                  '268/420 mesas escrutadas',
                  style: TextStyle(color: Colors.white54, fontSize: 12.5),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _navegarA('Dashboard de resultados'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[300],
                  ),
                  child: const Text('Ver en vivo'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGridAccesos() {
    final accesos = _accesos;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accesos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.98,
      ),
      itemBuilder: (context, i) => _buildAccesoCard(accesos[i]),
    );
  }

  Widget _buildAccesoCard(AccesoRapido acceso) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: acceso.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: acceso.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(acceso.icono, color: acceso.color, size: 20),
            ),
            const Spacer(),
            Text(
              acceso.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              acceso.subtitulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCerrarSesion() {
    return OutlinedButton.icon(
      onPressed: () => _navegarA('Cerrar sesión'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red[300],
        side: BorderSide(color: Colors.red[300]!.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.logout, size: 18),
      label: const Text('Cerrar sesión'),
    );
  }
}
