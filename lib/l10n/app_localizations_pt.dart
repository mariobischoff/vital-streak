// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get welcomeTitle => 'Bem-vindo ao Vital Streak!';

  @override
  String get welcomeSubtitle => 'Comece sua jornada vital hoje.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get noAccountText => 'Não tem uma conta? ';

  @override
  String get signUpText => 'Cadastre-se';

  @override
  String get createAccountTitle => 'Criar Conta';

  @override
  String get createAccountSubtitle =>
      'Junte-se ao Vital Streak e comece a monitorar sua saúde.';

  @override
  String get haveAccountText => 'Já tem uma conta? ';

  @override
  String get createAccountButton => 'Criar Conta';

  @override
  String get dashboardChallengeStarted => 'DESAFIO INICIADO';

  @override
  String get dashboardDays => 'Dias';

  @override
  String get dashboardAvg => 'MÉDIA';

  @override
  String get dashboardTrend => 'TENDÊNCIA DOS ÚLTIMOS 30 DIAS';

  @override
  String get dashboardScanNow => 'Escanear Agora';

  @override
  String get dashboardConstancy => 'Constância nos Últimos 30 Dias';

  @override
  String get dashboardEnterManually => 'Entrada Manual';

  @override
  String get manualEntryTitle => 'ENTRADA MANUAL';

  @override
  String get manualEntryRecord => 'Registre uma medição';

  @override
  String get manualEntryFillDetails =>
      'Preencha os detalhes do seu aparelho manual.';

  @override
  String get manualEntryDate => 'Data da Medição';

  @override
  String get manualEntrySys => 'SISTÓLICA';

  @override
  String get manualEntryDia => 'DIASTÓLICA';

  @override
  String get manualEntrySave => 'Salvar Leitura';

  @override
  String get manualEntryErrorInvalid =>
      'Por favor, insira valores válidos para SYS e DIA.';

  @override
  String get manualEntryErrorSysDia =>
      'A pressão Sistólica (SYS) deve ser maior que a Diastólica (DIA).';

  @override
  String get dashboardRecentActivity => 'ATIVIDADE RECENTE';

  @override
  String get dashboardEmptyTitle => 'Nenhum registro encontrado.';

  @override
  String get dashboardEmptySubtitle =>
      'Faça sua primeira medição para iniciar sua sequência!';

  @override
  String get dashboardCalculating => 'Calculando...';

  @override
  String get dashboardStatus => 'STATUS';

  @override
  String get dashboardAvgBP => 'MÉDIA BP';
}
