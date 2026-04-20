# Vital Streak 🩺🔥

**Vital Streak** é um aplicativo de monitoramento de pressão arterial projetado para unir precisão clínica com ciência comportamental. Diferente de logs tradicionais, ele foca na **constância** do usuário através de gamificação e visualizações de dados avançadas.

---

## ✨ Principais Diferenciais

### 📊 Painel de Insights Comportamentais
- **Habit HeatMap**: Visualize sua consistência nas últimas 4 semanas. Cada dia de aferição preenche seu mapa de hábitos, incentivando a rotina de cuidado.
- **Range Bar Chart**: Uma abordagem única para visualização de pressão arterial. Em vez de linhas confusas, usamos barras de intervalo que mostram claramente a relação entre Sistólica e Diastólica, coloridas de acordo com as zonas de saúde da AHA/ESC.
- **Sistema de Streaks**: Mantenha sua "chama" acesa! O app rastreia sua sequência de dias consecutivos de monitoramento.

### 📄 Relatórios Médicos Profissionais
- **Exportação em PDF**: Em um toque, gere um relatório formatado com médias, gráficos de tendência e histórico detalhado para compartilhar diretamente com seu médico via WhatsApp ou E-mail.

### 👁️ Scanner Inteligente (AI Powered)
- **OCR com Gemini**: Utilize a câmera para ler automaticamente os valores do seu monitor de pressão arterial. Chega de digitação manual chata.

---

## 🛠️ Stack Técnica

- **Frontend**: [Flutter](https://flutter.dev) (Dart)
- **Gerenciamento de Estado**: [Riverpod 2.0](https://riverpod.dev) com Code Generation.
- **Banco de Dados**: [Supabase](https://supabase.com) (Auth & Data) + Persistência Offline.
- **Gráficos**: [fl_chart](https://pub.dev/packages/fl_chart).
- **IA/OCR**: [Google Generative AI](https://pub.dev/packages/google_generative_ai).

---

## 🚀 Como Executar o Projeto

1. **Pré-requisitos**:
   - Flutter SDK instalado.
   - Uma chave de API do Google Gemini (para o OCR).
   - Um projeto Supabase configurado.

2. **Configuração**:
   - Clone o repo: `git clone https://github.com/mariobischoff/vital-streak.git`
   - Crie um arquivo `.env` na raiz com suas chaves:
     ```env
     SUPABASE_URL=seu_url
     SUPABASE_ANON_KEY=sua_chave
     GEMINI_API_KEY=sua_chave_gemini
     ```

3. **Rodar**:
   ```bash
   flutter pub get
   flutter run
   ```

---

## 👨‍💻 Autor
Desenvolvido por [Mario Bischoff](https://github.com/mariobischoff).

---
*Este é um projeto com fins de monitoramento pessoal. Consulte sempre um médico para decisões de saúde.*
