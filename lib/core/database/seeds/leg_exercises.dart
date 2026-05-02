import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';

/// Exercises for the Legs (Gambe)
const legExercises = [
  ExercisesCompanion(
    name: Value('Back Squat'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Bilanciere, Rack (Squat rack), Pesi'),
    focusArea: Value('Quadricipiti, Glutei, Ischiocrurali, Core'),
    preparation: Value(
      "Posiziona il bilanciere sul rack all'altezza delle spalle. Mettiti sotto, appoggialo sui trapezi (high bar) o deltoidi posteriori (low bar). Stacca il bilanciere, fai 1-2 passi indietro. Piedi larghezza spalle, punte leggermente extraruotate.",
    ),
    execution: Value(
      'Inspira e contrai il core. Scendi controllando il movemento (sedere indietro e in basso), idealmente rompendo il parallelo (anca sotto il ginocchio). Mantieni la schiena neutra. Spingi with forza sui talloni/mesopiede per tornare su, espirando.',
    ),
    tips: Value(
      "Mantieni il petto \"alto\" e lo sguardo in avanti o leggermente in basso. Non far collassare le ginocchia verso l'interno (spingile attivamente fuori).",
    ),
  ),
  ExercisesCompanion(
    name: Value('Front Squat'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Bilanciere, Rack, Pesi'),
    focusArea: Value(
      'Quadricipiti (focus primario), Glutei, Core (molto intenso)',
    ),
    preparation: Value(
      "Posiziona il bilanciere sul rack. Avvicinati e posizionalo sui deltoidi anteriori. Incrocia le braccia (presa 'bodybuilder') o usa la presa 'clean' (polsi estesi, gomiti alti). Stacca, fai 1-2 passi indietro.",
    ),
    execution: Value(
      'Scendi mantenendo il busto il più verticale possibile e i gomiti alti. Scendi in accosciata profonda (deep squat). Spingi per tornare su, mantenendo sempre i gomiti sollevati.',
    ),
    tips: Value(
      'Il busto eretto è fondamentale. Se i gomiti cadono, il bilanciere scivolerà. Grande lavoro per il core e la mobilità toracica.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Stacco da terra (Deadlift)'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Bilanciere, Pesi'),
    focusArea: Value(
      'Ischiocrurali, Glutei, Schiena (Erettori spinali, Dorsali), Core',
    ),
    preparation: Value(
      'Piedi larghezza fianchi sotto il bilanciere (deve tagliare il piede a metà). Piegati e afferra il bilanciere (presa prona o mista) appena fuori dalle ginocchia. Abbassa il bacino, schiena piatta e tesa, petto in fuori.',
    ),
    execution: Value(
      "Spingi with le gambe 'allontanando il pavimento'. Quando il bilanciere supera le ginocchia, estendi l'anca portando il bacino in avanti. Chiudi il movemento in piedi, dritto. Scendi in modo controllato.",
    ),
    tips: Value(
      'La schiena DEVE rimanere neutra, mai curvarsi ("gatto"). Pensa a "spingere" with le gambe, non a "tirare" with la schiena.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Stacco da terra (Sumo)'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Bilanciere, Pesi'),
    focusArea: Value('Glutei, Ischiocrurali, Quadricipiti, Adduttori'),
    preparation: Value(
      "Piedi molto larghi, punte rivolte verso l'esterno (varia in base alla mobilità). Afferra il bilanciere all'interno delle gambe (presa larghezza spalle). Scendi in posizione with il busto più eretto rispetto al convenzionale.",
    ),
    execution: Value(
      "Spingi with le gambe, allargando attivamente le ginocchia verso l'esterno (in linea with le punte dei piedi). Estendi l'anca per chiudere il movemento. Contrai i glutei in cima.",
    ),
    tips: Value(
      "Richiede molta mobilità dell'anca. Permette al busto di stare più verticale, riducendo lo stress lombare per alcuni.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Stacco Romeno'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Bilanciere o Manubri'),
    focusArea: Value('Ischiocrurali (focus primario), Glutei'),
    preparation: Value(
      'Parti in piedi with il bilanciere/manubri in mano (puoi staccarlo da un rack). Gambe leggermente piegate (ma fisse), piedi larghezza fianchi.',
    ),
    execution: Value(
      "Spingi il bacino indietro (\"chiudi un cassetto col sedere\"), mantenendo la schiena piatta e il bilanciere/manubri vicino alle gambe. Scendi finché senti un forte allungamento negli ischiocrurali (solitamente sotto il ginocchio). Torna su estendendo l'anca.",
    ),
    tips: Value(
      "Non è uno stacco da terra. Il movemento è un'estensione d'anca (hip hinge), le ginocchia restano quasi bloccate. Il focus è l'allungamento (stretch).",
    ),
  ),
  ExercisesCompanion(
    name: Value('Leg Press (Pressa a 45°)'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Macchinario (Leg Press)'),
    focusArea: Value(
      'Quadricipiti, Glutei, Ischiocrurali (varia with posizione piedi)',
    ),
    preparation: Value(
      'Siediti sulla pressa, schiena e glutei ben aderenti al sedile. Posiziona i piedi sulla piattaforma (larghezza spalle, medi).',
    ),
    execution: Value(
      'Sblocca la sicura. Scendi in modo controllato piegando le ginocchia finché non raggiungono circa 90 gradi (o finché il bacino non inizia a staccarsi). Spingi with forza per tornare su, senza bloccare le ginocchia in cima.',
    ),
    tips: Value(
      'Piedi alti = focus glutei/ischi. Piedi bassi = focus quadricipiti. Non staccare MAI il bacino dallo schienale in fondo al movemento (retroversione).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Affondi with manubri'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Manubri'),
    focusArea: Value('Quadricipiti, Glutei (lavoro unilaterale)'),
    preparation: Value('In piedi, schiena dritta, manubri ai lati del corpo.'),
    execution: Value(
      'Fai un passo lungo in avanti. Abbassa il corpo finché entrambe le ginocchia non formano circa 90 gradi. Il ginocchio posteriore quasi sfiora terra. Spingi sul tallone della gamba anteriore per tornare alla posizione di partenza. Alterna gamba.',
    ),
    tips: Value(
      'Mantieni il busto eretto. Il passo non deve essere né troppo corto (stress sul ginocchio ant.) né troppo lungo (instabilità).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Affondi with bilanciere'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Bilanciere, Rack'),
    focusArea: Value(
      'Quadricipiti, Glutei, Core (maggiore richiesta di stabilità)',
    ),
    preparation: Value(
      'Posiziona il bilanciere sulla schiena come in uno squat (high bar). Stacca dal rack.',
    ),
    execution: Value(
      'Come gli affondi with manubri, ma richiede più equilibrio. Fai un passo avanti, scendi controllato (ginocchia a 90°), spingi per tornare su. Spesso eseguiti camminando (walking lunges).',
    ),
    tips: Value(
      "Richiede molta più stabilità e forza del core rispetto ai manubri. Usa un peso inferiore all'inizio.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Affondi Bulgari'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Manubri (o Bilanciere), Panca (o rialzo)'),
    focusArea: Value('Glutei (focus primario), Quadricipiti'),
    preparation: Value(
      "Posiziona il collo del piede posteriore su una panca. Fai un passo avanti with l'altra gamba. Tieni i manubri ai lati.",
    ),
    execution: Value(
      'Scendi verticalmente finché il ginocchio posteriore non è vicino al pavimento. Il busto può inclinarsi leggermente in avanti per aumentare il focus sui glutei. Spingi sul tallone della gamba anteriore per tornare su.',
    ),
    tips: Value(
      'Esercizio eccellente per i glutei. La distanza dalla panca determina il focus: più lontano = più glutei; più vicino = più quadricipiti.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Leg Extension'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Macchinario (Leg Extension)'),
    focusArea: Value('Quadricipiti (isolamento puro)'),
    preparation: Value(
      'Siediti sulla macchina, regola lo schienale in modo che le ginocchia siano allineate with il perno di rotazione. Posiziona il cuscinetto sulle caviglie.',
    ),
    execution: Value(
      'Estendi completamente le gambe contraendo i quadricipiti. Mantieni la contrazione (picco) per 1 secondo. Ritorna lentamente e in modo controllato alla posizione di partenza.',
    ),
    tips: Value(
      "Puro isolamento. Non usare slancio o pesi eccessivi che stressano l'articolazione del ginocchio. Controlla la fase eccentrica (discesa).",
    ),
  ),
  ExercisesCompanion(
    name: Value('Leg Curl (sdraiato)'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Macchinario (Lying Leg Curl)'),
    focusArea: Value('Ischiocrurali (isolamento)'),
    preparation: Value(
      "Sdraiati prono sulla macchina. Posiziona il cuscinetto sopra i talloni (tendine d'Achille). Afferra le maniglie e tieni il bacino premuto contro la panca.",
    ),
    execution: Value(
      "Fletti le ginocchia portando i talloni verso i glutei. Contrai gli ischiocrurali. Ritorna lentamente alla posizione iniziale, controllando l'eccentrica.",
    ),
    tips: Value(
      'Non sollevare il bacino dalla panca durante il movemento; ciò toglie lavoro agli ischiocrurali e lo sposta sulla schiena.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Leg Curl (seduto)'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Macchinario (Seated Leg Curl)'),
    focusArea: Value("Ischiocrurali (isolamento, focus sull'allungamento)"),
    preparation: Value(
      'Siediti sulla macchina, regola il cuscinetto superiore per bloccare le cosce. Posiziona il cuscinetto inferiore dietro le caviglie.',
    ),
    execution: Value(
      'Fletti le ginocchia portando i talloni sotto il sedile. Contrai e ritorna lentamente. Il movemento è molto controllato.',
    ),
    tips: Value(
      "La versione seduta lavora gli ischiocrurali in una posizione di maggiore allungamento (anca flessa) rispetto alla versione sdraiata, ottimo per l'ipertrofia.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Goblet Squat'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Manubrio (o Kettlebell)'),
    focusArea: Value('Quadricipiti, Glutei, Core'),
    preparation: Value(
      'Tieni un manubrio verticalmente (o un kettlebell) davanti al petto with entrambe le mani. Piedi larghezza spalle.',
    ),
    execution: Value(
      "Scendi in uno squat profondo, mantenendo il busto molto eretto (il peso funge da contrappeso). I gomiti possono scendere all'interno delle ginocchia. Spingi per tornare su.",
    ),
    tips: Value(
      'Eccellente per imparare lo schema motorio dello squat e per rinforzare il core. Mantieni il petto "alto".',
    ),
  ),
  ExercisesCompanion(
    name: Value('Hip Thrust (Bilanciere)'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Panca piana, Bilanciere, Pesi, (Pad per bilanciere)'),
    focusArea: Value('Glutei (focus primario), Ischiocrurali'),
    preparation: Value(
      'Siediti a terra with la parte alta della schiena (sotto le scapole) appoggiata al lato di una panca. Posiziona il bilanciere sopra il bacino (usa un pad!). Piedi a terra, ginocchia piegate.',
    ),
    execution: Value(
      "Spingi with forza i talloni a terra, sollevando il bacino fino a formare un 'ponte' (corpo parallelo al suolo dalle spalle alle ginocchia). Contrai i glutei al massimo in cima. Scendi controllato.",
    ),
    tips: Value(
      "Lo sguardo deve essere in avanti (mento verso lo sterno), non verso il soffitto, per mantenere la colonna vertebrale allineata. È l'esercizio principale per i glutei.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Good Morning (Bilanciere)'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Bilanciere, Rack'),
    focusArea: Value('Ischiocrurali, Glutei, Erettori spinali'),
    preparation: Value(
      "Posiziona il bilanciere sulla schiena (come uno squat 'low bar'). Piedi larghezza fianchi, ginocchia leggermente flesse (ma fisse).",
    ),
    execution: Value(
      "Esegui un \"inchino\" spingendo il bacino indietro e flettendo il busto in avanti. Mantieni la schiena piatta e tesa. Scendi finché il busto non è quasi parallelo al suolo. Torna su estendendo l'anca.",
    ),
    tips: Value(
      'Molto simile a un RDL ma col carico sulla schiena. Usa pesi LEGGERI. È un movemento di "hip hinge", non una flessione della schiena.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Hack Squat (Macchinario)'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Macchinario (Hack Squat)'),
    focusArea: Value('Quadricipiti (focus intenso)'),
    preparation: Value(
      'Posizionati sulla macchina with le spalle sotto i supporti e la schiena ben appoggiata allo schienale. Piedi sulla piattaforma (posizione medio-bassa per focus sui quad).',
    ),
    execution: Value(
      'Sblocca le sicure. Scendi in accosciata profonda, mantenendo la schiena aderente. Spingi per tornare su, senza bloccare le ginocchia.',
    ),
    tips: Value(
      "Permette un'accosciata profonda with supporto per la schiena, ottimo per isolare i quadricipiti. Variare la posizione dei piedi cambia il focus.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Sissy Squat'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Corpo libero (with supporto) o Macchina specifica'),
    isBodyweight: Value(true),
    focusArea: Value('Quadricipiti (isolamento, focus retto femorale)'),
    preparation: Value(
      "In piedi, afferra un supporto per l'equilibrio (se a corpo libero). Piedi vicini.",
    ),
    execution: Value(
      "Piegati all'indietro solo sulle ginocchia, sollevando i talloni. Il corpo forma una linea dritta dalle ginocchia alla testa, inclinata all'indietro. Scendi finché le ginocchia quasi toccano terra. Torna su estendendo i quadricipiti.",
    ),
    tips: Value(
      'Esercizio avanzato di isolamento. Mette molta tensione sul retto femorale. Procedi with cautela per non stressare le ginocchia.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Step-Up (Manubri)'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Panca (o Box pliometrico), Manubri'),
    focusArea: Value('Quadricipiti, Glutei (lavoro unilaterale)'),
    preparation: Value(
      'In piedi di fronte a una panca o box, tieni i manubri ai lati. Appoggia un piede completamente sulla panca.',
    ),
    execution: Value(
      "Spingi sul tallone del piede sul box per sollevare tutto il corpo, portando l'altro ginocchio in alto. Scendi in modo controllato, usando solo la gamba che lavora (non spingere with la gamba a terra).",
    ),
    tips: Value(
      "Non \"rimbalzare\" o spingere with la gamba a terra. Il lavoro deve essere tutto a carico della gamba sul rialzo. Ottimo per l'equilibrio.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Stacco a gambe tese'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Bilanciere (o Manubri)'),
    focusArea: Value("Ischiocrurali (focus sull'allungamento), Glutei"),
    preparation: Value(
      'Simile al RDL, ma le ginocchia sono quasi completamente bloccate (solo una micro-flessione per sicurezza). Schiena piatta.',
    ),
    execution: Value(
      'Fletti il busto in avanti mantenendo le gambe tese. Scendi finché puoi mantenendo la schiena piatta. Il bilanciere potrebbe allontanarsi di più dalle gambe rispetto a un RDL. Torna su contraendo glutei e ischio.',
    ),
    tips: Value(
      "Spesso confuso with l'RDL. L'RDL è un \"hip hinge\" (sedere indietro), lo stacco a gambe tese è più simile a un \"inchino\" with focus sull'allungamento massimo.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Glute Ham Raise'),
    targetMuscle: Value('Gambe'),
    equipment: Value('Macchinario GHR (o panca apposita)'),
    focusArea: Value(
      'Ischiocrurali (entrambe le funzioni), Glutei, Polpacci',
    ),
    preparation: Value(
      'Posizionati sulla macchina GHR, caviglie bloccate, ginocchia appoggiate sul cuscinetto, busto eretto.',
    ),
    execution: Value(
      "Lasciati 'cadere' in avanti in modo controllato (eccentrica), mantenendo il corpo dritto (dalle ginocchia alla testa). Torna su flettendo prima le ginocchia (come un leg curl) e poi estendendo l'anca.",
    ),
    tips: Value(
      'Esercizio durissimo e completo per la catena posteriore. Molti iniziano usando un elastico di supporto o solo la fase eccentrica.',
    ),
  ),
];
