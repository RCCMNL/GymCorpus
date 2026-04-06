import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';

/// Exercises for the Calves (Polpacci)
const calfExercises = [
  ExercisesCompanion(
    name: Value('Calf Raises in piedi (Alla macchina)'),
    targetMuscle: Value('Polpacci'),
    equipment: Value('Macchina (Standing Calf Raise)'),
    focusArea: Value('Gastrocnemio (gemelli)'),
    preparation: Value(
      'Posizionarsi sulla macchina dedicata. Spalle sotto i cuscinetti imbottiti, avampiedi sulla piattaforma, talloni liberi di scendere.',
    ),
    execution: Value(
      "Spingere sui talloni sollevandosi il più in alto possibile sulle punte dei piedi. Mantenere la contrazione di picco per 1-2 secondi. Scendere lentamente sotto il livello della piattaforma per massimizzare l'allungamento (stretch).",
    ),
    tips: Value(
      'Mantenere le ginocchia quasi completamente tese (ma non bloccate) per focalizzare il lavoro sul gastrocnemio. Non "rimbalzare" in basso.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Calf Raises in piedi (Con bilanciere)'),
    targetMuscle: Value('Polpacci'),
    equipment: Value('Bilanciere, Rialzo (step o disco robusto)'),
    focusArea: Value('Gastrocnemio, Stabilizzatori (Core, Caviglie)'),
    preparation: Value(
      'Posizionare un bilanciere sulla schiena (come nello squat). Posizionare gli avampiedi su un rialzo stabile, talloni liberi.',
    ),
    execution: Value(
      "Mantenendo l'equilibrio e il core contratto, sollevarsi sulle punte dei piedi. Contrazione di picco. Scendere lentamente in allungamento.",
    ),
    tips: Value(
      'Richiede molto equilibrio. È consigliabile eseguirlo dentro un rack per sicurezza. Iniziare with carichi bassi per padroneggiare il movemento.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Calf Raises in piedi (Smith Machine)'),
    targetMuscle: Value('Polpacci'),
    equipment: Value('Smith Machine (Multipower), Rialzo'),
    focusArea: Value('Gastrocnemio'),
    preparation: Value(
      'Posizionare la sbarra del Multipower sulla schiena. Posizionare un rialzo sotto i piedi e salirci with gli avampiedi.',
    ),
    execution: Value(
      'Eseguire il calf raise sollevandosi sulle punte. Contrazione. Scendere lentamente in stretch.',
    ),
    tips: Value(
      "Molto più stabile del bilanciere libero, permette di concentrarsi esclusivamente sulla contrazione dei polpacci senza preoccuparsi dell'equilibrio.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Calf Raises in piedi (Manubrio)'),
    targetMuscle: Value('Polpacci'),
    equipment: Value('Manubrio, Rialzo, Supporto (per equilibrio)'),
    focusArea: Value('Gastrocnemio (lavoro unilaterale)'),
    preparation: Value(
      "Tenere un manubrio in una mano (es. destra). Appoggiare l'avampiede della stessa gamba (destra) su un rialzo. Tenersi with l'altra mano (sinistra) a un supporto per l'equilibrio. L'altra gamba (sinistra) è piegata e sollevata.",
    ),
    execution: Value(
      'Sollevare il tallone (destro) il più in alto possibile, contraendo il polpaccio. Scendere lentamente in massimo allungamento.',
    ),
    tips: Value(
      'Il lavoro unilaterale è eccellente per correggere squilibri muscolari e permette un ROM (arco di movemento) completo.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Calf Raises seduto (Macchina)'),
    targetMuscle: Value('Polpacci'),
    equipment: Value('Macchina (Seated Calf Raise)'),
    focusArea: Value('Soleo'),
    preparation: Value(
      'Sedersi alla macchina specifica. Posizionare le ginocchia sotto i cuscinetti imbottiti. Avampiedi sulla piattaforma, talloni liberi.',
    ),
    execution: Value(
      'Spingere with le punte sollevando i talloni, contraendo il polpaccio. Mantenere la contrazione. Scendere lentamente in allungamento.',
    ),
    tips: Value(
      'Tenere le ginocchia piegate a 90° esclude gran parte del gastrocnemio (che è bi-articolare) e isola il lavoro sul soleo, un muscolo importante per lo "spessore" del polpaccio.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Calf Raises alla Pressa 45°'),
    targetMuscle: Value('Polpacci'),
    equipment: Value('Leg Press (Pressa a 45°)'),
    focusArea: Value('Gastrocnemio, Soleo'),
    preparation: Value(
      'Sedersi alla pressa. Posizionare solo gli avampiedi sulla parte bassa della piattaforma, talloni liberi. Spingere per stendere le gambe (NON bloccare le ginocchia!).',
    ),
    execution: Value(
      "Mantenendo le gambe quasi tese, spingere la piattaforma with le punte (flessione plantare). Contrazione. Rilasciare lentamente (flessione dorsale) per l'allungamento.",
    ),
    tips: Value(
      'ATTENZIONE: Non bloccare mai le ginocchia (rischio infortunio). Questo esercizio permette di usare carichi molto elevati in sicurezza.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Calf Raises su scalino, 2 gambe)'),
    targetMuscle: Value('Polpacci'),
    equipment: Value('Scalino (o rialzo), Corpo libero'),
    focusArea: Value('Gastrocnemio, Soleo'),
    preparation: Value(
      'In piedi, posizionare gli avampiedi sul bordo di uno scalino, talloni liberi nel vuoto.',
    ),
    execution: Value(
      'Sollevarsi su entrambe le punte il più in alto possibile. Mantenere la contrazione. Scendere lentamente portando i talloni sotto il livello dello scalino per un allungamento completo.',
    ),
    tips: Value(
      "Ottimo per alte ripetizioni (\"burnout\") o come riscaldamento. Tenersi a un corrimano o al muro per l'equilibrio.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Calf Raises su scalino, 1 gamba)'),
    targetMuscle: Value('Polpacci'),
    equipment: Value('Scalino (o rialzo), Corpo libero'),
    focusArea: Value('Gastrocnemio, Soleo (unilaterale)'),
    preparation: Value(
      "Come il precedente, ma tutto il peso è su una gamba sola. L'altra gamba è sollevata o piegata all'indietro.",
    ),
    execution: Value(
      'Sollevarsi sulla punta della gamba che lavora. Contrazione. Scendere lentamente in massimo allungamento.',
    ),
    tips: Value(
      'Molto più intenso e sfidante rispetto alla versione a due gambe. Ottimo per sviluppare forza unilaterale senza bisogno di pesi.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Salti su box pliometrici'),
    targetMuscle: Value('Polpacci'),
    equipment: Value('Box pliometrico (Plywood box)'),
    focusArea: Value('Polpacci (potenza esplosiva), Quadricipiti, Glutei'),
    preparation: Value(
      'In piedi di fronte a un box di altezza adeguata (iniziare bassi). Posizione di partenza in leggero semi-squat.',
    ),
    execution: Value(
      'Eseguire un salto esplosivo per atterrare morbidamente (in semi-squat) sopra il box. La spinta parte dalla tripla estensione: caviglia (polpacci), ginocchio (quadricipiti) e anca (glutei).',
    ),
    tips: Value(
      "Esercizio pliometrico per la potenza, non per l'ipertrofia pura. I polpacci lavorano in modo esplosivo. Scendere dal box camminando (step down), non saltare all'indietro.",
    ),
  ),
];
