# Squat Counter — Guia do Projeto

App Flutter (Android) que utiliza o **acelerômetro** do smartphone para
contar agachamentos, controlar séries e gerar um resumo estatístico do treino.

---

## 1. Como rodar o aplicativo

### 1.1 Pré-requisitos

- **Flutter SDK** stable (testado com `3.41.6`)
- **Dart SDK** `^3.11.4` (vem com o Flutter)
- **Android SDK** com Platform 34/35 instaladas
- **JDK 17** (configurado em `android/app/build.gradle.kts`)
- Um dispositivo Android físico (recomendado) **ou** emulador.
  > ⚠️ Emuladores não simulam acelerômetro de forma realista. Para testar a
  > detecção de agachamentos, **use um celular real**.

Verifique o ambiente com:

```bash
flutter doctor
```

### 1.2 Instalar dependências

A partir da raiz do projeto:

```bash
flutter pub get
```

### 1.3 Rodar em modo debug

Com o celular conectado via USB (modo de desenvolvedor + depuração USB ativados):

```bash
flutter devices          # confirma que o dispositivo aparece
flutter run              # roda o app em debug
```

Atalhos úteis durante o `flutter run`:
- `r` — hot reload
- `R` — hot restart
- `q` — encerrar

### 1.4 Gerar APK de release

```bash
flutter build apk --release
# APK gerado em: build/app/outputs/flutter-apk/app-release.apk
```

Para instalar o APK no celular:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 1.5 Rodar testes e análise estática

```bash
flutter analyze     # análise estática (lints)
flutter test        # testes unitários dos modelos
```

---

## 2. Como usar o aplicativo

1. **Tela inicial** → toque em **"Configurar treino"**.
2. **Tela de configuração** → defina:
   - Repetições por série (1–100)
   - Quantidade de séries (1–20)
   - Toque em **"Iniciar treino"**.
3. **Tela de treino**:
   - **Coloque o celular no bolso da calça** (posição recomendada).
   - Realize agachamentos normalmente. O contador sobe a cada repetição
     detectada e o celular vibra dando feedback.
   - Caso a detecção falhe em alguma rep, use o botão **"Contar manual"**.
   - Ao completar a série, o app pausa para descanso. Toque em
     **"Iniciar série N"** quando estiver pronto.
4. **Resumo final** aparece automaticamente ao concluir a última série.
5. **Histórico** → todas as sessões ficam salvas em SQLite e podem ser
   revisitadas pela tela "Histórico de treinos".

---

## 3. Critérios de sucesso (rubrica da disciplina)

| # | Critério | Pontos | Onde é atendido no código |
|---|---|---|---|
| 1 | Configuração correta do projeto Flutter e execução no Android | **1,0** | `pubspec.yaml`, `android/`, `lib/main.dart`. Build validado via `flutter build apk --debug`. |
| 2 | Tela de configuração do treino | **1,0** | `lib/screens/config_screen.dart` + `lib/providers/config_provider.dart` (persiste última configuração via `shared_preferences`). |
| 3 | Uso correto do acelerômetro e/ou giroscópio | **1,0** | `lib/services/sensor_service.dart` consome `accelerometerEventStream` do pacote `sensors_plus`. Indicador visual em tempo real (`lib/widgets/sensor_pulse_indicator.dart`). |
| 4 | Contador de repetições utilizando sensores | **1,0** | `lib/services/squat_detector.dart` — máquina de estados sobre a magnitude do acelerômetro. Constantes calibráveis em `lib/core/constants.dart`. |
| 5 | Controle de séries e progresso do treino | **1,5** | `lib/providers/workout_provider.dart` gerencia séries, descanso e finalização. UI: `lib/screens/workout_screen.dart` + `lib/widgets/set_progress_indicator.dart` + `lib/widgets/rep_counter_display.dart`. |
| 6 | Resumo final da sessão | **1,5** | `lib/screens/summary_screen.dart` — exibe total de reps, séries completas, duração total, tempo médio/rep, descanso médio, % de aderência e gráfico de barras (`fl_chart`). Sessão salva em SQLite e revisitável via `lib/screens/history_screen.dart`. |

**Total previsto: 7,0 pontos** (cobertura completa da rubrica).

---

## 4. Algoritmo de detecção de agachamento

O detector observa a **magnitude** do vetor aceleração:

```
m(t) = √(x² + y² + z²)
```

Em repouso, `m ≈ 9.8 m/s²` (gravidade). Durante o agachamento:

- **Descida**: o corpo acelera para baixo → `m` cai abaixo de `THRESHOLD_DOWN`.
- **Fundo**: movimento estabiliza brevemente próximo da gravidade.
- **Subida**: impulso vertical → `m` ultrapassa `THRESHOLD_UP`.
- **Retorno**: `m` estabiliza novamente → conta a repetição.

A magnitude bruta passa por uma **média móvel** (`smoothingWindow = 5` amostras)
para reduzir ruído. Repetições com duração fora de `[MIN_REP_DURATION,
MAX_REP_DURATION]` são descartadas para filtrar tremores ou movimentos lentos
demais.

Os limites podem ser ajustados em `lib/core/constants.dart` conforme a
calibração do dispositivo / posição de uso.

---

## 5. Arquitetura

```
lib/
├── main.dart                  # bootstrap
├── app.dart                   # MultiProvider + MaterialApp
├── core/
│   ├── constants.dart         # thresholds do detector, chaves de storage
│   └── theme.dart             # Material 3 verde
├── models/
│   ├── workout_config.dart
│   ├── workout_session.dart
│   └── squat_event.dart
├── services/
│   ├── sensor_service.dart       # wrapper de sensors_plus
│   ├── squat_detector.dart       # máquina de estados
│   ├── feedback_service.dart     # vibração + som
│   ├── prefs_service.dart        # shared_preferences
│   └── session_repository.dart   # sqflite (histórico)
├── providers/                 # ChangeNotifiers (Provider)
│   ├── config_provider.dart
│   ├── workout_provider.dart
│   └── history_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── config_screen.dart
│   ├── workout_screen.dart
│   ├── summary_screen.dart
│   └── history_screen.dart
└── widgets/
    ├── rep_counter_display.dart
    ├── set_progress_indicator.dart
    └── sensor_pulse_indicator.dart
```

### Fluxo de navegação

```
HomeScreen ──┬──► ConfigScreen ──► WorkoutScreen ──► SummaryScreen ──► Home
             └──► HistoryScreen ──► SummaryScreen (modo histórico)
```

---

## 6. Dependências principais

| Pacote | Uso |
|---|---|
| `provider` | State management entre telas |
| `sensors_plus` | Stream do acelerômetro |
| `shared_preferences` | Última configuração de treino |
| `sqflite` + `path` + `path_provider` | Histórico de sessões |
| `vibration` | Feedback tátil por rep / série / fim |
| `audioplayers` | Beep curto (opcional; sem asset embarcado por padrão) |
| `fl_chart` | Gráfico de barras no resumo |
| `intl` | Formatação de datas |

---

## 7. Permissões Android

`android/app/src/main/AndroidManifest.xml` declara apenas:

```xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

Sensores de movimento (acelerômetro/giroscópio) não exigem permissão.

---

## 8. Calibração e ajustes

Se a detecção contar reps demais ou de menos, ajuste em
`lib/core/constants.dart`:

- **Conta repetições falsas (tremor)** → aumente `thresholdDown` ou
  `minRepDuration`.
- **Não conta agachamentos lentos** → aumente `maxRepDuration`.
- **Não detecta o impulso de subida** → reduza `thresholdUp`.

Use o **indicador de magnitude** no rodapé da tela de treino para visualizar
o sinal em tempo real durante a calibração.
