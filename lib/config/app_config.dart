/// Configuração central do app. Concentra valores antes hardcoded nos serviços.
class AppConfig {
  const AppConfig._();

  /// Base URL do microserviço Python de remoção de fundo.
  /// `10.0.2.2` = máquina host via emulador Android; em dispositivo físico,
  /// usar o IP LAN da máquina host.
  static const String backgroundRemovalBaseUrl = 'http://172.16.255.217:8000';

  /// Timeout das chamadas HTTP ao microserviço de remoção de fundo.
  static const Duration backgroundRemovalTimeout = Duration(seconds: 45);

  /// Base URL da API de contas/backup (mesmo servidor FastAPI do rembg).
  static const String apiBaseUrl = backgroundRemovalBaseUrl;

  /// Timeout das chamadas de auth/backup (upload de imagens pode demorar).
  static const Duration apiTimeout = Duration(seconds: 60);
}
