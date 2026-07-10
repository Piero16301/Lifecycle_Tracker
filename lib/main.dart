import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lifecycle Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// ===========================================================================
/// PANTALLA PRINCIPAL: Monitorea el Ciclo de Vida de la Aplicación Global
/// ===========================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _showChild = false;
  int _parentCounter = 0;
  String _currentLifecycleState = 'Esperando eventos...';
  final List<String> _lifecycleHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('📱 [App/Parent] initState: Registrado WidgetsBindingObserver.');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('📱 [App/Parent] didChangeDependencies: Contexto listo.');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    String stateMessage = '';

    switch (state) {
      case AppLifecycleState.resumed:
        stateMessage = 'RESUMED: La app volvió a primer plano';
        debugPrint(
          '🔋 [App State] RESUMED: La app volvió a primer plano y es visible.',
        );
        break;
      case AppLifecycleState.inactive:
        stateMessage = 'INACTIVE: Transición (ej. notificaciones)';
        debugPrint(
          '⏳ [App State] INACTIVE: Transición (ej. abriste el centro de notificaciones).',
        );
        break;
      case AppLifecycleState.paused:
        stateMessage = 'PAUSED: App oculta en segundo plano';
        debugPrint(
          '💤 [App State] PAUSED: La app está oculta en segundo plano (buen momento para pausar timers).',
        );
        break;
      case AppLifecycleState.detached:
        stateMessage = 'DETACHED: Motor de Flutter separándose';
        debugPrint(
          '💀 [App State] DETACHED: La app sigue viva pero el motor de Flutter se está separando.',
        );
        break;
      case AppLifecycleState.hidden:
        stateMessage = 'HIDDEN: App completamente oculta';
        debugPrint(
          '🙈 [App State] HIDDEN: La app está completamente oculta (iOS/Android modernos).',
        );
        break;
    }

    setState(() {
      _currentLifecycleState = state.name.toUpperCase();
      final time = DateTime.now();
      final timeString =
          '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}:'
          '${time.second.toString().padLeft(2, '0')}';
      _lifecycleHistory.insert(0, '[$timeString] $stateMessage');

      if (_lifecycleHistory.length > 5) {
        _lifecycleHistory.removeLast();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('📱 [App/Parent] dispose: Removido WidgetsBindingObserver.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 [App/Parent] build: Dibujando la pantalla principal.');
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Lifecycle Tracker')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_android,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'ESTADO DEL SISTEMA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _currentLifecycleState,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Divider(),
                    const Text(
                      'Últimos eventos:',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    ..._lifecycleHistory.map(
                      (event) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          event,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    if (_lifecycleHistory.isEmpty)
                      const Text(
                        'Aún no hay cambios de estado',
                        style: TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Text(
                'Estado del Widget Hijo: ${_showChild ? "Montado" : "Destruido"}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),

              // BOTÓN 1: Montar / Desmontar el widget hijo (Fuerza initState y dispose)
              ElevatedButton.icon(
                icon: Icon(
                  _showChild ? Icons.visibility_off : Icons.visibility,
                ),
                label: Text(
                  _showChild ? 'Destruir Widget Hijo' : 'Montar Widget Hijo',
                ),
                onPressed: () {
                  setState(() {
                    _showChild = !_showChild;
                  });
                },
              ),
              const SizedBox(height: 15),

              // BOTÓN 2: Cambiar una propiedad del padre (Fuerza didUpdateWidget en el hijo)
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Modificar Configuración del Padre'),
                onPressed: _showChild
                    ? () {
                        setState(() {
                          _parentCounter++;
                        });
                      }
                    : null,
              ),

              const Padding(padding: EdgeInsets.all(20.0), child: Divider()),

              // RENDERIZADO CONDICIONAL DEL HIJO
              if (_showChild)
                ChildCounterWidget(parentData: _parentCounter)
              else
                const Text(
                  'Presiona "Montar" para iniciar el ciclo del hijo.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// WIDGET HIJO: Demuestra el Ciclo de Vida Local del Widget
/// ===========================================================================
class ChildCounterWidget extends StatefulWidget {
  const ChildCounterWidget({super.key, required this.parentData});

  final int parentData;

  @override
  State<ChildCounterWidget> createState() => _ChildCounterWidgetState();
}

class _ChildCounterWidgetState extends State<ChildCounterWidget> {
  int _localCounter = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('👶 [Hijo Widget] initState: El hijo ha nacido.');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint(
      '👶 [Hijo Widget] didChangeDependencies: El hijo heredó dependencias.',
    );
  }

  @override
  void didUpdateWidget(covariant ChildCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('🔄 [Hijo Widget] didUpdateWidget: El padre cambió de datos.');
    debugPrint(
      '   ↳ Valor anterior: ${oldWidget.parentData} -> Valor nuevo: ${widget.parentData}',
    );
  }

  @override
  void dispose() {
    debugPrint(
      '🛑 [Hijo Widget] dispose: El hijo ha sido eliminado del árbol de widgets de forma permanente.',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 [Hijo Widget] build: Renderizando UI del Hijo.');

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '👶 COMPONENTE HIJO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Dato enviado por el Padre: ${widget.parentData}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            'Contador Local (setState): $_localCounter',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 15),

          // BOTÓN 3: Modifica el estado interno (Muestra build local sin destruir nada)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _localCounter++;
              });
            },
            child: Text(
              'Incrementar Local',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
