# Squat Counter

Aplicativo Flutter (Android) que utiliza o **acelerômetro** do smartphone
para contar agachamentos, controlar séries e gerar um resumo estatístico
do treino.

## Funcionalidades

- 📐 Configuração de treino (repetições por série e número de séries)
- 📈 Detecção automática de agachamentos via acelerômetro (`sensors_plus`)
- 🔢 Controle de séries com pausa para descanso
- 📊 Resumo final com gráfico e estatísticas (duração, aderência,
  tempo médio por rep, etc.)
- 📚 Histórico persistente de sessões (SQLite)
- 📳 Feedback tátil a cada repetição

## Como rodar

```bash
flutter pub get
flutter run
```

> Use um **dispositivo Android físico** — emuladores não simulam
> acelerômetro de forma realista.

Documentação completa em [`CLAUDE.md`](CLAUDE.md).
